//
//  DatabaseDAO.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseDAO.h"
#import "DatabaseDAO+Additions.h"
#import "DatabaseDAO+DDL.h"
#import "NSObject+Record.h"
#import "ActiveObjectDefine.h"

// column add or delete, index add and delete
@interface DatabaseAutoMigrator : NSObject

- (BOOL)autoExecuteMigrate;

@end


@implementation DatabaseAutoMigrator

- (BOOL)autoExecuteMigrate
{
    NSArray<NSString *> *tableNames = [[DatabaseDAO sharedInstance] getAllTableName];
    
    BOOL result = YES;
    for (NSString *tableName in tableNames) {
        result = [self executeColumnMigrateForTable:tableName];
        if (!result) {
            break;
        }
        
        result = [self executeIndexesMigrateForTable:tableName];
        if (!result) {
            break;
        }
    }
    
    return result;
}

#pragma mark - PrivateMethod

- (BOOL)executeColumnMigrateForTable:(NSString *)tableName
{
    Class class = NSClassFromString(tableName);
    NSArray *propertyInfoList = [class getPropertyInfoList];
    
    NSArray *columns = [[DatabaseDAO sharedInstance] getColumnsForTableName:tableName];
    
    NSMutableArray<NSDictionary *> *addColumns = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *deleteAfterColumns = [[NSMutableArray alloc] init];
    
    for (NSDictionary *propertyInfo in propertyInfoList) {
        if (![columns containsObject:propertyInfo[PROPERTY_NAME]]) {
            [addColumns addObject:propertyInfo];
        }
    }
    
    for (NSString *column in columns) {
        __block BOOL isContian = NO;
       [propertyInfoList enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull propertyInfo, NSUInteger idx, BOOL * _Nonnull stop) {
           if ([propertyInfo[PROPERTY_NAME] isEqualToString:column]) {
               *stop = YES;
               isContian = YES;
           }
       }];
        
        if (isContian) {
            [deleteAfterColumns addObject:column];
        }
    }

    BOOL result = YES;
    do {
        if ([deleteAfterColumns count] != [columns count]) {
            result = [self executeDeleteColumnsWithDeleteAfterColumns:deleteAfterColumns forTable:tableName];
            
            if (!result) {
                break;
            }
        }
        
        if ([addColumns count] > 0) {
            result = [self executeAddColumns:addColumns forTable:tableName];
            
            if (!result) {
                break;
            }
        }
    } while (0);
    
    return result;
}

- (BOOL)executeAddColumns:(NSArray<NSDictionary *> *)columns forTable:(NSString *)tableName
{
    BOOL result = YES;
    NSDictionary *columnContraints = [[DatabaseDAO sharedInstance] getConstraintsForTableName:tableName];
    for (NSDictionary *propertyInfo in columns) {
        NSString *columnName = propertyInfo[PROPERTY_NAME];
        
        result = [[DatabaseDAO sharedInstance] addColumn:propertyInfo[PROPERTY_NAME] type:propertyInfo[PROPERTY_TYPE] constraint:columnContraints[columnName] forTable:tableName];
        
        if (!result) {
            break;
        }
    }
    
    return result;
}

- (BOOL)executeDeleteColumnsWithDeleteAfterColumns:(NSArray *)deleteAfterColumns forTable:(NSString *)tableName
{
    NSString *tmpTableName = [NSString stringWithFormat:@"tmp%@", tableName];
    [[DatabaseDAO sharedInstance] renameTable:tableName toTableNewName:tmpTableName];
    
    Class class = NSClassFromString(tableName);
    [[DatabaseDAO sharedInstance] createTable:tableName forClass:class];
    
    NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"insert into Person(%@) select %@ from %@", [deleteAfterColumns componentsJoinedByString:@", "], [deleteAfterColumns componentsJoinedByString:@", "], tmpTableName];
    
    [[DatabaseDAO sharedInstance] executeUpdate:sql];
    
    [[DatabaseDAO sharedInstance] dropTable:tmpTableName];
    
    return YES;
}

- (BOOL)executeIndexesMigrateForTable:(NSString *)tableName
{
    NSDictionary<NSString*, NSDictionary*> *sqliteMasteIndexes = [[DatabaseDAO sharedInstance] getIndexesFromSqliteMasterForTable:tableName];

    NSDictionary<NSString*, NSDictionary*> *indexes = [[DatabaseDAO sharedInstance] getIndexesForTableName:tableName];
    
    
    NSMutableDictionary<NSString*, NSDictionary*> *addIndexes = [NSMutableDictionary dictionary];
    NSMutableArray *deleteIndexNames = [[NSMutableArray alloc] init];
    
    NSArray *currentColumns = [sqliteMasteIndexes allKeys];
    NSArray *columns = [indexes allKeys];

    for (NSString *columnName in columns) {
        if (![currentColumns containsObject:columnName]) {
            [addIndexes setObject:indexes[columnName] forKey:columnName];
        }
    }
    
    for (NSString *columnName in currentColumns) {
        if (![columns containsObject:columnName]) {
            [deleteIndexNames addObject:sqliteMasteIndexes[columnName][INDEX_NAME]];
        }
    }
    
    BOOL result = YES;
    do {
        if ([deleteIndexNames count] > 0) {
            result = [self executeDropIndexesWithIndexNames:deleteIndexNames];
            
            if (!result) {
                break;
            }
        }
        
        if ([addIndexes count] > 0) {
            result = [self executeAddIndexesWithColumnIndexes:addIndexes forTable:tableName];
            
            if (!result) {
                break;
            }
        }
    } while (0);
    
    return result;
}

- (BOOL)executeAddIndexesWithColumnIndexes:(NSDictionary<NSString*, NSDictionary*> *)columnIndexes forTable:(NSString *)tableName
{
    BOOL result = YES;
    for (NSString *columnName in columnIndexes) {
        NSDictionary *columnIndex = columnIndexes[columnName];
        
        result = [[DatabaseDAO sharedInstance] createIndex:columnIndex[INDEX_NAME] onColumn:columnName isUnique:[columnIndex[IS_UNIQUE] boolValue] forTable:tableName];
        
        if (!result) {
            break;
        }
    }
    
    return result;
}

- (BOOL)executeDropIndexesWithIndexNames:(NSArray *)indexNames
{
    BOOL result = YES;
    for (NSString *indexName in indexNames) {
        result = [[DatabaseDAO sharedInstance] dropIndex:indexName];
        if (!result) {
            break;
        }
    }
    
    return result;
}

@end


#define DEFAULT_DATABASE_NAME  @"Ansel.db"

@interface DatabaseDAO ()

@property (nonatomic, copy) NSString *databasePath;
@property (nonatomic, assign) int flags;
@property (nonatomic, copy) NSString *databaseVersion;
@property (nonatomic, strong) DatabaseAutoMigrator *databaseAutoMigrator;

@end

@implementation DatabaseDAO

static NSMutableDictionary<NSString*, NSDictionary*> *g_constraintsMap;
static NSMutableDictionary<NSString*, NSDictionary*> *g_indexesMap;

void registerConstraints(NSString *tableName, NSDictionary *constraints)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_constraintsMap = [[NSMutableDictionary alloc] init];
    });
    
    if (!constraints || !tableName) {
        return;
    }
    
    [g_constraintsMap setObject:constraints forKey:tableName];
}

void registerIndexes(NSString *tableName, NSDictionary *indexes)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_indexesMap = [[NSMutableDictionary alloc] init];
    });
    
    if (!indexes || !tableName) {
        return;
    }
    
    [g_indexesMap setObject:indexes forKey:tableName];
}

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

#pragma mark - get columnConstraints and columnIndex

- (NSDictionary<NSString*, NSDictionary*> *)getConstraintsForTableName:(NSString *)tableName
{
    return [g_constraintsMap objectForKey:tableName];
}

- (NSDictionary<NSString*, NSDictionary*> *)getIndexesForTableName:(NSString *)tableName;
{
    return [g_indexesMap objectForKey:tableName];
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
    
    BOOL result = [self.databaseAutoMigrator autoExecuteMigrate];
    if (!result) {
        return;
    }
    
    result =  [self.databaseMigrator executeMigrateForDatabase:self.database currentDatabaseVersion:currentDatabaseVersion];
    if (!result) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.databaseVersion forKey:@"DatabaseVersion"];
}

@end
