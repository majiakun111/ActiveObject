//
//  NSObject+JSONModel.m
//  ActiveObject
//
//  Created by Ansel on 2019/4/29.
//  Copyright © 2019 MJK. All rights reserved.
//

#import "NSObject+JSONModel.h"
#import "PropertyAnalyzer.h"
#import "NSDictionary+JSON.h"
#import "NSString+JSON.h"
#import "NSArray+JSONModel.h"
#import "NSObject+Foundation.h"

//下面静态无需初始化，因为用于关联对象的key的时候只会用到其地址
static const char * kAssociatedArrayContainerClassMapDictioanry;

@implementation NSObject (JSONModel)

- (id)initWithJSONDictionary:(NSDictionary *)dictionary
{
    return [self initWithJSONDictionary:dictionary error:nil];
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    self = [self init];
    if (self) {
        NSArray<PropertyInfo *> *propertyInfoList = [PropertyAnalyzer getPropertyInfoListForClass:[self class] untilRootClass:[NSObject class]];
        [propertyInfoList enumerateObjectsUsingBlock:^(PropertyInfo*  _Nonnull propertyInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *propertyName = propertyInfo.propertyName;
            Class propertyClass = propertyInfo.propertyClass;
            id value = dictionary[propertyName];
            if (propertyClass && !propertyInfo.isFromFoundation) {
                value = [propertyClass modelWithJSONDictionary:value];
            } else if ([propertyClass isKindOfClass:object_getClass([NSArray class])]) {
                Class clazz = [self objectClassInArray][propertyName];
                if (clazz && ![self fromFoundationForClazz:clazz]) {
                    value = [value modelArrayWithClass:clazz];
                }
                
                if ([propertyClass isKindOfClass:object_getClass([NSMutableArray class])]) {
                    value = [value mutableCopy];
                }
            } else if ([propertyClass isKindOfClass:object_getClass([NSDictionary class])]) {
                if ([value isKindOfClass:[NSString class]]) {
                    value = [value JSONObject];
                }
                
                if ([propertyClass isKindOfClass:object_getClass([NSMutableDictionary class])]) {
                    value = [value mutableCopy];
                }
            } else if ([propertyClass isKindOfClass:object_getClass([NSMutableString class])] || [propertyClass isKindOfClass:object_getClass([NSMutableData class])]) {
                value = [value mutableCopy];
            }
            
            [self setValue:value forKeyPath:propertyName];
        }];
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
    NSArray<PropertyInfo *> *propertyInfoList = [PropertyAnalyzer getPropertyInfoListForClass:[self class] untilRootClass:[NSObject class]];
    if (!propertyInfoList || [propertyInfoList count] == 0) {
        return nil;
    }
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [propertyInfoList enumerateObjectsUsingBlock:^(PropertyInfo*  _Nonnull propertyInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *propertyName = propertyInfo.propertyName;
        Class propertyClass = propertyInfo.propertyClass;
        id value = [self valueForKey:propertyName];
        if (propertyClass && propertyInfo.isFromFoundation) {
            value = [value toJSONDictionary];
        } else if ([propertyClass isKindOfClass:object_getClass([NSArray class])]) {
            Class clazz = [self objectClassInArray][propertyName];
            if (clazz && ![self fromFoundationForClazz:clazz]) {
                value = [(NSArray *)value toJSONArray];
            }
        } else if ([propertyClass isKindOfClass:object_getClass([NSDictionary class])]) {
            value = [value JSONString];
        } else if ([propertyClass isKindOfClass:object_getClass([NSMutableString class])] || [propertyClass isKindOfClass:object_getClass([NSMutableData class])]) {
            value = [value copy];
        }
        
        [jsonDictionary setValue:value forKeyPath:propertyName];
    }];
    
    return jsonDictionary;
}

#pragma mark - Map

- (NSDictionary *)objectClassInArray {
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

@end
