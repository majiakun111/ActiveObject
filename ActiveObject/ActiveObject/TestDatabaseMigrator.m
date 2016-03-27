//
//  TestDatabaseMigrate.m
//  ActiveObject
//
//  Created by Ansel on 16/3/27.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "TestDatabaseMigrator.h"
#import "Version2MigrateExecutor.h"

@implementation TestDatabaseMigrator

- (NSArray<NSString *> *)migrationVersionList
{
    return @[@"2.0"];
}

- (NSDictionary<NSString*, Class> *)migrateVersionAndExecutorMap
{
    return @{@"2.0": [Version2MigrateExecutor class]};
}

@end
