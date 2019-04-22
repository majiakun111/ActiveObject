//
//  Database+Additions.h
//  ActiveObject
//
//  Created by Ansel on 16/3/26.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "Database.h"

@interface Database (Additions)

//获取最后插入的rowId
- (sqlite_int64)lastInsertRowId;

/*
 * set database 加解密的key
 */
- (BOOL)setKey:(NSString*)key;

/*
 * reset database 加解密的key
 */
- (BOOL)resetKey:(NSString*)key;

@end
