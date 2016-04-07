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

void registerColumnConstraints(NSString *tableName, NSDictionary *columnConstraints); //注册columnConstraints
void registerColumnIndexes(NSString *tableName, NSDictionary *columnIndex); //注册columnIndex

+ (instancetype)sharedInstance;

- (NSDictionary<NSString*, NSDictionary*> *)getColumnConstraintsForTableName:(NSString *)tableName;

- (NSDictionary<NSString*, NSDictionary*> *)getColumnIndexesForTableName:(NSString *)tableName;

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
