//
//  Record+Additions.m
//  Database
//
//  Created by Ansel on 16/3/23.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record+Additions.h"
#import "DatabaseDAO+Additions.h"

@implementation Record (Additions)

- (NSArray *)getColumns
{
    return [[DatabaseDAO sharedInstance] getColumnsForTableName:[self tableName]];
}

@end
