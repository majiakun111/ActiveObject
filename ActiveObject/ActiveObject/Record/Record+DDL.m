//
//  Record+DDL.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "Record+DDL.h"
#import "DatabaseDAO.h"
#import "DatabaseDAO+DDL.h"
#import "Record+Additions.h"
#import "PropertyAnalyzer.h"

@implementation Record (DDL)

- (BOOL)createTable
{
    return [[DatabaseDAO sharedInstance] createTable:[self tableName] constraints:[[self class] constraints] indexes:[[self class] indexes] forClass:[self class] untilRootClass:[Record class]];
}

- (BOOL)dropTable
{
    BOOL result = YES;
    NSArray<NSString *> *propertyList = [self getColumns];
    NSArray *valueList = [PropertyAnalyzer getPropertyValueListWithPropertyList:propertyList forRecord:self];
    
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

    return [[DatabaseDAO sharedInstance] dropTable:[self tableName]];
}

- (BOOL)createIndex:(NSString *)indexName onColumn:(id)column isUnique:(BOOL )isUnique
{
    return [[DatabaseDAO sharedInstance] createIndex:indexName onColumn:column isUnique:isUnique forTable:[self tableName]];
}

- (BOOL)dropIndex:(NSString *)indexName
{
    return [[DatabaseDAO sharedInstance] dropIndex:indexName];
}

- (BOOL)renameTable:(NSString *)tableName toTableNewName:(NSString *)tableNewName
{
    return [[DatabaseDAO sharedInstance] renameTable:tableName toTableNewName:tableNewName];
}

- (BOOL)addColumn:(NSString *)column type:(NSString *)type
{
    return [self addColumn:column type:type constraint:nil];
}

- (BOOL)addColumn:(NSString *)column type:(NSString *)type constraint:(NSString *)constraint
{
    return [[DatabaseDAO sharedInstance] addColumn:column type:type constraint:constraint forTable:[self tableName]];
}

@end
