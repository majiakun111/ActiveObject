//
//  Database+Transaction.h
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Database.h"

@interface Database (Transaction)

- (BOOL)beginDeferredTransaction;

- (BOOL)beginImmediateTransaction;

- (BOOL)beginExclusiveTransaction;

- (BOOL)startSavePointWithName:(NSString*)name;

- (BOOL)releaseSavePointWithName:(NSString*)name;

- (BOOL)rollbackToSavePointWithName:(NSString*)name;

- (BOOL)rollback;

- (BOOL)commit;

@end
