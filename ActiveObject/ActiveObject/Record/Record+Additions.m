//
//  Record+Additions.m
//  Database
//
//  Created by Ansel on 16/3/23.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record+Additions.h"
#import "DatabaseDAO+Additions.h"
#import "ActiveObjectDefine.h"

@implementation Record (Additions)

- (NSArray<NSString *> *)getColumns
{
    NSMutableArray *columns  = (NSMutableArray *)[[DatabaseDAO sharedInstance] getColumnsForTableName:[self tableName]];
    [columns removeObject:ROW_ID];
    
    return columns;
}

@end
