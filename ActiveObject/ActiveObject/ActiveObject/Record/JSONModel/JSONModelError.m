//
//  JSONModelError.m
//  ActiveObject
//
//  Created by Ansel on 2016/10/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "JSONModelError.h"


NSString* const JSONModelErrorDomain = @"JSONModelErrorDomain";


typedef NS_ENUM(int, kJSONModelErrorTypes) {
    kJSONModelErrorNilInput = 0,
    kJSONModelErrorInvalidData = 1,
};

@implementation JSONModelError

+(id)errorInputIsNil
{
    return [JSONModelError errorWithDomain:JSONModelErrorDomain
                                      code:kJSONModelErrorNilInput
                                  userInfo:@{NSLocalizedDescriptionKey:@"Initializing model with nil input object."}];
}

+(id)errorInvalidDataWithDescription:(NSString*)description
{
    description = [NSString stringWithFormat:@"Invalid JSON data: %@", description];
    return [JSONModelError errorWithDomain:JSONModelErrorDomain
                                      code:kJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:description}];
}

@end
