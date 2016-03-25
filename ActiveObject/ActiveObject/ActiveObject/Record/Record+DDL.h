//
//  Record+DDL.h
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record.h"

/**
 * DDL contian create table, drop table, create index, drop index, alter table,
 */

@interface Record (DDL)

- (BOOL)createTable;

- (BOOL)dropTable;

/**
 * 若是单列 就传字符串 多列传数组
 */
- (BOOL)createIndex:(NSString *)indexName onColumn:(id)column isUnique:(BOOL )isUnique;

- (BOOL)dropIndex:(NSString *)indexName;

//就这么设计
- (BOOL)renameTable:(NSString *)tableName toTableNewName:(NSString *)tableNewName;

- (BOOL)addColumn:(NSString *)column type:(NSString *)type;

/**
* constraint :
* eg.  1. default 0; 2. check (age >= 0);
*
*/
- (BOOL)addColumn:(NSString *)column type:(NSString *)type constraint:(NSString *)constraint;

@end
