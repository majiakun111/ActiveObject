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
    Person *person = [[Person alloc] init];
    
    BOOL result = YES;
    result = [person dropIndex:@"height_index"];
    if (!result) {
        return NO;
    }
    
    result = [person createIndex:@"height_index" onColumn:@"height, weight" isUnique:NO];
    
    return result;
}

@end
