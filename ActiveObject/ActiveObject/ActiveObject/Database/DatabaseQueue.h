//
//  DatabaseQueue.h
//  Database
//
//  Created by Ansel on 16/3/21.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Database;

@interface DatabaseQueue : NSObject

- (instancetype)initWithDatabasePath:(NSString*)databasePath;

- (instancetype)initWithDatabasePath:(NSString*)databasePath flags:(int)flags;

- (void)close;

- (void)inDatabase:(void (^)(Database *db))block;

- (void)inDeferredTransaction:(void (^)(Database *db, BOOL *rollback))block;

- (void)inImmediateTransaction:(void (^)(Database *db, BOOL *rollback))block;

- (void)inExclusiveTransaction:(void (^)(Database *db, BOOL *rollback))block;

@end
