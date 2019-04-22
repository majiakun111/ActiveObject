//
//  Database.h
//  Database
//
//  Created by Ansel on 16/3/21.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Database : NSObject
{
    sqlite3 *_db;
}

- (instancetype)initWithDatabasePath:(NSString *)databasePath;

- (BOOL)open;

- (BOOL)openWithFlags:(int)flags;

- (BOOL)close;

//create table, drop table, alter table, insert into, delete, replace, update, transaction
- (BOOL)executeUpdate:(NSString*)sql;

//select
- (NSArray<NSDictionary *> *)executeQuery:(NSString*)sql;

@end
