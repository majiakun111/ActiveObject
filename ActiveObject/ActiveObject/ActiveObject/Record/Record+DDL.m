//
//  Record+DDL.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record+DDL.h"
#import "DatabaseDAO.h"
#import "DatabaseDAO+DDL.h"

@implementation Record (DDL)

- (BOOL)createTable
{    
    return [[DatabaseDAO sharedInstance] createTable:[self tableName] forClass:[self class]];
}

- (BOOL)dropTable
{
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
