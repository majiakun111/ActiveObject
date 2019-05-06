//
//  ArrayConverter.m
//  ActiveObject
//
//  Created by Ansel on 2019/5/6.
//  Copyright © 2019 MJK. All rights reserved.
//

#import "ArrayConverter.h"
#import "MJExtension.h"
#import "MJFoundation.h"
#import "NSArray+JSON.h"

@implementation ArrayConverter

+ (id)getArrayValueWithValue:(id)value propertyName:(NSString *)propertyName forObject:(NSObject *)object block:(NSDictionary* (^)(long long rowId, Class clazz))block
{
    id arrayValue = nil;
    Class clazz = [self getClassWithObject:object forPopertyName:propertyName];
    if (clazz && ![MJFoundation isClassFromFoundation:clazz]) {
        //此value是rowIds, eg.@"1,2,3"
        arrayValue = [self getDictionaryRecordsWithRowIds:[value componentsSeparatedByString:@","] class:clazz block:block];
    } else {
        arrayValue = [value mj_JSONObject];
    }
    
    return arrayValue;
}

+ (id)getValuesWithArrayValue:(NSArray *)arrayValue propertyName:(NSString *)propertyName forObject:(NSObject *)object
{
    id value = nil;
    Class clazz =[self getClassWithObject:object forPopertyName:propertyName];
    if (clazz && ![MJFoundation isClassFromFoundation:clazz]) {
        value = arrayValue; //直接返回数组
    } else {
        NSString *jsonString = [arrayValue JSONString];
        value = jsonString;
    }
    
    return value ? value : @"";
}

#pragma mark - PrivateMethod

+ (Class)getClassWithObject:(NSObject *)object forPopertyName:(NSString *)propertyName {
    Class clazz = nil;
    if ([[object class] respondsToSelector:@selector(mj_objectClassInArray)]) {
        clazz = [[object class] mj_objectClassInArray][propertyName];
        if ([clazz isKindOfClass:[NSString class]]) {
            clazz = NSClassFromString((NSString *)clazz);
        }
    }
    
    return clazz;
}

+ (NSArray<NSDictionary *> *)getDictionaryRecordsWithRowIds:(NSArray *)rowIds class:(Class)clazz block:(NSDictionary* (^)(long long rowId, Class clazz))block
{
    NSMutableArray<NSDictionary *> *dictionaryRecords = [[NSMutableArray alloc] init];
    for (NSString *rowId in rowIds) {
        NSDictionary *dictionaryRecord = block ? block([rowId longLongValue], clazz) : nil;
        if (!dictionaryRecord) {
            continue;
        }
        
        [dictionaryRecords addObject:dictionaryRecord];
    }
    
    return dictionaryRecords;
}

@end
