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

//需要删除关联的表,先query后delete
- (BOOL)delete;

- (BOOL)update;

#pragma mark - Hook Method

- (void)saveBefore;

- (void)saveAfter;

- (void)deleteBefore;

- (void)deleteAfter;

- (void)updateBefore;

- (void)updateAfter;

@end
