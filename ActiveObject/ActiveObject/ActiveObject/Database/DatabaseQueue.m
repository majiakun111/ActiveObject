//
//  DatabaseQueue.m
//  Database
//
//  Created by Ansel on 16/3/21.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseQueue.h"
#import "Database.h"
#import "Database+Transaction.h"

typedef NS_ENUM(NSInteger, TransactionType) {
    Deferred = 0,
    Immediate = 1,
    Exclusive = 2,
};

@interface DatabaseQueue ()

@property (nonatomic, strong) Database *database;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation DatabaseQueue

- (instancetype)initWithDatabasePath:(NSString*)databasePath flags:(int)flags
{
    self = [super init];
    
    if (self) {
        _database = [[Database alloc]initWithDatabasePath:databasePath];
        BOOL result = [_database openWithFlags:flags];
        if (!result) {
            NSLog(@"Could not create database queue for path %@", databasePath);
            return 0x00;
        }
    }
    
    return self;
}

- (instancetype)initWithDatabasePath:(NSString*)databasePath
{
    return [self initWithDatabasePath:databasePath flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE];
}

- (void)close
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [self.database close];
        self.database = nil;
    }];
    
    [self.operationQueue addOperation:operation];
}

- (void)inDatabase:(void (^)(Database *db))block
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        block(self.database);
    }];
    
    [self.operationQueue addOperation:operation];
}

- (void)inDeferredTransaction:(void (^)(Database *db, BOOL *rollback))block
{
    [self beginTransaction:Deferred withBlock:block];
}

- (void)inImmediateTransaction:(void (^)(Database *db, BOOL *rollback))block
{
    [self beginTransaction:Immediate withBlock:block];
}

- (void)inExclusiveTransaction:(void (^)(Database *db, BOOL *rollback))block
{
    [self beginTransaction:Exclusive withBlock:block];
}

#pragma mark - PrivateMethod

- (void)beginTransaction:(TransactionType)transactionType withBlock:(void (^)(Database *db, BOOL *rollback))block
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        BOOL shouldRollback = NO;
        
        switch (transactionType) {
            case Deferred: {
                [self.database beginDeferredTransaction];
                break;
            }
            case Immediate: {
                [self.database beginImmediateTransaction];
                break;
            }
            case Exclusive: {
                [[self database] beginExclusiveTransaction];
                break;
            }
            default:
                break;
        }
        
        block(self.database, &shouldRollback);
        
        if (shouldRollback) {
            [self.database rollback];
        }
        else {
            [self.database commit];
        }
    }];
    
    [self.operationQueue addOperation:operation];
}

#pragma mark - PrivateMethod

- (NSOperationQueue *)operationQueue
{
    if (nil == _operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setMaxConcurrentOperationCount:1];
    }
    
    return _operationQueue;
}

@end

