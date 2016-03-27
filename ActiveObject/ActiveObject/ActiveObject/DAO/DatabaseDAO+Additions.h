//
//  DatabaseDAO+Additions.h
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseDAO.h"

@interface DatabaseDAO (Additions)

- (long long)lastInsertRowId;

- (NSArray <NSDictionary *> *)getTableInfoForTable:(NSString *)tableName;

/*
 * set database 加解密的key
 */
- (BOOL)setKey:(NSString*)key;

/*
 * reset database 加解密的key
 */
- (BOOL)resetKey:(NSString*)key;

@end
