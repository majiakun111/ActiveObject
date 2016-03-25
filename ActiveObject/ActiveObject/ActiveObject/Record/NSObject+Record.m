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
#import "RecordDefine.h"

@implementation NSObject (Record)

- (NSArray *)getPropertyInfoListUntilRootClass:(Class)rootClass
{
    return [[self class] getPropertyInfoListUntilRootClass:rootClass];
}

+ (NSArray *)getPropertyInfoListUntilRootClass:(Class)rootClass
{
    NSMutableArray *propertyInfoList = [NSMutableArray array];
    
    NSString *currentClassName = NSStringFromClass([self class]);
    NSString *rootClassName = NSStringFromClass(rootClass);
    
    if ([[self class] superclass] && rootClass && ![currentClassName isEqual:rootClassName]) {
        NSArray *superPropertyInfoList = [[self superclass] getPropertyInfoListUntilRootClass:rootClass];
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

@end
