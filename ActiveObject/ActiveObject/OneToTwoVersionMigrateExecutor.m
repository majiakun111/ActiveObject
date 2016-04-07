//
//  ExecuteVersion2Migrate.m
//  ActiveObject
//
//  Created by Ansel on 16/3/27.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "OneToTwoVersionMigrateExecutor.h"
#import "Person.h"
#import "Record+DDL.h"

@implementation OneToTwoVersionMigrateExecutor

- (BOOL)execute
{
    return YES;
    
    Person *person = [[Person alloc] init];
    return [person createIndex:@"height_index" onColumn:@"height" isUnique:NO];
}

@end
