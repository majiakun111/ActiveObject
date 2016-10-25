//
//  JSONModelError.h
//  ActiveObject
//
//  Created by Ansel on 2016/10/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONModelError : NSError

+(id)errorInputIsNil;

+(id)errorInvalidDataWithDescription:(NSString*)description;

@end
