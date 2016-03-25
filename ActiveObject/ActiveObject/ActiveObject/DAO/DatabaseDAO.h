//
//  DatabaseDAO.h
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"

@interface DatabaseDAO : NSObject

@property (nonatomic, strong) Database *database;

+ (instancetype)sharedInstance;

- (void)configDatabasePath:(NSString*)databasePath;

- (void)configDatabasePath:(NSString*)databasePath flags:(int)flags;

- (BOOL)executeUpdate:(NSString*)sql;

//select
- (NSArray<NSDictionary *> *)executeQuery:(NSString*)sql;

@end
