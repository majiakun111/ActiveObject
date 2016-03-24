//
//  Record.h
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject

- (NSString *)tableName;

// may override
+ (NSString *)tableName;

@end
