//
//  PropertyAnalyzer.m
//  ActiveObject
//
//  Created by Ansel on 2019/4/22.
//  Copyright © 2019 PingAn. All rights reserved.
//

#import "PropertyAnalyzer.h"
#import "ActiveObjectDefine.h"
#import "JSONModel.h"
#import "NSArray+JSON.h"

static const char * PropertyInfoListAssociatedKey;

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

@implementation PropertyAnalyzer

+ (NSArray<PropertyInfo *> *)getPropertyInfoListForClass:(Class)clazz untilRootClass:(Class)rootClazz {
    NSMutableArray<PropertyInfo *> *propertyInfoList = objc_getAssociatedObject(clazz, &PropertyInfoListAssociatedKey);
    if (propertyInfoList) {
        return propertyInfoList;
    }
    
    propertyInfoList = [[NSMutableArray alloc] init];
    NSString *currentClassName = NSStringFromClass(clazz);
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
    
    objc_setAssociatedObject(clazz, &PropertyInfoListAssociatedKey, propertyInfoList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return propertyInfoList;
}

+ (NSArray *)getPropertyValueListWithPropertyList:(NSArray<NSString *> *)propertyList forRecord:(JSONModel *)record {
    NSMutableArray *propertyValueList = [[NSMutableArray alloc] init];
    for (NSString *propertyName in propertyList) {
        id value = [record valueForKey:propertyName];
        if (!value) {
            [propertyValueList addObject:@""];
            continue;
        }
        
        if ([value isKindOfClass:[NSArray class]]) {
            [propertyValueList addObject:[self getValuesWithArrayValue:value propertyName:propertyName forRecord:record]];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            NSString *jsonString = [value JSONString];
            [propertyValueList addObject:jsonString ? jsonString : @""];
        } else {
            [propertyValueList addObject:value];
        }
    }
    
    return propertyValueList;
}

#pragma mark - PrivateMethod

+ (id)getValuesWithArrayValue:(NSArray *)arrayValue propertyName:(NSString *)propertyName forRecord:(JSONModel *)record
{
    id  value = nil;
    Class class = [record objectClassInArray][propertyName];
    if ([class isSubclassOfClass:[JSONModel class]]) {
        value = arrayValue; //直接返回数组
    } else {
        NSString *jsonString = [arrayValue JSONString];
        value = jsonString;
    }
    
    return value ? value : @"";
}

@end
