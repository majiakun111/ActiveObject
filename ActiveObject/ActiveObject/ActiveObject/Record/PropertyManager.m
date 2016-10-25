//
//  PropertyInfoListManager.m
//  ActiveObject
//
//  Created by Ansel on 16/8/13.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "PropertyManager.h"
#import "ActiveObjectDefine.h"
#import "Record.h"
#import "NSArray+JSON.h"
#import "PropertyInfo.h"

@interface PropertyManager ()

/**
 *   return @{className : NSArray<PropertyInfo *>, ...};
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<PropertyInfo *> *> *propertyInfoListMap;


/**
 *   return @{hash : [], ...}; // 对象的hash
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSArray *> *valueListMap;

@end

@implementation PropertyManager

+ (instancetype)shareInstance
{
    static PropertyManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PropertyManager alloc] init];
    });
    
    return instance;
}

- (NSArray<PropertyInfo *> *)getPropertyInfoListForClass:(Class)clazz untilRootClass:(Class)rootClazz
{
    NSString *currentClassName = NSStringFromClass(clazz);
    NSArray<PropertyInfo *> *propertyInfoList = self.propertyInfoListMap[currentClassName];
    if (propertyInfoList) {
        return propertyInfoList;
    }
    
    propertyInfoList = [self _getPropertyInfoListForClass:clazz untilRootClass:rootClazz];
    self.propertyInfoListMap[currentClassName] = propertyInfoList;
    
    return propertyInfoList;
}

- (NSArray *)getValueListWithPropertyList:(NSArray *)propertyList forRecord:(JSONModel *)record
{
    NSArray *valueList = self.valueListMap[@([record hash])];
    if (valueList) {
        return valueList;
    }
    
    valueList = [self _getValueListWithPropertyList:propertyList forRecord:record];
    self.valueListMap[@([record hash])] = valueList;
    
    return valueList;
}

- (void)removePropertyInfoListForClasss:(Class)clazz
{
    NSString *currentClassName = NSStringFromClass(clazz);
    [self.propertyInfoListMap removeObjectForKey:currentClassName];
}

- (void)removeValueListForRecord:(Record *)record
{
    [self.valueListMap removeObjectForKey:@([record hash])];
}

#pragma mark - Property

- (NSMutableDictionary<NSString *, NSArray<PropertyInfo *> *> *)propertyInfoListMap
{
    if (nil == _propertyInfoListMap) {
        _propertyInfoListMap = [[NSMutableDictionary alloc] init];
    }
    
    return _propertyInfoListMap;
}

- (NSMutableDictionary<NSNumber *,NSArray *> *)valueListMap
{
    if (nil == _valueListMap) {
        _valueListMap = [[NSMutableDictionary alloc] init];
    }
    
    return _valueListMap;
}

#pragma mark - PrivateMethod

- (NSArray<PropertyInfo *> *)_getPropertyInfoListForClass:(Class)clazz untilRootClass:(Class)rootClazz
{
    NSString *currentClassName = NSStringFromClass(clazz);
    NSArray<PropertyInfo *> *propertyInfoList = [[NSMutableArray alloc] init];
    NSString *rootClassName = NSStringFromClass(rootClazz);
    
    //递归获取
    if ([[self class] superclass] && ![currentClassName isEqual:rootClassName]) {
        NSArray *superPropertyInfoList = [self _getPropertyInfoListForClass:[clazz superclass] untilRootClass:rootClazz];
        if ([superPropertyInfoList count] > 0) {
            [(NSMutableArray *)propertyInfoList addObjectsFromArray:superPropertyInfoList];
        }
    }
    
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(clazz, &propertyCount);
    for (unsigned int index = 0; index < propertyCount; ++index) {
        objc_property_t property = properties[index];
        PropertyInfo *propertyInfo = [[PropertyInfo alloc] initWithProperty:property];
        [(NSMutableArray *)propertyInfoList addObject:propertyInfo];
    }
    
    free(properties);
    
    return propertyInfoList;
}

- (NSArray *)_getValueListWithPropertyList:(NSArray *)propertyList forRecord:(JSONModel *)record
{
    NSMutableArray *valueList = [[NSMutableArray alloc] init];
    for (NSString *propertyName in propertyList) {
        id value = [record valueForKeyPath:propertyName];
        if (!value) {
            [valueList addObject:@""];
            continue;
        }
        
        if ([value isKindOfClass:[NSArray class]]) {
            [valueList addObject: [self getValuesWithArrayValue:value propertyName:propertyName forRecord:record]];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            NSString *jsonString = [value JSONString];
            [valueList addObject:jsonString ? jsonString : @""];
        }
        else {
            [valueList addObject:value];
        }
    }
    
    return valueList;
}

- (id)getValuesWithArrayValue:(NSArray *)arrayValue propertyName:(NSString *)propertyName forRecord:(JSONModel *)record
{
    id  value = nil;
    Class class = [record arrayContainerClassForPropertyName:propertyName];
    if ([class isSubclassOfClass:[JSONModel class]]) {
        value = arrayValue; //直接返回数组
    }
    else {
        NSString *jsonString = [arrayValue JSONString];
        value = jsonString;
    }
    
    return value ? value : @"";
}

@end
