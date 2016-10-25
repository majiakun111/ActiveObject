//
//  JSONModel.m
//  ActiveObject
//
//  Created by Ansel on 2016/10/24.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "JSONModel.h"
#import "PropertyManager.h"
#import "NSDictionary+JSON.h"
#import "NSString+JSON.h"
#import "NSArray+JSONModel.h"
#import "JSONModelError.h"
#import "PropertyInfo.h"
#import "JSONModelKeyMapper.h"

//下面静态无需初始化，因为用于关联对象的key的时候只会用到其地址
static const char * kAssociatedArrayContainerClassMapDictioanry;
static const char * kAssociatedKeyMapper;
static const char * kAssociatedPropertyInfoMap;

@implementation JSONModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupArrayContaineClassMapDictioanry];
        [self setupKeyMapper];
        [self setupPropertyInfoMap];
    }
    
    return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary
{
    return [self initWithJSONDictionary:dictionary error:nil];
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    if (!dictionary) {
        if (error) {
            *error = [JSONModelError errorInputIsNil];
        }
        return nil;
    }
    
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = [JSONModelError errorInvalidDataWithDescription:@"Attempt to initialize JSONModel object using initWithDictionary:error: but the dictionary parameter was not an 'NSDictionary'."];
        }
        return nil;
    }

    self = [self init];
    if (self) {
        [self updateModelWithDictionary:dictionary];
    }
    
    return self;
}

+ (id)modelWithJSONDictionary:(NSDictionary *)dictionary
{
    return [self modelWithJSONDictionary:dictionary error:nil];
}

+ (id)modelWithJSONDictionary:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error
{
    return [[self alloc] initWithJSONDictionary:dictionary error:error];
}

- (NSDictionary *)toJSONDictionary
{
    NSDictionary<NSString *, PropertyInfo *> *propertyInfoMap = [self getPropertyInfoMap];
    if (!propertyInfoMap || [[propertyInfoMap allKeys] count] == 0) {
        return nil;
    }
    
    JSONModelKeyMapper *keyMapper = [self getKeyMapper];
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [propertyInfoMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, PropertyInfo * _Nonnull propertyInfo, BOOL * _Nonnull stop) {
        NSString *propertyName = propertyInfo.propertyName;
        NSString *propertyType = propertyInfo.propertyType;
        id value = [self valueForKeyPath:propertyName];
        if (!value) {
            return;
        }
        
        if ([NSClassFromString(propertyType) isSubclassOfClass:[JSONModel class]]) {
            value = [(JSONModel *)value toJSONDictionary];
        } else if ([propertyType isEqual:@"NSArray"]) {
            Class class = [self arrayContainerClassForPropertyName:propertyName];
            if (class && [class isSubclassOfClass:[JSONModel class]]) {
                value = [(NSArray *)value toJSONArray];
            }
        } else if ([propertyType isEqual:@"NSDictionary"]) {
            value = [value JSONString];
        } else {
        }
        
        NSString *jsonKey = [keyMapper getJSONKeyWithModelPropertyName:propertyName];
        jsonKey = jsonKey ? jsonKey : propertyName;
        [jsonDictionary setValue:value forKeyPath:jsonKey];
    }];
    
    return jsonDictionary;
}

#pragma mark - Map

- (void)arrayContainerClass:(Class)class forPropertyName:(NSString *)propertyName
{
    NSMutableDictionary *arrayContainerClassMapDictioanry = objc_getAssociatedObject(self.class, &kAssociatedArrayContainerClassMapDictioanry);
    [arrayContainerClassMapDictioanry setObject:class forKey:propertyName];
}

- (Class)arrayContainerClassForPropertyName:(NSString *)propertyName
{
    NSMutableDictionary *arrayContainerClassMapDictioanry = objc_getAssociatedObject(self.class, &kAssociatedArrayContainerClassMapDictioanry);
    return [arrayContainerClassMapDictioanry objectForKey:propertyName];
}

- (NSDictionary <NSString *, NSString *> *)jsonKeyToModelPropertyNameMap
{
    return nil;
}

#pragma mark -Overrride 避免崩溃

- (void)setNilValueForKey:(NSString *)key
{
#ifdef DEBUG
    NSLog(@"WARNING: %@ %@ %@", NSStringFromClass([self class]),  NSStringFromSelector(_cmd), key);
#endif
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
#ifdef DEBUG
    NSLog(@"WARNING: %@ setValue:%@ forUndefinedKey:%@", NSStringFromClass([self class]),  value, key);
#endif
}

- (id)valueForUndefinedKey:(NSString *)key {
#ifdef DEBUG
    NSLog(@"WARNING: %@ %@ %@", NSStringFromClass([self class]),  NSStringFromSelector(_cmd), key);
#endif
    
    return nil;
}

#pragma mark - PrivateMethod

//此Dictionary可以用来描述model容器中元素对应的类@{"propertyNameA":ClassA}
- (void)setupArrayContaineClassMapDictioanry
{
    if (objc_getAssociatedObject(self.class, &kAssociatedArrayContainerClassMapDictioanry) == nil) {
        NSMutableDictionary *arrayContaineClassMapDictioanry = [[NSMutableDictionary alloc] init];
        
        objc_setAssociatedObject(self.class, &kAssociatedArrayContainerClassMapDictioanry, arrayContaineClassMapDictioanry, OBJC_ASSOCIATION_RETAIN);
        
        arrayContaineClassMapDictioanry = nil;
    }
}

- (void)setupKeyMapper
{
    NSDictionary <NSString *, NSString *> *jsonKeyToModelPropertyNameDictionary = [self jsonKeyToModelPropertyNameMap];
    if (!jsonKeyToModelPropertyNameDictionary) {
        return;
    }
    
    JSONModelKeyMapper *keyMapper = [self getKeyMapper];
    if (!keyMapper) {
        keyMapper = [[JSONModelKeyMapper alloc] initWithDictionary:jsonKeyToModelPropertyNameDictionary];
        objc_setAssociatedObject(self.class, &kAssociatedKeyMapper, keyMapper, OBJC_ASSOCIATION_RETAIN);
        keyMapper = nil;
    }
}

- (JSONModelKeyMapper *)getKeyMapper
{
    JSONModelKeyMapper *keyMapper = objc_getAssociatedObject(self.class, &kAssociatedKeyMapper);
    return keyMapper;
}

- (void)setupPropertyInfoMap
{
    NSDictionary<NSString *, PropertyInfo *> *propertyInfoMap  = [self getPropertyInfoMap];
    if (!propertyInfoMap) {
        NSDictionary<NSString *, PropertyInfo *> *propertyInfoMap = [self getPropertyInfoMapForClass:[self class] untilRootClass:[JSONModel class]];
        objc_setAssociatedObject(self.class, &kAssociatedPropertyInfoMap, propertyInfoMap, OBJC_ASSOCIATION_RETAIN);
    }
}

- (NSDictionary<NSString *, PropertyInfo *> *)getPropertyInfoMap
{
    NSDictionary<NSString *, PropertyInfo *> *propertyInfoMap = objc_getAssociatedObject(self.class, &kAssociatedPropertyInfoMap);
    return propertyInfoMap;
}

- (void)updateModelWithDictionary:(NSDictionary *)dictionary
{
    NSDictionary<NSString*, PropertyInfo *> *propertyInfoMap = [self getPropertyInfoMap];
    if (!propertyInfoMap || [propertyInfoMap allKeys] == 0) {
        return;
    }
    
    JSONModelKeyMapper *keyMapper = [self getKeyMapper];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull jsonKey, id  _Nonnull jsonValue, BOOL * _Nonnull stop) {
       
        NSString *modelPropertyName =  [keyMapper getModelProperyNameWithJSONKey:jsonKey];
        modelPropertyName = modelPropertyName ?  modelPropertyName : jsonKey;
        
        PropertyInfo *propertyInfo = propertyInfoMap[modelPropertyName];
        if (!propertyInfo || !propertyInfo.propertyName) {
            return;
        }
       
        id value = [self getValueWithPropertyInfo:propertyInfo jsonValue:jsonValue];
        if (!value) {
            return;
        }
        
        [self setValue:value forKeyPath:propertyInfo.propertyName];
    }];
}

- (id)getValueWithPropertyInfo:(PropertyInfo *)propertyInfo jsonValue:(id)jsonValue
{
    id value = jsonValue;
    NSString *propertyName = propertyInfo.propertyName;
    NSString *propertyType = propertyInfo.propertyType;
    if ([NSClassFromString(propertyType) isSubclassOfClass:[JSONModel class]]) {
        Class clazz = NSClassFromString(propertyType);
        value = [clazz modelWithJSONDictionary:jsonValue];
    } else if ([propertyType isEqual:@"NSArray"]) {
        Class class = [self arrayContainerClassForPropertyName:propertyName];
        if (class && [class isSubclassOfClass:[JSONModel class]]) {
            value = [jsonValue modelArrayWithClass:class];
        }
    } else if ([propertyType isEqual:@"NSDictionary"]) {
        value = [jsonValue JSONObject];
    } else if ([propertyType isEqual:@"NSString"] &&
               ![value isKindOfClass:[NSString class]]) {
        value = [NSString stringWithFormat:@"%@", value];
    } else if (([propertyType isEqual:@"NSNumber"] ||
               [propertyType isEqual:@"CGFloat"] ||
               [propertyType isEqual:@"NSInteger"]) &&
               [value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        value = [numberFormatter numberFromString:value];
    } else {
    }

    return value;
}

- (NSDictionary<NSString *, PropertyInfo *> *)getPropertyInfoMapForClass:(Class)clazz untilRootClass:(Class)rootClazz
{
    NSString *currentClassName = NSStringFromClass(clazz);
    //以属性作为Key， 以PropertyInfo做为value
    NSMutableDictionary<NSString *, PropertyInfo *> *propertyInfoMap = [[NSMutableDictionary alloc] init];
    NSString *rootClassName = NSStringFromClass(rootClazz);
    
    //递归获取
    if ([[self class] superclass] && ![currentClassName isEqual:rootClassName]) {
        NSDictionary<NSString *, PropertyInfo *> *superPropertyInfoMap = [self getPropertyInfoMapForClass:[clazz superclass] untilRootClass:rootClazz];
        if ([superPropertyInfoMap allKeys] > 0) {
            [propertyInfoMap addEntriesFromDictionary:superPropertyInfoMap];
        }
    }
    
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(clazz, &propertyCount);
    for (unsigned int index = 0; index < propertyCount; ++index) {
        objc_property_t property = properties[index];
        PropertyInfo *propertyInfo = [[PropertyInfo alloc] initWithProperty:property];
        if (!propertyInfo || !propertyInfo.propertyName) {
            continue;
        }
        
        [propertyInfoMap setObject:propertyInfo forKey:propertyInfo.propertyName];
    }
    
    free(properties);
    
    return propertyInfoMap;
}

@end
