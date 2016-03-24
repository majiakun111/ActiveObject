//
//  Record+DML.h
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record.h"

@interface Record (DML)

- (BOOL)save;

- (BOOL)delete;

+ (BOOL)deleteAll;

- (BOOL)update;

#pragma mark - Hook Method

- (void)saveBefore;

- (void)saveAfter;

- (void)deleteBefore;

- (void)deleteAfter;

- (void)deleteAllBefore;

- (void)deleteAllAfter;

- (void)updateBefore;

- (void)updateAfter;

@end
