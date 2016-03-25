//
//  DatabaseDAO.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseDAO.h"

#define DEFAULT_DATABASE_NAME  @"Ansel.db"

@interface DatabaseDAO ()

@property (nonatomic, copy) NSString *databasePath;
@property (nonatomic, assign) int flags;

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

- (void)configDatabasePath:(NSString*)databasePath
{
    [self configDatabasePath:databasePath flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE];
}

- (void)configDatabasePath:(NSString*)databasePath flags:(int)flags
{
    self.databasePath = databasePath;
    self.flags = flags;
}

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
    }
    
    return _database;
}

#pragma mark - PrivateMethod

- (void)configDefaultParameter
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _databasePath = [documentDirectory stringByAppendingPathComponent:DEFAULT_DATABASE_NAME];
    _flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;
}

@end
