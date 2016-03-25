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
*   return {@"name" : {@"propertyType": @"NSString", @"dbType": @"text"}}; //以propertyName 作为key
*/
- (NSDictionary *)getPropertyInfoMapUntilRootClass:(Class)rootClass;

+ (NSDictionary *)getPropertyInfoMapUntilRootClass:(Class)rootClass;

- (NSArray *)getValueListWithPropertyList:(NSArray *)propertyList;

@end
