//
//  Record.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record.h"
#import "Record+DDL.h"
#import "Record+Condition.h"

@implementation Record

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createTable];
        [self resetAll];
    }
    
    return self;
}

- (NSString *)tableName
{
    return [[self class] tableName];
}

+ (NSString *)tableName
{
    return NSStringFromClass([self class]);
}

@end
