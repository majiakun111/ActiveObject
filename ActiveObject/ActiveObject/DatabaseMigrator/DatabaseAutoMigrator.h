//
//  DatabaseAutoMigrator.h
//  ActiveObject
//
//  Created by Ansel on 16/4/8.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseAutoMigrator : NSObject

- (BOOL)autoExecuteMigrate;

@end
