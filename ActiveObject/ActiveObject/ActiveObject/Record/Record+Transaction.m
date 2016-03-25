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
    return [[DatabaseDAO sharedInstance] beginDeferredTransaction];
}

- (BOOL)beginImmediateTransaction
{
    return [[DatabaseDAO sharedInstance] beginImmediateTransaction];
}

- (BOOL)beginExclusiveTransaction
{
    return [[DatabaseDAO sharedInstance] beginExclusiveTransaction];
}

- (BOOL)startSavePointWithName:(NSString*)name
{    
    return [[DatabaseDAO sharedInstance] startSavePointWithName:name];
}

- (BOOL)releaseSavePointWithName:(NSString*)name
{
    return [[DatabaseDAO sharedInstance] releaseSavePointWithName:name];
}

- (BOOL)rollbackToSavePointWithName:(NSString*)name
{
    return [[DatabaseDAO sharedInstance] rollbackToSavePointWithName:name];
}

- (BOOL)rollback
{
    return [[DatabaseDAO sharedInstance] rollback];
}

- (BOOL)commit
{
    return [[DatabaseDAO sharedInstance] commit];
}
@end
