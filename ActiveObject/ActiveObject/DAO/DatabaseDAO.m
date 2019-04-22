//
//  DatabaseDAO.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "DatabaseDAO.h"
#import "DatabaseAutoMigrator.h"

#define DEFAULT_DATABASE_NAME  @"Ansel.db"

@interface DatabaseDAO ()

@property (nonatomic, copy) NSString *databasePath;
@property (nonatomic, assign) int flags;
@property (nonatomic, copy) NSString *databaseVersion;
@property (nonatomic, strong) DatabaseAutoMigrator *databaseAutoMigrator;

@end

@implementation DatabaseDAO

+ (instancetype)sharedInstance
{
    static DatabaseDAO *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == instance) {
            instance = [[DatabaseDAO alloc] init];
        }
    });
    
    return instance;
}

#pragma mark - Config

- (void)configDatabasePath:(NSString*)databasePath
{
    [self configDatabasePath:databasePath flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE];
}

- (void)configDatabasePath:(NSString*)databasePath flags:(int)flags
{
    [self configDatabasePath:databasePath flags:flags databaseVersion:nil];
}

- (void)configDatabasePath:(NSString*)databasePath databaseVersion:(NSString *)databaseVersion
{
    [self configDatabasePath:databasePath flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE databaseVersion:databaseVersion];
}

- (void)configDatabasePath:(NSString*)databasePath flags:(int)flags databaseVersion:(NSString *)databaseVersion
{
    self.databasePath = databasePath;
    self.flags = flags;
    self.databaseVersion = databaseVersion;
}

#pragma mark - Exectue

- (BOOL)executeUpdate:(NSString*)sql
{
    return [self.database executeUpdate:sql];
}

//select
- (NSArray<NSDictionary *> *)executeQuery:(NSString*)sql
{
    return [self.database executeQuery:sql];
}

#pragma mark - property

- (Database *)database
{
    if (nil == _database) {
        
        if (!self.databasePath) {
            [self configDefaultParameter];
        }
        
        _database = [[Database alloc] initWithDatabasePath:self.databasePath];
        [_database openWithFlags:self.flags];
        
        [self executeDatabaseMigrator];
    }
    
    return _database;
}

- (DatabaseAutoMigrator *)databaseAutoMigrator
{
    if (nil == _databaseAutoMigrator) {
        _databaseAutoMigrator = [[DatabaseAutoMigrator alloc] init];
    }
    
    return _databaseAutoMigrator;
}

#pragma mark - PrivateMethod

- (void)configDefaultParameter
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _databasePath = [documentDirectory stringByAppendingPathComponent:DEFAULT_DATABASE_NAME];
    _flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;
}

- (void)executeDatabaseMigrator
{
    if (!self.databaseMigrator) {
        return;
    }
    
    NSString *currentDatabaseVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"DatabaseVersion"];
    if (!currentDatabaseVersion) {
        [[NSUserDefaults standardUserDefaults] setObject:self.databaseVersion forKey:@"DatabaseVersion"];
        return;
    }
    
    if ([currentDatabaseVersion compare:self.databaseVersion options:NSCaseInsensitiveSearch] != NSOrderedAscending) {
        return;
    }
    
    BOOL result =  [self.databaseMigrator executeMigrateForDatabase:self.database currentDatabaseVersion:currentDatabaseVersion];
    if (!result) {
        return;
    }
    
    result = [self.databaseAutoMigrator autoExecuteMigrate];
    if (!result) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.databaseVersion forKey:@"DatabaseVersion"];
}

@end
