//
//  DatabaseDAO.h
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseDAO : NSObject

+ (instancetype)sharedInstance;

- (void)configDatabasePath:(NSString*)databasePath;

- (void)configDatabasePath:(NSString*)databasePath flags:(int)flags;

- (BOOL)executeUpdate:(NSString*)sql;

//select
- (NSArray<NSDictionary *> *)executeQuery:(NSString*)sql;

//transaction
- (BOOL)beginDeferredTransaction;

- (BOOL)beginImmediateTransaction;

- (BOOL)beginExclusiveTransaction;

- (BOOL)startSavePointWithName:(NSString*)name;

- (BOOL)releaseSavePointWithName:(NSString*)name;

- (BOOL)rollbackToSavePointWithName:(NSString*)name;

- (BOOL)rollback;

- (BOOL)commit;

@end
