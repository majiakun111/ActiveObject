//
//  NSObject+Record.h
//  Database
//
//  Created by Ansel on 16/3/23.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Record)

+ (NSArray *)getPropertyAndTypeListUntilRootClass:(Class)rootClass;

- (NSArray *)getValuesWithPropertyList:(NSArray *)propertyList;

@end
