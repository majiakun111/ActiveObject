//
//  Person.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Person.h"

@implementation Person

- (NSDictionary *)columnConstraints
{
    return @{
              @"age" :  @"check (age >= 0)",
              @"height": @"check (height > 0)",
              @"name" : @"not null",
              @"cid"  : @"unique not null",
              @"telphones" : @"default ''"
            };
}

@end

