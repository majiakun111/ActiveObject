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

@interface Converter : NSObject

+ (NSArray <Record *> *)modelsOfClass:(Class )classs fromArray:(NSArray <NSDictionary *> *)array;

@end

@implementation Converter

+ (NSArray <Record *> *)modelsOfClass:(Class )classs fromArray:(NSArray <NSDictionary *> *)array
{
    if (!array) {
        return nil;
    }
    
    NSMutableArray <Record *> *records = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in array) {
        Record *record = [[classs alloc] init];
        for (NSString *key in dictionary) {
            if ([key isEqual:@"rowId"]) { //remove primary key
                continue;
            }
            
            [record setValue:dictionary[key] forKeyPath:key];
        }
        
        [records addObject:record];
    }
    
    return records;
}

@end

@implementation Record (DQL)

- (NSArray <__kindof Record *> *)query
{
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@ %@ %@ %@", self.field, [self tableName], self.where, self.orderBy, self.limit];
    
    NSArray<NSDictionary *> *results = [[DatabaseDAO sharedInstance] executeQuery:sql];
    NSArray<Record *> *records = [Converter modelsOfClass:[self class] fromArray:results];
    
    return records;
}

- (NSArray <__kindof Record *> *)queryAll
{
    NSArray *columns = [self getColumns];
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@", [columns componentsJoinedByString:@", "], [self tableName]];

    NSArray <NSDictionary *> *results = [[DatabaseDAO sharedInstance] executeQuery:sql];
    
    NSArray <Record *> *records = [Converter modelsOfClass:[self class] fromArray:results];
    
    return records;
}

- (NSArray <NSDictionary *> *)queryDictionary
{
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@ %@ %@ %@ %@ %@",self.field, [self tableName], self.where, self.groupBy, self.having, self.orderBy, self.limit];
    
    NSArray<NSDictionary *> *results = [[DatabaseDAO sharedInstance] executeQuery:sql];
    
    return results;
}

@end
