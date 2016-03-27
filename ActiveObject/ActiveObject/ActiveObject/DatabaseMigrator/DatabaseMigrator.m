//
//  DatabaseMigrator.m
//  ActiveObject
//
//  Created by Ansel on 16/3/26.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseMigrator.h"
#import "VersionMigrateExecutor.h"

@implementation DatabaseMigrator

- (BOOL)executeMigrateForDatabase:(Database *)database
           currentDatabaseVersion:(NSString *)currentDatabaseVersion
{
    //获取真正需要迁移的版本
    NSArray *migrationVersionList = [self migrationVersionList];
    NSInteger currentDatabaseVersionIndex = [migrationVersionList indexOfObject:currentDatabaseVersion];
    NSInteger count = [migrationVersionList count];
    
    if ((currentDatabaseVersionIndex > count-1) || currentDatabaseVersionIndex < 0) {
        currentDatabaseVersionIndex = 0;
    }
    
    NSArray *realMigrationVersionList = [migrationVersionList subarrayWithRange:NSMakeRange(currentDatabaseVersionIndex, count)];
    if (!realMigrationVersionList || [realMigrationVersionList count] <= 0) {
        return NO;
    }
    
    //获取版本件迁移的执行者
    NSDictionary *migrateVersionAndExecutorMap = [self migrateVersionAndExecutorMap];
    NSMutableArray<Class> *executors = [NSMutableArray array];
    [realMigrationVersionList enumerateObjectsUsingBlock:^(NSString*  _Nonnull databaseVersion, NSUInteger idx, BOOL * _Nonnull stop) {
        
        Class class = migrateVersionAndExecutorMap[databaseVersion];
        if (class) {
            [executors addObject:class];
        }
        
    }];

    //开始执行迁移
    __block BOOL result = YES;
    [executors enumerateObjectsUsingBlock:^(Class  _Nonnull class, NSUInteger idx, BOOL * _Nonnull stop) {
        id <VersionMigrateExecutor> executor = [[class alloc] init];
        result = [executor execute];
        if (!result) {
            *stop = !result;
        }
    }];
    
    return result;
}

#pragma mark - MustOverrride

- (NSArray<NSString *> *)migrationVersionList
{
    [NSException raise:@"Must Override" format:@"migrationVersionList"];
    return nil;
}

- (NSDictionary<NSString*, Class> *)migrateVersionAndExecutorMap
{
    [NSException raise:@"Must Override" format:@"migrateVersionAndExecutorMap"];
    return nil;
}

@end
