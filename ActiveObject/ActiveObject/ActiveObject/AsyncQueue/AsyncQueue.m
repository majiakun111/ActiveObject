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
    TransactionForUnknowType = -1,
    
    TransactionForDeferredType = 0,
    TransactionForImmediateType = 1,
    TransactionForExclusiveType = 2,
    
    TransactionForAllType
};

NSUInteger const MaxConcurrentOperationCountOfRead = 1;
NSUInteger const MaxConcurrentOperationCountOfWrite = 1;

@interface AsyncQueue ()

@property(nonatomic, strong) dispatch_semaphore_t semaphore;//锁

@property(nonatomic, strong) NSOperationQueue *readOperationQueue; //数据库读的任务队列
@property(nonatomic, strong) NSOperationQueue *writeOperationQueue; //数据库写的任务队列

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

- (instancetype)init {
    self = [super init];
    if (self) {
        _semaphore = dispatch_semaphore_create(1);

        _readOperationQueue = [[NSOperationQueue alloc] init];
        [_readOperationQueue setMaxConcurrentOperationCount:MaxConcurrentOperationCountOfRead];
        
        _writeOperationQueue = [[NSOperationQueue alloc] init];
        [_writeOperationQueue setMaxConcurrentOperationCount:MaxConcurrentOperationCountOfWrite];
    }
    
    return self;
}

- (void)inDatabase:(void (^)(void))block forSqlType:(SqlType)sqlType
{
    [self executeBlock:block sqlType:sqlType];
}

- (void)inDeferredTransaction:(void (^)(BOOL *rollback))block forSqlType:(SqlType)sqlType
{
    [self beginTransaction:TransactionForDeferredType block:block forSqlType:sqlType];
}

- (void)inImmediateTransaction:(void (^)(BOOL *rollback))block forSqlType:(SqlType)sqlType
{
    [self beginTransaction:TransactionForImmediateType block:block forSqlType:sqlType];
}

- (void)inExclusiveTransaction:(void (^)(BOOL *rollback))block forSqlType:(SqlType)sqlType
{
    [self beginTransaction:TransactionForExclusiveType block:block forSqlType:sqlType];
}

#pragma mark - PrivateMethod

- (void)beginTransaction:(TransactionType)transactionType block:(void (^)(BOOL *rollback))block forSqlType:(SqlType)sqlType
{
    if (!block) {
        return;
    }
    
    void (^warpperBlock)(void) = ^{
        BOOL shouldRollback = NO;
        
        switch (transactionType) {
            case  TransactionForDeferredType: {
                [[DatabaseDAO sharedInstance] beginDeferredTransaction];
                break;
            }
            case TransactionForImmediateType: {
                [[DatabaseDAO sharedInstance] beginImmediateTransaction];
                break;
            }
            case TransactionForExclusiveType: {
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
    };

    [self executeBlock:warpperBlock sqlType:sqlType];
}

- (void)executeBlock:(void (^)(void))block sqlType:(SqlType)sqlType
{
    if (!block) {
        return;
    }
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        
        block();
        
        dispatch_semaphore_signal(self.semaphore);
    }];
    
    if (sqlType == SqlForDQLType) {
        [self.readOperationQueue addOperation:operation];
    } else {
        [self.writeOperationQueue addOperation:operation];
    }
}

@end

