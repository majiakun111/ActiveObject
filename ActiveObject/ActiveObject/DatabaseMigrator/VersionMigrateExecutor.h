//
//  MigratingBetweenVersionsProtocol.h
//  ActiveObject
//
//  Created by Ansel on 16/3/26.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Database;

@protocol VersionMigrateExecutor <NSObject>

@required
- (BOOL)execute;

@end
