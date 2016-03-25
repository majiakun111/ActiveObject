//
//  DatabaseDAO+Transaction.h
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseDAO.h"

@interface DatabaseDAO (Transaction)

- (BOOL)beginDeferredTransaction;

- (BOOL)beginImmediateTransaction;

- (BOOL)beginExclusiveTransaction;

- (BOOL)startSavePointWithName:(NSString*)name;

- (BOOL)releaseSavePointWithName:(NSString*)name;

- (BOOL)rollbackToSavePointWithName:(NSString*)name;

- (BOOL)rollback;

- (BOOL)commit;

@end
