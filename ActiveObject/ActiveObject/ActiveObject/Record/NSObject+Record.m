//
//  NSObject+Record.m
//  Database
//
//  Created by Ansel on 16/3/23.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "NSObject+Record.h"
#import <objc/runtime.h>
#import "RecordHeader.h"
#import "Record.h"

@implementation NSObject (Record)

//包括 类的属性和类型（但此类型是数据库的类型）
+ (NSArray *)getPropertyAndTypeListUntilRootClass:(Class)rootClass
{
    NSMutableArray *propertyList = [NSMutableArray array];
    
    //当类名是class的name时就不调用父类
    NSString *currentClassName = NSStringFromClass([self class]);
    NSString *toSuperClassName = NSStringFromClass(rootClass);
    
    if ([[self class] superclass] && rootClass && ![currentClassName isEqual:toSuperClassName]) {
        NSArray *superPropertyList = [[self superclass] getPropertyAndTypeListUntilRootClass:rootClass];
        if ([superPropertyList count] > 0) {
            [propertyList addObjectsFromArray:superPropertyList];
        }
    }
    
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    for (unsigned int index = 0; index < propertyCount; ++index) {
        objc_property_t property = properties[index];
        const char * propertyName = property_getName(property);
        //此Type是存在数据库里的Type
        NSString * dbType = [self getDbTypeFromObjcProperty:property];
        [propertyList addObject:[NSString stringWithFormat:@"%@ %@",[NSString stringWithUTF8String:propertyName], dbType]];
    }
    
    free(properties);
    
    return propertyList;
}

- (NSArray *)getValuesWithPropertyList:(NSArray *)propertyList
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (NSString *property in propertyList) {
        id value = [self valueForKey:property];
        if (value) {
            [values addObject:value];
        } else {
            [values addObject:@""];
        }
    }
    
    return values;
}

#pragma mark - PrivateMethod

+ (NSString *)getDbTypeFromObjcProperty:(objc_property_t)property
{
    NSString *dbType = TEXT;
    char * type = property_copyAttributeValue(property, "T");
    switch(type[0]) {
        case 'f' : //float
        case 'd' : //double
        {
            dbType = FLOAT;
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
        case 'B': // BOOL
        {
            dbType = INTEGER;
            break;
        }
        case '@' : //ObjC object
            //Handle different clases in here
        {
            NSString *cls = [NSString stringWithUTF8String:type];
            cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
            cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            if ([NSClassFromString(cls) isSubclassOfClass:[NSString class]]) {
                dbType = TEXT;
            }
            else if ([NSClassFromString(cls) isSubclassOfClass:[NSNumber class]]) {
                dbType = TEXT;
            }
            
            break;
        }
    }
    
    return dbType;
}

@end
