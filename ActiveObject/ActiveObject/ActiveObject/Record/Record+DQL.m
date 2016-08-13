//
//  Record+DQL.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record+DQL.h"
#import "DatabaseDAO.h"
#import "DatabaseDAO+DQL.h"
#import "Record+Additions.h"
#import "Record+Condition.h"
#import "NSString+JSON.h"
#import "ActiveObjectDefine.h"
#import "PropertyManager.h"

@implementation Record (DQL)

- (NSArray <__kindof Record *> *)query
{    
    NSArray <NSMutableDictionary *> *results =  [[DatabaseDAO sharedInstance] queryWithColumns:self.field where:self.where groupBy:self.groupBy having:self.having orderBy:self.orderBy limit:self.limit forTable:[self tableName]];
    
    NSArray <Record *> *records = [self getModelsfromArray:results];
    
    return records;
}

- (NSArray <NSDictionary *> *)queryDictionary
{
    NSArray<NSDictionary *> *results = [[DatabaseDAO sharedInstance] queryWithColumns:self.field where:self.where groupBy:self.groupBy having:self.having orderBy:self.orderBy limit:self.limit forTable:[self tableName]];
    
    return results;
}

#pragma mark - PrivateMethod
//此方法耦合性 较强
- (NSArray <Record *> *)getModelsfromArray:(NSArray <NSDictionary *> *)array
{
    if (!array) {
        return nil;
    }
    
    NSArray<PropertyInfo *> *propertyInfoList = [[PropertyManager shareInstance] getPropertyInfoListForClass:[self class] untilRootClass:[Record class]];
    NSMutableArray <Record *> *records = [[NSMutableArray alloc] init];
    
    //array 是数据库返回的结果
    for (NSDictionary *dictionary in array) {
        Record *record = [[[self class] alloc] init];
        
        [propertyInfoList enumerateObjectsUsingBlock:^(PropertyInfo*  _Nonnull propertyInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *propertyName = propertyInfo.propertyName;
            NSString *propertyType = propertyInfo.propertyType;
            id value = dictionary[propertyName];
            if ([NSClassFromString(propertyType) isSubclassOfClass:[Record class]]) {
                //value 是rowId
                Record *rd = [self getRecordWithRowId:value class:NSClassFromString(propertyType)];
                [record setValue:rd forKeyPath:propertyName];
                
            } else if ([propertyType isEqual:@"NSArray"]) {
                
                id arrayValue = [self getArrayValueWithValue:value propertyName:propertyName];
                [record setValue:arrayValue forKeyPath:propertyName];
                
            } else if ([propertyType isEqual:@"NSDictionary"]) {
                
                id JSONObject = [value JSONObject];
                [record setValue:JSONObject forKeyPath:propertyName];
                
            } else {
                
                [record setValue:value forKeyPath:propertyName];
                
            }
            
        }];
        
        [records addObject:record];
    }
    
    return records;
}

- (Record *)getRecordWithRowId:(NSNumber *)rowId class:(Class)class
{
    Record *record = [[class alloc] init];
    [record setWhere:@{ROW_ID : rowId}];
    NSArray<Record *> *results = [record query];
    
    return [results firstObject];
}


- (NSArray<Record *> *)getRecordsWithRowIds:(NSArray *)rowIds class:(Class)class
{
    NSMutableArray *records = [[NSMutableArray alloc] init];

    for (NSString *rowId in rowIds) {
        Record *record = [self getRecordWithRowId:@([rowId longLongValue]) class:class];
        
        if (!record) {
            continue;
        }
        
        [records addObject:record];
    }
    
    return records;
}

- (id)getArrayValueWithValue:(id)value propertyName:(NSString *)propertyName
{
    id arrayValue = nil;
    Class class = [self arrayContainerClassForPropertyName:propertyName];
    if (class && [class isSubclassOfClass:[Record class]]) {
        //此value是rowIds, eg.@"1,2,3"
        arrayValue = [self getRecordsWithRowIds:[value componentsSeparatedByString:@","] class:class];
    }
    else {
        arrayValue = [value JSONObject];
    }
    
    return arrayValue;
}

@end
