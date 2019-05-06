//
//  PropertyAnalyzer.m
//  ActiveObject
//
//  Created by Ansel on 2019/4/22.
//  Copyright © 2019 MJK. All rights reserved.
//

#import "PropertyAnalyzer.h"
#import "ActiveObjectDefine.h"
#import "MJExtension.h"
#import "MJFoundation.h"
#import "ArrayConverter.h"

static const char * PropertyInfoListAssociatedKey;

@interface PropertyInfo ()

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, strong) Class propertyClass;
@property (nonatomic, getter = isFromFoundation) BOOL fromFoundation;
@property (nonatomic, copy) NSString *databaseType;

@end

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
            self.databaseType = @"integer";
            break;
        }
        case '@': {//ObjC object
            //Handle different clases in here
            NSString *cls = [NSString stringWithUTF8String:type];
            cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
            cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            self.propertyClass = NSClassFromString(cls);
            self.fromFoundation = [MJFoundation isClassFromFoundation:self.propertyClass];
            self.databaseType = @"text";
            break;
        }
        default: {
            self.databaseType = @"text";
        }
    }
}

@end

@implementation PropertyAnalyzer

+ (NSArray<PropertyInfo *> *)getPropertyInfoListForClass:(Class)clazz {
    NSMutableArray<PropertyInfo *> *propertyInfoList = objc_getAssociatedObject(clazz, &PropertyInfoListAssociatedKey);
    if (propertyInfoList) {
        return propertyInfoList;
    }
    
    propertyInfoList = [[NSMutableArray alloc] init];
    //递归获取
    if ([clazz superclass] && ![[clazz superclass] isEqual:[NSObject class]]) {
        NSArray *superPropertyInfoList = [self getPropertyInfoListForClass:[clazz superclass]];
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
    
    objc_setAssociatedObject(clazz, &PropertyInfoListAssociatedKey, propertyInfoList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return propertyInfoList;
}

+ (NSArray *)getPropertyValueListWithPropertyList:(NSArray<NSString *> *)propertyList forObject:(NSObject *)object {
    NSMutableArray *propertyValueList = [[NSMutableArray alloc] init];
    for (NSString *propertyName in propertyList) {
        id value = [object valueForKey:propertyName];
        if (!value) {
            [propertyValueList addObject:@""];
            continue;
        }
        
        if ([value isKindOfClass:[NSArray class]]) {
            [propertyValueList addObject:[ArrayConverter getValuesWithArrayValue:value propertyName:propertyName forObject:object]];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            NSString *jsonString = [value mj_JSONString];
            [propertyValueList addObject:jsonString ? jsonString : @""];
        } else {
            [propertyValueList addObject:value];
        }
    }
    
    return propertyValueList;
}

@end
