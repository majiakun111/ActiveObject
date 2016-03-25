//
//  DatabaseDAO+Additions.m
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseDAO+Additions.h"

@implementation DatabaseDAO (Additions)

- (long long)lastInsertRowId
{
    return [self.database lastInsertRowId];
}

- (NSArray <NSDictionary *> *)getTableInfoForTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"pragma table_info('%@')" , tableName];
    NSArray <NSDictionary *> *tableInfo = [[DatabaseDAO sharedInstance] executeQuery:sql];
    
    return tableInfo;
}

@end
