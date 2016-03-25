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
*   return [{propertyName : @"age", PROPERTY_TYPE: @"NSString", DATABASE_TYPE: @"text"}, ...]; //以propertyName 作为key
*/
- (NSArray *)getPropertyInfoListUntilRootClass:(Class)rootClass;

+ (NSArray *)getPropertyInfoListUntilRootClass:(Class)rootClass;

- (NSArray *)getValueListWithPropertyList:(NSArray *)propertyList;

@end
