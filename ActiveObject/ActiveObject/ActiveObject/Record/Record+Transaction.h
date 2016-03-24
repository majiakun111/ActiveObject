//
//  Record+Transaction.h
//  ActiveObject
//
//  Created by Ansel on 16/3/24.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record.h"

@interface Record (Transaction)

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
