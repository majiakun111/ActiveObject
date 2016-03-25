//
//  DatabaseQueue.m
//  Database
//
//  Created by Ansel on 16/3/21.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "AsyncQueue.h"
#import "Database.h"
#import "DatabaseDAO.h"
#import "DatabaseDAO+Transaction.h"

typedef NS_ENUM(NSInteger, TransactionType) {
    Deferred = 0,
    Immediate = 1,
    Exclusive = 2,
};


@interface AsyncQueue ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation AsyncQueue

+ (instancetype)sharedInstance
{
    static AsyncQueue *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == instance) {
            instance = [[AsyncQueue alloc] init];
        }
    });
    
    return instance;
}

- (void)inDatabase:(void (^)())block
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        block();
    }];
    
    [self.operationQueue addOperation:operation];
}

- (void)inDeferredTransaction:(void (^)(BOOL *rollback))block
{
    [self beginTransaction:Deferred withBlock:block];
}

- (void)inImmediateTransaction:(void (^)(BOOL *rollback))block
{
    [self beginTransaction:Immediate withBlock:block];
}

- (void)inExclusiveTransaction:(void (^)(BOOL *rollback))block
{
    [self beginTransaction:Exclusive withBlock:block];
}

#pragma mark - PrivateMethod

- (void)beginTransaction:(TransactionType)transactionType withBlock:(void (^)(BOOL *rollback))block
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        BOOL shouldRollback = NO;
        
        switch (transactionType) {
            case Deferred: {
                [[DatabaseDAO sharedInstance] beginDeferredTransaction];
                break;
            }
            case Immediate: {
                [[DatabaseDAO sharedInstance] beginImmediateTransaction];
                break;
            }
            case Exclusive: {
                [[DatabaseDAO sharedInstance] beginExclusiveTransaction];
                break;
            }
            default:
                break;
        }
        
        block(&shouldRollback);
        
        if (shouldRollback) {
            [[DatabaseDAO sharedInstance] rollback];
        }
        else {
            [[DatabaseDAO sharedInstance] commit];
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

