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

+ (instancetype)sharedInstance;

- (void)inDatabase:(void (^)())block;

- (void)inDeferredTransaction:(void (^)(BOOL *rollback))block;

- (void)inImmediateTransaction:(void (^)(BOOL *rollback))block;

- (void)inExclusiveTransaction:(void (^)(BOOL *rollback))block;

@end
