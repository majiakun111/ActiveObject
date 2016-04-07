//
//  DatabaseDAO.h
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "DatabaseMigrator.h"

@interface DatabaseDAO : NSObject

@property (nonatomic, strong) Database *database;

@property (nonatomic, strong) DatabaseMigrator *databaseMigrator;

void registerConstraints(NSString *tableName, NSDictionary *constraints); //注册constraints
void registerIndexes(NSString *tableName, NSDictionary *indexes); //注册indexes

+ (instancetype)sharedInstance;

- (NSDictionary<NSString*, NSDictionary*> *)getConstraintsForTableName:(NSString *)tableName;

- (NSDictionary<NSString*, NSDictionary*> *)getIndexesForTableName:(NSString *)tableName;

- (void)configDatabasePath:(NSString*)databasePath;

- (void)configDatabasePath:(NSString*)databasePath flags:(int)flags;

- (void)configDatabasePath:(NSString*)databasePath databaseVersion:(NSString *)databaseVersion;

/**
 * databasePath : database path
 * flags:  database permission
 * databaseVersion : database version,
 */
- (void)configDatabasePath:(NSString*)databasePath flags:(int)flags databaseVersion:(NSString *)databaseVersion;

- (BOOL)executeUpdate:(NSString*)sql;

//select
- (NSArray<NSDictionary *> *)executeQuery:(NSString*)sql;

@end
