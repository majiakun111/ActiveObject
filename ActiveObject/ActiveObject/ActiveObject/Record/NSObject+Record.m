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

@implementation NSObject (Record)

- (NSDictionary *)getPropertyInfoMapUntilRootClass:(Class)rootClass
{
    return [[self class] getPropertyInfoMapUntilRootClass:rootClass];
}

+ (NSDictionary *)getPropertyInfoMapUntilRootClass:(Class)rootClass
{
    NSMutableDictionary *propertyInfoMap = [NSMutableDictionary dictionary];
    
    NSString *currentClassName = NSStringFromClass([self class]);
    NSString *rootClassName = NSStringFromClass(rootClass);
    
    if ([[self class] superclass] && rootClass && ![currentClassName isEqual:rootClassName]) {
        NSDictionary *superPropertyInfoMap = [[self superclass] getPropertyInfoMapUntilRootClass:rootClass];
        if ([superPropertyInfoMap count] > 0) {
            [propertyInfoMap addEntriesFromDictionary:superPropertyInfoMap];
        }
    }
    
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    for (unsigned int index = 0; index < propertyCount; ++index) {
        objc_property_t property = properties[index];
        const char * propertyName = property_getName(property);
        NSDictionary * typeMap = [self getTypeMapWithProperty:property];
        [propertyInfoMap setObject:typeMap forKey:[NSString stringWithUTF8String:propertyName]];
    }
    
    free(properties);
    
    return propertyInfoMap;
}

- (NSArray *)getValueListWithPropertyList:(NSArray *)propertyList
{
    //修改
    NSMutableArray *valueList = [[NSMutableArray alloc] init];
    for (NSString *property in propertyList) {
        id value = [self valueForKey:property];
        if (value) {
            if ([value isKindOfClass:[NSArray class]]) {
                Class class = [(Record *)self getArrayTransformerModelClassWithKeyPath:property];
                if ([class isSubclassOfClass:[Record class]]) {
                    [valueList addObject:value];  //直接添加数组
                }
                else {
                    NSString *jsonString = [value JSONString];
                    [valueList addObject:jsonString ? jsonString : @""];
                }
            } else if ([value isKindOfClass:[NSDictionary class]]) {
                NSString *jsonString = [value JSONString];
                [valueList addObject:jsonString ? jsonString : @""];
            }
            else {
                [valueList addObject:value];
            }
        } else {
            [valueList addObject:@""];
        }
    }
    
    return valueList;
}

+ (NSDictionary *)getTypeMapWithProperty:(objc_property_t)property
{
    NSMutableDictionary *typeMap = [[NSMutableDictionary alloc] init];
    char * type = property_copyAttributeValue(property, "T");
    switch(type[0]) {
        case 'f' : //float
        case 'd' : {//double
            [typeMap setObject:@"CGFloat" forKey:@"propertyType"];
            [typeMap setObject:@"float" forKey:@"dbType"];
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
            [typeMap setObject:@"NSInteger" forKey:@"propertyType"];
            [typeMap setObject:@"integer" forKey:@"dbType"];
            break;
        }
        case '@' : {//ObjC object
            //Handle different clases in here
            NSString *cls = [NSString stringWithUTF8String:type];
            cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
            cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSString class]]) {
                [typeMap setObject:@"NSString" forKey:@"propertyType"];
            }
            else if ([NSClassFromString(cls) isSubclassOfClass:[NSNumber class]]) {
                [typeMap setObject:@"NSNumber" forKey:@"propertyType"];
            }
            else if ([NSClassFromString(cls) isSubclassOfClass:[NSArray class]]) {
                [typeMap setObject:@"NSArray" forKey:@"propertyType"];
            }
            else if ([NSClassFromString(cls) isSubclassOfClass:[NSDictionary class]]) {
                [typeMap setObject:@"NSDictionary" forKey:@"propertyType"];
            }
            else if ([NSClassFromString(cls) isSubclassOfClass:[Record class]]) {
                [typeMap setObject:cls forKey:@"propertyType"];
            }
            
            [typeMap setObject:@"text" forKey:@"dbType"];
            break;
        }
        default: {
            [typeMap setObject:@"NSString" forKey:@"propertyType"];
            [typeMap setObject:@"text" forKey:@"dbType"];
        }
    }
    
    return typeMap;
}

@end
