//
//  Record+DQL.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record+DQL.h"
#import "DatabaseDAO.h"
#import "Record+Additions.h"
#import "Record+Condition.h"
#import "NSObject+Record.h"
#import "NSString+JSON.h"
#import "RecordDefine.h"

@implementation Record (DQL)

- (NSArray <__kindof Record *> *)query
{
    NSString *sql = nil;
    NSString *field = [self.field stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([field isEqual:@"*"]) {
        NSArray *columns = [self getColumns];
        sql = [NSString stringWithFormat:@"select %@ from %@ %@ %@ %@", [columns componentsJoinedByString:@", "], [self tableName], self.where, self.orderBy, self.limit];
    }
    else {
        sql = [NSString stringWithFormat:@"select %@ from %@ %@ %@ %@", self.field, [self tableName], self.where, self.orderBy, self.limit];
    }
    
    return [self queryWithSql:sql];
}

- (NSArray <__kindof Record *> *)queryAll
{
    NSArray *columns = [self getColumns];
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@", [columns componentsJoinedByString:@", "], [self tableName]];

    return [self queryWithSql:sql];
}

- (NSArray <NSDictionary *> *)queryDictionary
{
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@ %@ %@ %@ %@ %@",self.field, [self tableName], self.where, self.groupBy, self.having, self.orderBy, self.limit];
    
    NSArray<NSDictionary *> *results = [[DatabaseDAO sharedInstance] executeQuery:sql];
    
    return results;
}

#pragma mark - PrivateMethod

- (NSArray <__kindof Record *> *)queryWithSql:(NSString *)sql
{
    NSArray <NSMutableDictionary *> *results = (NSArray <NSMutableDictionary *> *)[[DatabaseDAO sharedInstance] executeQuery:sql];
    
    NSArray <Record *> *records = [self getModelsfromArray:results];
    
    return records;
}

- (NSArray <Record *> *)getModelsfromArray:(NSArray <NSDictionary *> *)array
{
    if (!array) {
        return nil;
    }
    
    NSArray *propertyInfoList = [self getPropertyInfoListUntilRootClass:[Record class]];
    NSMutableArray <Record *> *records = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dictionary in array) {
        Record *record = [[[self class] alloc] init];
        
        [propertyInfoList enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull propertyInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *propertyName = propertyInfo[PROPERTY_NAME];
            NSString *propertyType = propertyInfo[PROPERTY_TYPE];
            if ([NSClassFromString(propertyType) isSubclassOfClass:[Record class]]) {
                
                NSNumber *rowId = dictionary[propertyName];
                
                Record *rd = [[NSClassFromString(propertyType) alloc] init];
                [rd setWhere:@{ROW_ID : rowId}];
                NSArray<Record *> *result = [rd query];
                
                [record setValue:[result firstObject] forKeyPath:propertyName];
                
            } else if ([propertyType isEqual:@"NSArray"]) {
                
                NSString *value = dictionary[propertyName];
                
                Class class = [self getArrayTransformerModelClassWithKeyPath:propertyName];
                if (class && [class isSubclassOfClass:[Record class]]) {
                    
                    NSArray *rowIds = [value componentsSeparatedByString:@","];
                    NSMutableArray *rds = [[NSMutableArray alloc] init];
                    for (NSString *rowId in rowIds) {
                        Record *rd = [[class alloc] init];
                        [rd setWhere:@{ROW_ID : @([rowId longLongValue])}];
                        
                        NSArray<Record *> *result = [rd query];
                        [rds addObject:[result firstObject]];
                    }
                    
                    [record setValue:rds forKeyPath:propertyName];
                    
                }
                else {
                    
                    NSString *value = dictionary[propertyName];
                    id JSONObject = [value JSONObject];
                    
                    [record setValue:JSONObject forKeyPath:propertyName];
                    
                }
                
            } else if ([propertyType isEqual:@"NSDictionary"]) {
                NSString *value = dictionary[propertyName];
                id JSONObject = [value JSONObject];
                [record setValue:JSONObject forKeyPath:propertyName];
            } else {
                [record setValue:dictionary[propertyName] forKeyPath:propertyName];
            }
        }];
        
        [records addObject:record];
    }
    
    return records;
}

@end
