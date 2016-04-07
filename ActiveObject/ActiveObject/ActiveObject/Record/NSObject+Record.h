//
//  NSObject+Record.h
//  Database
//
//  Created by Ansel on 16/3/23.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Record)

/**
*   return [{PROPERTY_NAME : @"age", PROPERTY_TYPE: @"NSString", DATABASE_TYPE: @"text"}, ...]; 
*/
- (NSArray *)getPropertyInfoList;

+ (NSArray *)getPropertyInfoList;

- (NSArray *)getValueListWithPropertyList:(NSArray *)propertyList;

@end
