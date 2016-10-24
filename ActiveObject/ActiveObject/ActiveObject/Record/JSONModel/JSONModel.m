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

//下面静态无需初始化，因为用于关联对象的key的时候只会用到其地址
static const char * kAssociatedArrayContainerClassMapDictioanry;

@implementation JSONModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupArrayContaineClassMapDictioanry];
    }
    
    return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary
{
    return [self initWithJSONDictionary:dictionary error:nil];
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    JSONModel *jsonModel = [[[self class] alloc] init];
    
    NSArray<PropertyInfo *> *propertyInfoList = [[PropertyManager shareInstance] getPropertyInfoListForClass:[self class] untilRootClass:[JSONModel class]];
    [propertyInfoList enumerateObjectsUsingBlock:^(PropertyInfo*  _Nonnull propertyInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *propertyName = propertyInfo.propertyName;
        NSString *propertyType = propertyInfo.propertyType;
        id value = dictionary[propertyName];
        if ([NSClassFromString(propertyType) isSubclassOfClass:[JSONModel class]]) {
            
            Class clazz = NSClassFromString(propertyType);
            value = [clazz modelWithJSONDictionary:value];
            [jsonModel setValue:value forKeyPath:propertyName];
            
        } else if ([propertyType isEqual:@"NSArray"]) {
            
            Class class = [self arrayContainerClassForPropertyName:propertyName];
            if (class && [class isSubclassOfClass:[JSONModel class]]) {
                value = [value modelArrayWithClass:class];
            }
            [jsonModel setValue:value forKeyPath:propertyName];
            
        } else if ([propertyType isEqual:@"NSDictionary"]) {
            
            value = [value JSONObject];
            [jsonModel setValue:value forKeyPath:propertyName];
            
        } else {
            
            [jsonModel setValue:value forKeyPath:propertyName];
            
        }
        
    }];

    return jsonModel;
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
    NSArray<PropertyInfo *> *propertyInfoList = [[PropertyManager shareInstance] getPropertyInfoListForClass:[self class] untilRootClass:[JSONModel class]];
    if (!propertyInfoList || [propertyInfoList count] == 0) {
        return nil;
    }
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [propertyInfoList enumerateObjectsUsingBlock:^(PropertyInfo*  _Nonnull propertyInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *propertyName = propertyInfo.propertyName;
        NSString *propertyType = propertyInfo.propertyType;
        id value = [self valueForKey:propertyName];
        
        if ([NSClassFromString(propertyType) isSubclassOfClass:[JSONModel class]]) {
            
            value = [(JSONModel *)value toJSONDictionary];
            [jsonDictionary setValue:value forKeyPath:propertyName];
            
        } else if ([propertyType isEqual:@"NSArray"]) {
            
            Class class = [self arrayContainerClassForPropertyName:propertyName];
            if (class && [class isSubclassOfClass:[JSONModel class]]) {
                value = [(NSArray *)value toJSONArray];
            }
            
            [jsonDictionary setValue:value forKeyPath:propertyName];
            
        } else if ([propertyType isEqual:@"NSDictionary"]) {
            
            value = [value JSONString];
            [jsonDictionary setValue:value forKeyPath:propertyName];
            
        } else {
            
            [jsonDictionary setValue:value forKeyPath:propertyName];
            
        }
        
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

@end
