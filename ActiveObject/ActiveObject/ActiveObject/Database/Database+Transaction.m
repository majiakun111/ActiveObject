//
//  Database+Transaction.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Database+Transaction.h"

@implementation Database (Transaction)

- (BOOL)beginDeferredTransaction
{
    return [self executeUpdate:@"begin deferred transaction"];
}

- (BOOL)beginImmediateTransaction
{
    return [self executeUpdate:@"begin immediate transaction"];
}

- (BOOL)beginExclusiveTransaction
{
    return [self executeUpdate:@"begin exclusive transaction"];
}

- (BOOL)startSavePointWithName:(NSString*)name
{
    NSAssert(name, @"savepoint name can not nil");
    
    NSString *sql = [NSString stringWithFormat:@"savepoint '%@';", name];
    return [self executeUpdate:sql];
}

- (BOOL)releaseSavePointWithName:(NSString*)name
{
    NSAssert(name, @"savepoint name can not nil");
    
    NSString *sql = [NSString stringWithFormat:@"release savepoint '%@';", name];
    return [self executeUpdate:sql];
}

- (BOOL)rollbackToSavePointWithName:(NSString*)name
{
    NSAssert(name, @"savepoint name can not nil");
    
    NSString *sql = [NSString stringWithFormat:@"rollback transaction to savepoint '%@';", name];
    return [self executeUpdate:sql];
}

- (BOOL)rollback
{
    return [self executeUpdate:@"rollback transaction"];
}

- (BOOL)commit
{
    return [self executeUpdate:@"commit transaction"];
}

@end
