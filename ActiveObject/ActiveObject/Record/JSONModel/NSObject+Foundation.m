//
//  NSObject+Foundation.m
//  ActiveObject
//
//  Created by Ansel on 2019/4/29.
//  Copyright © 2019 MJK. All rights reserved.
//

#import "NSObject+Foundation.h"

@implementation NSObject (Foundation)

- (BOOL)fromFoundationForClazz:(Class)clazz
{
    if (clazz == [NSObject class]) return YES;
    
    NSSet *foundationClasses = [NSSet setWithObjects:
                                [NSURL class],
                                [NSDate class],
                                [NSValue class],
                                [NSData class],
                                [NSError class],
                                [NSArray class],
                                [NSDictionary class],
                                [NSString class],
                                [NSAttributedString class], nil];
    
    __block BOOL result = NO;
    [foundationClasses enumerateObjectsUsingBlock:^(Class foundationClass, BOOL *stop) {
        if ([clazz isSubclassOfClass:foundationClass]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

@end
