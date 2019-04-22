//
//  Person.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "Person.h"
#import "ActiveObjectDefine.h"

@implementation Person

+ (NSDictionary<NSString*, NSString*> *)constraints
{
    return @{
              @"age" :  @"check (age >= 0)",
              @"height": @"check (height > 0)",
              @"weight": @"check (weight > 0)",
              @"name" : @"not null",
              @"cid"  : @"unique not null",
              @"telphones" : @"default ''"
            };
}

+ (NSDictionary<NSString*, NSDictionary*> *)indexes
{
    return @{
             @"age" : @{
                        INDEX_NAME : @"age_index",
                        IS_UNIQUE : @(NO),
                       },
             
             @"height" : @{
                     INDEX_NAME : @"height_index",
                     IS_UNIQUE : @(NO),
                     },
            };
}

@end

