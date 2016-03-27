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
    return [person addColumn:@"address" type:@"text" constraint:@"default ''"];
}

@end
