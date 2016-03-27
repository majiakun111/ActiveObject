//
//  DatabaseDAO+DDL.h
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseDAO.h"

@interface DatabaseDAO (DDL)

- (BOOL)createTable:(NSString *)tableName forClass:(Class)class untilRootClass:(Class)rootClass columnConstraints:(NSDictionary *)columnConstraints;

- (BOOL)dropTable:(NSString *)tableName;

/**
 * 若是单列 就传字符串 多列传数组
 */
- (BOOL)createIndex:(NSString *)indexName onColumn:(id)column isUnique:(BOOL )isUnique forTable:(NSString *)tableName;

- (BOOL)dropIndex:(NSString *)indexName;

- (BOOL)renameTable:(NSString *)tableName toTableNewName:(NSString *)tableNewName;

/**
 * constraint :
 * eg.  1. default 0; 2. check (age >= 0);
 *
 */
- (BOOL)addColumn:(NSString *)column type:(NSString *)type constraint:(NSString *)constraint forTable:(NSString *)tableName;

@end
