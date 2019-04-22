//
//  Database+Additions.m
//  ActiveObject
//
//  Created by Ansel on 16/3/26.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "Database+Additions.h"

@implementation Database (Additions)

- (sqlite_int64)lastInsertRowId
{
    sqlite_int64 rowId = sqlite3_last_insert_rowid(self->_db);
    
    return rowId;
}

- (BOOL)resetKey:(NSString*)key {
#ifdef SQLITE_HAS_CODEC
    if (!key) {
        return NO;
    }
    
    NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:(NSUInteger)strlen([key UTF8String])];
    int result = sqlite3_rekey(self->_db, [keyData bytes], (int)[keyData length]);
    if (result != SQLITE_OK) {
        NSLog(@"error on rekey: %d", result);
        NSLog(@"%@", [self lastErrorMessage]);
    }
    
    return (result == SQLITE_OK);
#else
    return NO;
#endif
}

- (BOOL)setKey:(NSString*)key
{
#ifdef SQLITE_HAS_CODEC
    if (!key) {
        return NO;
    }
    
    NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:(NSUInteger)strlen([key UTF8String])];
    int result = sqlite3_key(self->_db, [keyData bytes], (int)[keyData length]);
    return (result == SQLITE_OK);
#else
    return NO;
#endif
}

@end
