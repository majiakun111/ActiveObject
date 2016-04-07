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
        return YES;
    }
    
    //执行迁移
    BOOL result = YES;
    NSDictionary *migrateVersionAndExecutorMap = [self migrateVersionAndExecutorMap];
    [realMigrationVersionList enumerateObjectsUsingBlock:^(NSString*  _Nonnull databaseVersion, NSUInteger idx, BOOL * _Nonnull stop) {
        
        Class class = migrateVersionAndExecutorMap[databaseVersion];
        id <VersionMigrateExecutor> executor = [[class alloc] init];
        BOOL result = [executor execute];
        if (!result) {
            *stop = YES;
        }
        
    }];
    
    return result;
}

#pragma mark - MustOverrride

- (NSArray<NSString *> *)migrationVersionList
{
#ifdef DEBUG
    [NSException raise:@"Must Override" format:@"migrationVersionList"];
#endif
    return nil;
}

- (NSDictionary<NSString*, Class> *)migrateVersionAndExecutorMap
{
#ifdef DEBUG
    [NSException raise:@"Must Override" format:@"migrateVersionAndExecutorMap"];
#endif
    return nil;
}

@end
