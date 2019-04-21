//
//  NSString+JSON.m
//  ActiveObject
//
//  Created by Ansel on 16/3/24.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)

- (id)JSONObject
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"JSONObject error: %@", error);
        
        return @"";
    }
    
    return object;
}

@end
