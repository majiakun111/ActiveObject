//
//  DatabaseMigrator.h
//  ActiveObject
//
//  Created by Ansel on 16/3/26.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"

@interface DatabaseMigrator : NSObject

- (BOOL)executeMigrateForDatabase:(Database *)database
           currentDatabaseVersion:(NSString *)currentDatabaseVersion;

#pragma mark - MustOverrride

- (NSArray<NSString *> *)migrationVersionList;

//版本之间迁移
- (NSDictionary<NSString*, Class> *)migrateVersionAndExecutorMap;

@end
