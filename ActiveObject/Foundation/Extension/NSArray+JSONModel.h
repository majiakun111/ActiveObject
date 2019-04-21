//
//  NSArray+JSONModel.h
//  ActiveObject
//
//  Created by Ansel on 2016/10/24.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (JSONModel)

- (NSArray *)modelArrayWithClass:(Class)modelClass;

- (NSArray *)toJSONArray;

@end
