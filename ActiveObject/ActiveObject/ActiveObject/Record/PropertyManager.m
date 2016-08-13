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

@implementation PropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property
{
    self = [super init];
    if (self) {
        [self analyzeProperty:property];
    }
    
    return self;
}

- (void)analyzeProperty:(objc_property_t)property
{
    const char * propertyName = property_getName(property);
    self.propertyName = [NSString stringWithUTF8String:propertyName];
    
    char * type = property_copyAttributeValue(property, "T");
    switch(type[0]) {
        case 'f': //float
        case 'd': {//double
            self.propertyType = @"CGFloat";
            self.databaseType = @"float";
            break;
        }
        case 'c':  // char
        case 's':  //short
        case 'i':  // int
        case 'l':  // long
        case 'q':  // long long
        case 'I':  // unsigned int
        case 'S':  // unsigned short
        case 'L':  // unsigned long
        case 'Q':  // unsigned long long
        case 'B': {// BOOL
            self.propertyType = @"NSInteger";
            self.databaseType = @"integer";
            break;
        }
        case '@': {//ObjC object
            //Handle different clases in here
            NSString *cls = [NSString stringWithUTF8String:type];
            cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
            cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            self.propertyType = cls;
            self.databaseType = @"text";
            break;
        }
        default: {
            self.propertyType = @"NSString";
            self.databaseType = @"text";
        }
    }
}

@end

@interface PropertyManager ()

/**
 *   return @{className : PropertyInfo, ...};
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *propertyInfoListMap;

/**
 *   return @{hash : [], ...}; // 对象的hash
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray *> *valueListMap;

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
    NSMutableArray<PropertyInfo *> *propertyInfoList = self.propertyInfoListMap[currentClassName];
    if (propertyInfoList) {
        return propertyInfoList;
    }
    
    propertyInfoList = [[NSMutableArray alloc] init];
    NSString *rootClassName = NSStringFromClass(rootClazz);
    
    //递归获取
    if ([[self class] superclass] && ![currentClassName isEqual:rootClassName]) {
        NSArray *superPropertyInfoList = [self getPropertyInfoListForClass:[clazz superclass] untilRootClass:rootClazz];
        if ([superPropertyInfoList count] > 0) {
            [propertyInfoList addObjectsFromArray:superPropertyInfoList];
        }
    }
    
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(clazz, &propertyCount);
    for (unsigned int index = 0; index < propertyCount; ++index) {
        objc_property_t property = properties[index];
        PropertyInfo *propertyInfo = [[PropertyInfo alloc] initWithProperty:property];
        [propertyInfoList addObject:propertyInfo];
    }
    
    free(properties);
    
    self.propertyInfoListMap[currentClassName] = propertyInfoList;
    
    return propertyInfoList;
}

- (NSArray *)getValueListWithPropertyList:(NSArray *)propertyList forRecord:(Record *)record
{
    NSMutableArray *valueList = self.valueListMap[@([record hash])];
    if (valueList) {
        return valueList;
    }
    
    valueList = [[NSMutableArray alloc] init];
    for (NSString *propertyName in propertyList) {
        id value = [record valueForKey:propertyName];
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
    
    self.valueListMap[@([record hash])] = valueList;
    
    return valueList;
}

#pragma mark - Property

- (NSMutableDictionary<NSString *, NSMutableArray *> *)propertyInfoListMap
{
    if (nil == _propertyInfoListMap) {
        _propertyInfoListMap = [[NSMutableDictionary alloc] init];
    }
    
    return _propertyInfoListMap;
}

- (NSMutableDictionary<NSNumber *,NSMutableArray *> *)valueListMap
{
    if (nil == _valueListMap) {
        _valueListMap = [[NSMutableDictionary alloc] init];
    }
    
    return _valueListMap;
}

#pragma mark - PrivateMethod

- (id)getValuesWithArrayValue:(NSArray *)arrayValue propertyName:(NSString *)propertyName forRecord:(Record *)record
{
    id  value = nil;
    Class class = [record arrayContainerClassForPropertyName:propertyName];
    if ([class isSubclassOfClass:[Record class]]) {
        value = arrayValue; //直接返回数组
    }
    else {
        NSString *jsonString = [arrayValue JSONString];
        value = jsonString;
    }
    
    return value ? value : @"";
}

@end