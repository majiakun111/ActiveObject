//
//  Record+DML.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "Record+DML.h"
#import "ActiveObjectDefine.h"
#import "DatabaseDAO.h"
#import "DatabaseDAO+DML.h"
#import "DatabaseDAO+Additions.h"
#import "Record+Additions.h"
#import "Record+Condition.h"
#import "Record+Additions.h"
#import "Record+DDL.h"
#import "PropertyAnalyzer.h"

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
    
    BOOL result = YES;
    
    //删除关联的表对应的数据
    NSArray<NSString *> *propertyList = [self getColumns];
    NSArray *valueList = [PropertyAnalyzer getPropertyValueListWithPropertyList:propertyList forRecord:self];
    
    for (NSInteger index = 0; index < [valueList count]; index++) {
        id value = valueList[index];
        if ([value isKindOfClass:[Record class]]) {
            
            [(Record *)value setWhere:@{ROW_ID : @([(Record *)value rowId])}];
            result = [(Record *)value delete];
            if (!result) {
                return result;
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            for (Record *record in value) {
                [record setWhere:@{ROW_ID : @([record rowId])}];
                result = [record delete];
                if (!result) {
                    return result;
                }
            }
        }
    }
    
    result = [[DatabaseDAO sharedInstance] deleteWithWhere:self.where forTable:[self tableName]];
    
    [self deleteAfter];
    
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

- (void)updateBefore{}

- (void)updateAfter{}

#pragma mark - PrivateMethod

- (BOOL)insert
{
    NSArray<NSString *> *propertyList = [self getColumns];
    NSArray *valueList = [PropertyAnalyzer getPropertyValueListWithPropertyList:propertyList forRecord:self];
    
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
