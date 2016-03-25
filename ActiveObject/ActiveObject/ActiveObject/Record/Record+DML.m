//
//  Record+DML.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record+DML.h"
#import "DatabaseDAO.h"
#import "DatabaseDAO+DML.h"
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
    [self deleteBefore];
    
    BOOL result = [[DatabaseDAO sharedInstance] deleteWithWhere:self.where forTable:[self tableName]];
    
    [self deleteAfter];
    
    return result;
}

- (BOOL)deleteAll
{
    [self deleteAllBefore];
    
    BOOL result = [[DatabaseDAO sharedInstance] deleteAllForTable:[self tableName]];
    
    [self deleteAllAfter];
    
    return result;
}

- (BOOL)update
{
    [self updateBefore];
    
    BOOL result = [[DatabaseDAO sharedInstance] updateWithUpdateField:self.updateField where:self.where forTable:[self tableName]];

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
    
    NSMutableString *valuesSql = [NSMutableString string];
    NSInteger count = [valueList count];
    for (NSInteger index = 0; index < count; index++) {
        id value = valueList[index];
        
        if ([value isKindOfClass:[Record class]]) {
            [value save];
            
            long long lastRowId = [[DatabaseDAO sharedInstance] lastInsertRowId];
            [valuesSql appendFormat:@"'%lld'", lastRowId];
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *rowIds = [NSMutableArray array];
            for (Record *record in value) {
                BOOL result =  [record save];
                if (result) {
                    long long rowId = [[DatabaseDAO sharedInstance] lastInsertRowId];
                    [rowIds addObject: @(rowId)];
                }
            }
            
            [valuesSql appendFormat:@"'%@'", [rowIds componentsJoinedByString:@","]];
        } else {
            [valuesSql appendFormat:@"'%@'", value];
        }
        
        if (index != count - 1) {
            [valuesSql appendString:@", "];
        }
    }
    
    return [[DatabaseDAO sharedInstance] insertWithFields:[propertyList componentsJoinedByString:@", "] values:valuesSql forTable:[self tableName]];
}

@end
