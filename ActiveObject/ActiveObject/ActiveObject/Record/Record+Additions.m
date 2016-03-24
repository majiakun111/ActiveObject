//
//  Record+Additions.m
//  Database
//
//  Created by Ansel on 16/3/23.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record+Additions.h"
#import "DatabaseDAO.h"

@implementation Record (Additions)

- (NSArray *)getColumns
{
    NSString *sql = [NSString stringWithFormat:@"pragma table_info('%@')" , [self tableName]];
    NSArray <NSDictionary *> *tableInfos = [DATABASE executeQuery:sql];
    
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    for (NSDictionary *tableInfo in tableInfos) {
        NSString *columnName = tableInfo[@"name"];
        [columns addObject:columnName];
    }
    
    //remove rowId
    [columns removeObjectAtIndex:0];
    
    return columns;
}

@end
