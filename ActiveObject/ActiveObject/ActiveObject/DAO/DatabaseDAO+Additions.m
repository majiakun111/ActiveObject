//
//  DatabaseDAO+Additions.m
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseDAO+Additions.h"
#import "Database+Additions.h"
#import "ActiveObjectDefine.h"

@implementation DatabaseDAO (Additions)

- (long long)lastInsertRowId
{
    return [self.database lastInsertRowId];
}

- (NSArray<NSDictionary *> *)getTableInfoForTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"pragma table_info('%@')" , tableName];
    NSArray <NSDictionary *> *tableInfo = [[DatabaseDAO sharedInstance] executeQuery:sql];
    
    return tableInfo;
}

- (NSArray<NSString *> *)getColumnsForTableName:(NSString *)tableName
{
    NSArray<NSDictionary *> *tableInfo = [self getTableInfoForTable:tableName];
    
    NSMutableArray <NSString *> *columns = [[NSMutableArray alloc] init];
    for (NSDictionary *columnInfo in tableInfo) {
        NSString *columnName = columnInfo[@"name"];
        [columns addObject:columnName];
    }
    
    //remove rowId
    [columns removeObject:ROW_ID];
    
    return columns;
}

- (NSArray<NSString *> *)getAllTableName
{
    NSString *sql = @"select tbl_name from sqlite_master where type = 'table'";
    NSArray<NSDictionary *> *sqliteMasterInfos = [[DatabaseDAO sharedInstance] executeQuery:sql];

    NSMutableArray<NSString *> *tableNames = [[NSMutableArray alloc] init];
    for (NSDictionary *sqliteMasterInfo in sqliteMasterInfos) {
        if ([sqliteMasterInfo[@"tbl_name"] isEqualToString:@"sqlite_sequence"]) {
            continue;
        }
        
        [tableNames addObject:sqliteMasterInfo[@"tbl_name"]];
    }
    
    return tableNames;
}

- (NSDictionary<NSString*, NSDictionary*> *)getColumnIndexesFromSqliteMasterForTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"select name, sql from sqlite_master where type = 'index' and tbl_name = '%@'", tableName];
    NSArray<NSDictionary *> *indexInfos = [[DatabaseDAO sharedInstance] executeQuery:sql];
    
    NSMutableDictionary<NSString*, NSDictionary*> *columnIndex = [NSMutableDictionary dictionary];
    
    for (NSDictionary *indexInfo in indexInfos) {
        NSString *indexName = indexInfo[@"name"];
        
        NSString *sql = indexInfo[@"sql"];
        
        NSRange uniqueRange = [sql rangeOfString:@" unique " options:NSCaseInsensitiveSearch];
        BOOL isUnique = NO;
        if (uniqueRange.location != NSNotFound) {
            isUnique = YES;
        }
        
        NSString *columnString = @"";
        NSRange beforeBracket = [sql rangeOfString:@"(" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [sql length])];
        
        NSRange afterBracket = [sql rangeOfString:@")" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [sql length])];
        
        if (afterBracket.location != NSNotFound && afterBracket.location > beforeBracket.location) {
            columnString = [sql substringWithRange:NSMakeRange(beforeBracket.location+1, afterBracket.location - (beforeBracket.location+1))];
            
            [columnIndex setObject:@{INDEX_NAME : indexName, IS_UNIQUE : @(isUnique)} forKey:columnString];
        }
        
    }
    
    return columnIndex;
}

- (BOOL)setKey:(NSString*)key
{
    return [self.database setKey:key];
}

- (BOOL)resetKey:(NSString*)key
{
    return [self.database resetKey:key];
}

@end
