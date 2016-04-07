//
//  NSObject+Record.m
//  Database
//
//  Created by Ansel on 16/3/23.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "NSObject+Record.h"
#import <objc/runtime.h>
#import "Record.h"
#import "NSArray+JSON.h"
#import "ActiveObjectDefine.h"

@implementation NSObject (Record)

- (NSArray *)getPropertyInfoList
{
    return [[self class] getPropertyInfoList];
}

+ (NSArray *)getPropertyInfoList
{
    NSMutableArray *propertyInfoList = [NSMutableArray array];
    
    NSString *currentClassName = NSStringFromClass([self class]);
    NSString *rootClassName = NSStringFromClass([Record class]);
    
    if ([[self class] superclass] && ![currentClassName isEqual:rootClassName]) {
        NSArray *superPropertyInfoList = [[self superclass] getPropertyInfoList];
        if ([superPropertyInfoList count] > 0) {
            [propertyInfoList addObjectsFromArray:superPropertyInfoList];
        }
    }
    
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    for (unsigned int index = 0; index < propertyCount; ++index) {
        objc_property_t property = properties[index];
        const char * propertyName = property_getName(property);
        
        NSMutableDictionary *propertyInfo = [NSMutableDictionary dictionary];
        [propertyInfo setObject:[NSString stringWithUTF8String:propertyName] forKey:PROPERTY_NAME];
         NSDictionary * typeMap = [self getTypeMapWithProperty:property];
        [propertyInfo addEntriesFromDictionary:typeMap];
        
        [propertyInfoList addObject:propertyInfo];
    }
    
    free(properties);
    
    return propertyInfoList;
}

- (NSArray *)getValueListWithPropertyList:(NSArray *)propertyList
{
    NSMutableArray *valueList = [[NSMutableArray alloc] init];
    for (NSString *propertyName in propertyList) {
        id value = [self valueForKey:propertyName];
        if (!value) {
            [valueList addObject:@""];
            continue;
        }
        
        if ([value isKindOfClass:[NSArray class]]) {
            [valueList addObject: [self getValuesWithArrayValue:value propertyName:propertyName]];
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

#pragma mark - PrivateMethod

+ (NSDictionary *)getTypeMapWithProperty:(objc_property_t)property
{
    NSMutableDictionary *typeMap = [[NSMutableDictionary alloc] init];
    char * type = property_copyAttributeValue(property, "T");
    switch(type[0]) {
        case 'f' : //float
        case 'd' : {//double
            [typeMap setObject:@"CGFloat" forKey:PROPERTY_TYPE];
            [typeMap setObject:@"float" forKey:DATABASE_TYPE];
            break;
        }
        case 'c':   // char
        case 's' : //short
        case 'i':   // int
        case 'l':   // long
        case 'q' : // long long
        case 'I': // unsigned int
        case 'S': // unsigned short
        case 'L': // unsigned long
        case 'Q' :  // unsigned long long
        case 'B': {// BOOL
            [typeMap setObject:@"NSInteger" forKey:PROPERTY_TYPE];
            [typeMap setObject:@"integer" forKey:DATABASE_TYPE];
            break;
        }
        case '@' : {//ObjC object
            //Handle different clases in here
            NSString *cls = [NSString stringWithUTF8String:type];
            cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
            cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSString class]]) {
                [typeMap setObject:@"NSString" forKey:PROPERTY_TYPE];
            }
            else if ([NSClassFromString(cls) isSubclassOfClass:[NSNumber class]]) {
                [typeMap setObject:@"NSNumber" forKey:PROPERTY_TYPE];
            }
            else if ([NSClassFromString(cls) isSubclassOfClass:[NSArray class]]) {
                [typeMap setObject:@"NSArray" forKey:PROPERTY_TYPE];
            }
            else if ([NSClassFromString(cls) isSubclassOfClass:[NSDictionary class]]) {
                [typeMap setObject:@"NSDictionary" forKey:PROPERTY_TYPE];
            }
            else if ([NSClassFromString(cls) isSubclassOfClass:[Record class]]) {
                [typeMap setObject:cls forKey:PROPERTY_TYPE];
            }
            
            [typeMap setObject:@"text" forKey:DATABASE_TYPE];
            break;
        }
        default: {
            [typeMap setObject:@"NSString" forKey:PROPERTY_TYPE];
            [typeMap setObject:@"text" forKey:DATABASE_TYPE];
        }
    }
    
    return typeMap;
}

- (id)getValuesWithArrayValue:(NSArray *)arrayValue propertyName:(NSString *)propertyName
{
    id  value = nil;
    Class class = [(Record *)self getArrayTransformerModelClassWithKeyPath:propertyName];
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
