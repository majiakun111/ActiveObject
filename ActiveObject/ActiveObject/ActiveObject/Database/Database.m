//
//  Database.m
//  Database
//
//  Created by Ansel on 16/3/21.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Database.h"

@interface Database ()

@property (nonatomic, copy) NSString *databasePath;

@end

@implementation Database

- (instancetype)initWithDatabasePath:(NSString *)databasePath
{
    self = [super init];
    if (self) {
        self.databasePath = databasePath;
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
    
    BOOL result = YES;
    
    do {
        sqlite3_stmt *pStmt = NULL;
        //1. 预处理SQL
        int statusCode = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &pStmt, NULL);
        if (statusCode != SQLITE_OK) {
            [self printErrorMessageForMethod:@"sqlite3_prepare_v2" sql:sql];
            sqlite3_finalize(pStmt);
            result = NO;
            break;
        }
        
        //2.执行SQL
        statusCode = sqlite3_step(pStmt);
        if (statusCode != SQLITE_DONE) {
            [self printErrorMessageForMethod:@"sqlite3_step" sql:sql];
            result = NO;
            break;
        }
        
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
    NSLog(@"database call %@ error. errorInfo: %d \"%@\"", method,  [self lastErrorCode], [self lastErrorMessage]);
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
