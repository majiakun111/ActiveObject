//
//  DatabaseQueue.h
//  Database
//
//  Created by Ansel on 16/3/21.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Database;

typedef NS_OPTIONS(NSInteger, SqlType) {    
    SqlForDDLType = 1 << 0, //数据库定义的sql
    SqlForDMLType = 1 << 1, //数据库操作的sql
    SqlForDQLType = 1 << 2, //数据库查询的sql
};


@interface AsyncQueue : NSObject

+ (instancetype)sharedInstance;

- (void)inDatabase:(void (^)(void))block forSqlType:(SqlType)sqlType;

- (void)inDeferredTransaction:(void (^)(BOOL *rollback))block forSqlType:(SqlType)sqlType;

- (void)inImmediateTransaction:(void (^)(BOOL *rollback))block forSqlType:(SqlType)sqlType;

- (void)inExclusiveTransaction:(void (^)(BOOL *rollback))block forSqlType:(SqlType)sqlType;

@end
