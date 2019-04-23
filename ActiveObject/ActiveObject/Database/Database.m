//
//  Database.m
//  Database
//
//  Created by Ansel on 16/3/21.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "Database.h"

@interface Statement : NSObject

//sql
@property (atomic, copy) NSString *query;
@property (atomic, assign) void *statement;
@property (atomic, assign) BOOL inUse;
@property (atomic, assign) long useCount;

- (void)close;
- (void)reset;

@end

@implementation Statement

- (void)dealloc {
    [self close];
}

- (void)close {
    if (_statement) {
        sqlite3_finalize(_statement);
        _statement = 0x00;
    }
    
    _inUse = NO;
}

- (void)reset {
    if (_statement) {
        sqlite3_reset(_statement);
    }
    
    _inUse = NO;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ %ld hit(s) for query %@", [super description], _useCount, _query];
}

@end


@interface Database ()

@property(nonatomic, copy) NSString *databasePath;
@property(nonatomic, strong) NSMutableDictionary<NSString*,  NSMutableSet<Statement *>*> *cachedStatements;

@end

@implementation Database

- (void)dealloc
{
    [self clearCachedStatements];
}

- (instancetype)initWithDatabasePath:(NSString *)databasePath
{
    self = [super init];
    if (self) {
        self.databasePath = databasePath;
        _cachedStatements = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (BOOL)open
{
    return [self openWithFlags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE];
}

- (BOOL)close
{
    BOOL result = YES;
    
    int statusCode = sqlite3_close_v2(_db);
    if (statusCode != SQLITE_OK) {
        NSLog(@"close database failed for error: %d", statusCode);

        result = NO;
    }
    
    _db  = nil;
    
    return result;
}

- (BOOL)openWithFlags:(int)flags
{
    if (_db) {
        return YES;
    }
    
    BOOL result = YES;
    int statusCode = sqlite3_open_v2([self cdatabasePath], &_db, flags, NULL /* Name of VFS module to use */);
    if(statusCode != SQLITE_OK) {
        NSLog(@"open database failed for error: %d", statusCode);
        result = NO;
    }
    
    return result;
}

- (BOOL)executeUpdate:(NSString*)sql
{
    if (![self databaseIsOpen]) {
        return NO;
    }
    
    if ([sql length] <= 0) {
        NSLog(@"warning sql is empty");
    }
    
    BOOL result = YES;
    do {
        sqlite3_stmt *pStmt = 0x00;
        Statement *statement = 0x00;
        if (self.shouldCacheStatements) {
            statement = [self cachedStatementForQuery:sql];
            pStmt = statement ? [statement statement] : 0x00;
            [statement reset];
        }
    
        int statusCode = 0;
        if (!pStmt) {
            //1. 预处理SQL
            statusCode = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &pStmt, NULL);
            if (statusCode != SQLITE_OK) {
                [self printErrorMessageForMethod:@"sqlite3_prepare_v2" sql:sql];
                sqlite3_finalize(pStmt);
                result = NO;
                break;
            }
        }
        
        //2.执行SQL
        statusCode = sqlite3_step(pStmt);
        if (statusCode != SQLITE_DONE) {
            [self printErrorMessageForMethod:@"sqlite3_step" sql:sql];
            result = NO;
            break;
        }
        
        if (!statement && self.shouldCacheStatements) {
            statement = [[Statement alloc] init];
            [statement setStatement:pStmt];
            
            [self setCachedStatement:statement forQuery:sql];
        }
        [statement setUseCount:[statement useCount] + 1];
        [statement setInUse:YES];
    } while (0);
    
    return result;
}

- (NSArray<NSDictionary *> *)executeQuery:(NSString*)sql
{
    if (![self databaseIsOpen]) {
        return nil;
    }
    
    sqlite3_stmt *pStmt = NULL;
    //1. 预处理SQL
    int statusCode = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &pStmt, NULL);
    if (statusCode != SQLITE_OK) {
        [self printErrorMessageForMethod:@"sqlite3_prepare_v2" sql:sql];
        sqlite3_finalize(pStmt);
        
        return nil;
    }
    
    NSMutableArray<NSMutableDictionary *> *results = [[NSMutableArray alloc] init];
    //2.执行SQL
    while (sqlite3_step(pStmt) == SQLITE_ROW) {
        int columns = sqlite3_column_count(pStmt);
        NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:columns];
        
        for (int index = 0; index<columns; index++) {
            const char *name = sqlite3_column_name(pStmt, index);
            NSString *columnName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            
            int type = sqlite3_column_type(pStmt,index);
            switch (type) {
                case SQLITE_INTEGER: {
                    int value = sqlite3_column_int(pStmt, index);
                    [result setObject:[NSNumber numberWithInt:value] forKey:columnName];
                    break;
                }
                case SQLITE_FLOAT: {
                    float value = sqlite3_column_double(pStmt, index);
                    [result setObject:[NSNumber numberWithFloat:value] forKey:columnName];
                    break;
                }
                case SQLITE_TEXT: {
                    const char *value = (const char*)sqlite3_column_text(pStmt, index);
                    NSString *valueString = [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
                    [result setObject:valueString ? valueString : @"" forKey:columnName];
                    break;
                }
                case SQLITE_BLOB: {
                    int bytes = sqlite3_column_bytes(pStmt, index);
                    if (bytes > 0) {
                        const void *blob = sqlite3_column_blob(pStmt, index);
                        if (blob != NULL) {
                            [result setObject:[NSData dataWithBytes:blob length:bytes] forKey:columnName];
                        }
                    }
                    break;
                }
                case SQLITE_NULL: {
                    [result setObject:@"" forKey:columnName];
                    break;
                }
                default: {
                    const char *value = (const char *)sqlite3_column_text(pStmt, index);
                    NSString *valueString = [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
                    [result setObject:valueString ? valueString : @"" forKey:columnName];
                    break;
                }
            }
        }
        
        [results addObject:result];
    }
    
    return results;
}

#pragma mark - PrivateCachedStatements

- (void)clearCachedStatements
{
    [self.cachedStatements enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableSet<Statement *> * _Nonnull statements, BOOL * _Nonnull stop) {
        [statements enumerateObjectsUsingBlock:^(Statement * _Nonnull statement, BOOL * _Nonnull stop) {
            [statement close];
        }];
    }];
    
    [self.cachedStatements removeAllObjects];
}

- (Statement*)cachedStatementForQuery:(NSString*)query
{
    __block Statement *statement = nil;
    NSMutableSet<Statement *> *statements = [self.cachedStatements objectForKey:query];
    [statements enumerateObjectsUsingBlock:^(Statement * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj inUse]) {
            return;
        }
        
        statement = obj;
        *stop = YES;
    }];
    
    return statement;
}

- (void)setCachedStatement:(Statement*)statement forQuery:(NSString*)query
{
    [statement setQuery:query];
    
    NSMutableSet* statements = [self.cachedStatements objectForKey:query];
    if (!statements) {
        statements = [NSMutableSet set];
    }
    [statements addObject:statement];
    
    [self.cachedStatements setObject:statements forKey:query];
}


#pragma mark - PrivateMethod

- (const char*)cdatabasePath
{
    if (!self.databasePath || ([self.databasePath length] == 0)) {
        NSLog(@"warning please set database path");
    }
    
    return [_databasePath fileSystemRepresentation];
}

- (BOOL)databaseIsOpen
{
    BOOL result = YES;
    
    if (nil == _db) {
        result  = NO;
        
        NSLog(@"warning database is not open");
    }
    
    return result;
}

- (void)printErrorMessageForMethod:(NSString *)method sql:(NSString *)sql
{
    NSLog(@"database call %@ method error. errorInfo: %d \"%@\"", method,  [self lastErrorCode], [self lastErrorMessage]);
    NSLog(@"database sql: %@", sql);
    NSLog(@"database path: %@", _databasePath);
}

- (int)lastErrorCode
{
    return sqlite3_errcode(_db);
}

- (NSString*)lastErrorMessage
{
    return [NSString stringWithUTF8String:sqlite3_errmsg(_db)];
}

@end
