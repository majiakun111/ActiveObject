//
//  NSArray+JOSN.m
//  ActiveObject
//
//  Created by Ansel on 16/3/24.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "NSArray+JSON.h"

@implementation NSArray (JSON)

- (NSString *)JSONString
{
    BOOL result = [NSJSONSerialization isValidJSONObject:self];
    if (!result) {
        return @"";
    }
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"JSONValue error: %@", error);
        return @"";
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

@end
