//
//  Record+Additions.m
//  Database
//
//  Created by Ansel on 16/3/23.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record+Additions.h"
#import "DatabaseDAO.h"
#import "DatabaseDAO+Additions.h"
#import "ActiveObjectDefine.h"

@implementation Record (Additions)

- (NSArray *)getColumns
{
    NSArray <NSDictionary *> *tableInfos = [[DatabaseDAO sharedInstance] getTableInfoForTable:[self tableName]];
    
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    for (NSDictionary *tableInfo in tableInfos) {
        NSString *columnName = tableInfo[@"name"];
        [columns addObject:columnName];
    }
    
    //remove rowId
    [columns removeObject:ROW_ID];
    
    return columns;
}

@end
