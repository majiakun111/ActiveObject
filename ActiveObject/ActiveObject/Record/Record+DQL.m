//
//  Record+DQL.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "Record+DQL.h"
#import "DatabaseDAO.h"
#import "DatabaseDAO+DQL.h"
#import "Record+Additions.h"
#import "Record+Condition.h"
#import "ActiveObjectDefine.h"
#import "PropertyAnalyzer.h"
#import "MJExtension.h"
#import "ArrayConverter.h"

@implementation Record (DQL)

- (NSArray <__kindof Record *> *)query
{    
    NSArray <NSMutableDictionary *> *results =  [[DatabaseDAO sharedInstance] queryWithColumns:self.field where:self.where groupBy:self.groupBy having:self.having orderBy:self.orderBy limit:self.limit forTable:[self tableName]];
    
    NSArray<Record *> *records = [self getRecordsfromDictionaryRecords:results];
    
    return records;
}

- (NSArray <NSDictionary *> *)queryDictionary
{
    NSArray<NSDictionary *> *results = [[DatabaseDAO sharedInstance] queryWithColumns:self.field where:self.where groupBy:self.groupBy having:self.having orderBy:self.orderBy limit:self.limit forTable:[self tableName]];
    
    return results;
}

#pragma mark - PrivateMethod

- (NSArray<Record *> *)getRecordsfromDictionaryRecords:(NSArray<NSDictionary *> *)dictionaryRecords
{
    if (!dictionaryRecords || [dictionaryRecords count] == 0) {
        return nil;
    }
    
    NSArray<NSDictionary *> *associationDictionaryRecords = [self getAssociationDictionaryRecordsWithArray:dictionaryRecords];
    if (!associationDictionaryRecords || [associationDictionaryRecords count] == 0) {
        return nil;
    }
    
    NSArray<Record *> *records = [[self class] mj_objectArrayWithKeyValuesArray:associationDictionaryRecords];
    return records;
}

- (NSArray<NSDictionary *> *)getAssociationDictionaryRecordsWithArray:(NSArray <NSDictionary *> *)array
{
    if (!array) {
        return nil;
    }
    
    NSArray<PropertyInfo *> *propertyInfoList = [PropertyAnalyzer getPropertyInfoListForClass:[self class]];
    NSMutableArray <NSMutableDictionary *> *associationDictionaryRecords = [[NSMutableArray alloc] init];
    
    //array 是数据库返回的结果
    for (NSDictionary *dictionaryRecord in array) {
        NSMutableDictionary *associationDictionaryRecord = [[NSMutableDictionary alloc] initWithDictionary:dictionaryRecord];
        
        [propertyInfoList enumerateObjectsUsingBlock:^(PropertyInfo*  _Nonnull propertyInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = dictionaryRecord[propertyInfo.propertyName];
            if (propertyInfo.propertyClass && !propertyInfo.isFromFoundation) {
                //value 是rowId
                NSDictionary *rd = [self getDictionaryRecordWithRowId:value class:propertyInfo.propertyClass];
                [associationDictionaryRecord setObject:rd forKey: propertyInfo.propertyName];
            } else if ([propertyInfo.propertyClass isKindOfClass:object_getClass([NSArray class])]) {
                id arrayValue = [ArrayConverter getArrayValueWithValue:value propertyName:propertyInfo.propertyName forObject:self block:^NSDictionary * _Nonnull(long long rowId, Class  _Nonnull __unsafe_unretained clazz) {
                    return [self getDictionaryRecordWithRowId:@(rowId) class:clazz];
                }];
                [associationDictionaryRecord setValue:arrayValue forKeyPath:propertyInfo.propertyName];
            } else if ([propertyInfo.propertyClass isKindOfClass:object_getClass([NSDictionary class])]) {
                NSDictionary *dictionary = [value mj_JSONObject];
                [associationDictionaryRecord setValue:dictionary forKeyPath:propertyInfo.propertyName];
            }
        }];
        
        [associationDictionaryRecords addObject:associationDictionaryRecord];
    }
    
    return associationDictionaryRecords;
}

- (NSDictionary *)getDictionaryRecordWithRowId:(NSNumber *)rowId class:(Class)class
{
    Record *record = [[class alloc] init];
    [record setWhere:@{ROW_ID : rowId}];
    NSArray<NSDictionary *> *dictionaryRecords = [record queryDictionary];
    
    NSArray<NSDictionary *> *associationDictionaryRecords = [record getAssociationDictionaryRecordsWithArray:dictionaryRecords];

    return [associationDictionaryRecords firstObject];
}

@end
