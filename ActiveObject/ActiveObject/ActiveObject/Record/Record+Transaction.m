//
//  Record+Transaction.m
//  ActiveObject
//
//  Created by Ansel on 16/3/24.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record+Transaction.h"
#import "DatabaseDAO.h"

@implementation Record (Transaction)

- (BOOL)beginDeferredTransaction
{
    return [[DatabaseDAO sharedInstance] executeUpdate:@"begin deferred transaction"];
}

- (BOOL)beginImmediateTransaction
{
    return [[DatabaseDAO sharedInstance] executeUpdate:@"begin immediate transaction"];
}

- (BOOL)beginExclusiveTransaction
{
    return [[DatabaseDAO sharedInstance] executeUpdate:@"begin exclusive transaction"];
}

- (BOOL)startSavePointWithName:(NSString*)name
{
    NSAssert(name, @"savepoint name can not nil");
    
    NSString *sql = [NSString stringWithFormat:@"savepoint '%@';", name];
    return [[DatabaseDAO sharedInstance] executeUpdate:sql];
}

- (BOOL)releaseSavePointWithName:(NSString*)name
{
    NSAssert(name, @"savepoint name can not nil");
    
    NSString *sql = [NSString stringWithFormat:@"release savepoint '%@';", name];
    return [[DatabaseDAO sharedInstance] executeUpdate:sql];
}

- (BOOL)rollbackToSavePointWithName:(NSString*)name
{
    NSAssert(name, @"savepoint name can not nil");
    
    NSString *sql = [NSString stringWithFormat:@"rollback transaction to savepoint '%@';", name];
    return [[DatabaseDAO sharedInstance] executeUpdate:sql];
}

- (BOOL)rollback
{
    return [[DatabaseDAO sharedInstance] executeUpdate:@"rollback transaction"];
}

- (BOOL)commit
{
    return [[DatabaseDAO sharedInstance] executeUpdate:@"commit transaction"];
}
@end
