//
//  DatabaseAutoMigrator.m
//  ActiveObject
//
//  Created by Ansel on 16/4/8.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseAutoMigrator.h"
#import "ActiveObjectDefine.h"
#import "DatabaseDAO+DDL.h"
#import "DatabaseDAO+Additions.h"
#import "NSObject+Record.h"
#import "Record+DDL.h"
#import "Record.h"

@implementation DatabaseAutoMigrator

- (BOOL)autoExecuteMigrate
{
    NSArray<NSString *> *tableNames = [[DatabaseDAO sharedInstance] getAllTableName];
    
    BOOL result = YES;
    for (NSString *tableName in tableNames) {
        result = [self executeColumnMigrateForTable:tableName];
        if (!result) {
            break;
        }
        
        result = [self executeIndexesMigrateForTable:tableName];
        if (!result) {
            break;
        }
    }
    
    return result;
}

#pragma mark - PrivateMethod

- (BOOL)executeColumnMigrateForTable:(NSString *)tableName
{
    Class class = NSClassFromString(tableName);
    NSArray *propertyInfoList = [class getPropertyInfoList];
    
    NSArray *columns = [[DatabaseDAO sharedInstance] getColumnsForTableName:tableName];
    
    NSMutableArray<NSDictionary *> *addColumns = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *deleteAfterColumns = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *needDeleteColumns = [[NSMutableArray alloc] init];

    for (NSDictionary *propertyInfo in propertyInfoList) {
        if (![columns containsObject:propertyInfo[PROPERTY_NAME]]) {
            [addColumns addObject:propertyInfo];
        }
    }
    
    for (NSString *column in columns) {
        __block BOOL isContian = NO;
        [propertyInfoList enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull propertyInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([propertyInfo[PROPERTY_NAME] isEqualToString:column]) {
                *stop = YES;
                isContian = YES;
            }
        }];
        
        if (isContian) {
            [deleteAfterColumns addObject:column];
        } else {
            [needDeleteColumns addObject:column];
        }
    }
    
    BOOL result = YES;
    do {
        if ([deleteAfterColumns count] != [columns count]) {
            result = [self executeDeleteColumnsWithDeleteAfterColumns:deleteAfterColumns needDeleteColumns:needDeleteColumns forTable:tableName];
            
            if (!result) {
                break;
            }
        }
        
        if ([addColumns count] > 0) {
            result = [self executeAddColumns:addColumns forTable:tableName];
            
            if (!result) {
                break;
            }
        }
    } while (0);
    
    return result;
}

- (BOOL)executeAddColumns:(NSArray<NSDictionary *> *)columns forTable:(NSString *)tableName
{
    BOOL result = YES;
    
    Class class = NSClassFromString(tableName);
    NSDictionary<NSString*, NSString*> *contraints = [class constraints];
    for (NSDictionary *propertyInfo in columns) {
        NSString *columnName = propertyInfo[PROPERTY_NAME];
        
        result = [[DatabaseDAO sharedInstance] addColumn:propertyInfo[PROPERTY_NAME] type:propertyInfo[PROPERTY_TYPE] constraint:contraints[columnName] forTable:tableName];
        
        if (!result) {
            break;
        }
    }
    
    return result;
}

- (BOOL)executeDeleteColumnsWithDeleteAfterColumns:(NSArray<NSString *> *)deleteAfterColumns needDeleteColumns:(NSArray<NSString *> *)needDeleteColumns forTable:(NSString *)tableName
{
    BOOL result = YES;
    
    //若删除的column 对应 table 该表也应该删除
    NSArray *valueList = [self getValueListWithPropertyList:needDeleteColumns];
    for (id value in valueList) {
        if ([value isKindOfClass:[Record class]]) {
            result = [(Record *)value dropTable];
            if (!result) {
                return result;
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            Record *record = [value firstObject];
            result = [record dropTable];
            if (!result) {
                return result;
            }
        }
    }
    
    NSString *tmpTableName = [NSString stringWithFormat:@"tmp%@", tableName];
    result = [[DatabaseDAO sharedInstance] renameTable:tableName toTableNewName:tmpTableName];
    if (!result) {
        return result;
    }
    
    Class class = NSClassFromString(tableName);
    result = [[DatabaseDAO sharedInstance] createTable:tableName constraints:[class constraints] indexes:[class indexes] forClass:class];
    if (!result) {
        return result;
    }
    
    NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"insert into Person(%@) select %@ from %@", [deleteAfterColumns componentsJoinedByString:@", "], [deleteAfterColumns componentsJoinedByString:@", "], tmpTableName];
    
    result = [[DatabaseDAO sharedInstance] executeUpdate:sql];
    if (!result) {
        return result;
    }
    
    result = [[DatabaseDAO sharedInstance] dropTable:tmpTableName];
    
    return result;
}

- (BOOL)executeIndexesMigrateForTable:(NSString *)tableName
{
    NSDictionary<NSString*, NSDictionary*> *sqliteMasteIndexes = [[DatabaseDAO sharedInstance] getIndexesFromSqliteMasterForTable:tableName];
    
    Class class = NSClassFromString(tableName);
    NSDictionary<NSString*, NSDictionary*> *indexes = [class indexes];
    
    NSMutableDictionary<NSString*, NSDictionary*> *addIndexes = [NSMutableDictionary dictionary];
    NSMutableArray<NSString *> *deleteIndexNames = [[NSMutableArray alloc] init];
    
    NSArray *currentColumns = [sqliteMasteIndexes allKeys];
    NSArray *columns = [indexes allKeys];
    
    for (NSString *columnName in columns) {
        if (![currentColumns containsObject:columnName]) {
            [addIndexes setObject:indexes[columnName] forKey:columnName];
        }
    }
    
    for (NSString *columnName in currentColumns) {
        if (![columns containsObject:columnName]) {
            [deleteIndexNames addObject:sqliteMasteIndexes[columnName][INDEX_NAME]];
        }
    }
    
    BOOL result = YES;
    do {
        if ([deleteIndexNames count] > 0) {
            result = [self executeDropIndexesWithIndexNames:deleteIndexNames];
            
            if (!result) {
                break;
            }
        }
        
        if ([addIndexes count] > 0) {
            result = [self executeAddIndexesWithColumnIndexes:addIndexes forTable:tableName];
            
            if (!result) {
                break;
            }
        }
    } while (0);
    
    return result;
}

- (BOOL)executeAddIndexesWithColumnIndexes:(NSDictionary<NSString*, NSDictionary*> *)columnIndexes forTable:(NSString *)tableName
{
    BOOL result = YES;
    for (NSString *columnName in columnIndexes) {
        NSDictionary *columnIndex = columnIndexes[columnName];
        
        result = [[DatabaseDAO sharedInstance] createIndex:columnIndex[INDEX_NAME] onColumn:columnName isUnique:[columnIndex[IS_UNIQUE] boolValue] forTable:tableName];
        
        if (!result) {
            break;
        }
    }
    
    return result;
}

- (BOOL)executeDropIndexesWithIndexNames:(NSArray<NSString *> *)indexNames
{
    BOOL result = YES;
    for (NSString *indexName in indexNames) {
        result = [[DatabaseDAO sharedInstance] dropIndex:indexName];
        if (!result) {
            break;
        }
    }
    
    return result;
}

@end
