//
//  Record+DML.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record+DML.h"
#import "DatabaseDAO.h"
#import "DatabaseDAO+Additions.h"
#import "Record+Additions.h"
#import "NSObject+Record.h"
#import "Record+Condition.h"

@implementation Record (DML)

- (BOOL)save
{
    BOOL result = YES;
    
    [self saveBefore];
    
    result = [self insert];
    
    [self saveAfter];
    
    return result;
}

- (BOOL)delete
{
    [self deleteAllBefore];
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ %@", [self tableName], self.where];

    BOOL result = [[DatabaseDAO sharedInstance] executeUpdate:sql];
    
    [self deleteAfter];
    
    return result;
}
+ (BOOL)deleteAll
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@", [self tableName]];
    return [[DatabaseDAO sharedInstance] executeUpdate:sql];
}

- (BOOL)update
{
    [self updateBefore];
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ %@", [self tableName], self.updateField, self.where];
    BOOL result = [[DatabaseDAO sharedInstance] executeUpdate:sql];

    [self updateAfter];
    
    return result;
}

#pragma mark - Hook Method

- (void)saveBefore{}

- (void)saveAfter{}

- (void)deleteBefore{}

- (void)deleteAfter{}

- (void)deleteAllBefore{}

- (void)deleteAllAfter{}

- (void)updateBefore{}

- (void)updateAfter{}

#pragma mark - PrivateMethod

- (BOOL)insert
{
    NSArray *propertyList = [self getColumns];
    NSArray *valueList = [self getValueListWithPropertyList:propertyList];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"replace into %@ (%@) values (", [self tableName], [propertyList componentsJoinedByString:@", "]];
    
    NSInteger count = [valueList count];
    for (NSInteger index = 0; index < count; index++) {
        id value = valueList[index];
        
        if ([value isKindOfClass:[Record class]]) {
            [value insert];
            
            long long lastRowId = [[DatabaseDAO sharedInstance] lastInsertRowId];
            [sql appendFormat:@"'%lld'", lastRowId];
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *rowIds = [NSMutableArray array];
            for (Record *record in value) {
                BOOL result =  [record insert];
                if (result) {
                    long long rowId = [[DatabaseDAO sharedInstance] lastInsertRowId];
                    [rowIds addObject: @(rowId)];
                }
            }
            
            [sql appendFormat:@"'%@'", [rowIds componentsJoinedByString:@","]];
        } else {
            [sql appendFormat:@"'%@'", value];
        }
        
        if (index == count - 1) {
            [sql appendString:@")"];
        } else {
            [sql appendString:@", "];
        }
    }
    
    return [[DatabaseDAO sharedInstance] executeUpdate:sql];
}

@end
