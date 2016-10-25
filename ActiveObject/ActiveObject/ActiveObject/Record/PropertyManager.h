//
//  PropertyInfoListManager.h
//  ActiveObject
//
//  Created by Ansel on 16/8/13.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class Record;
@class PropertyInfo;

@interface PropertyManager : NSObject

+ (instancetype)shareInstance; 

- (NSArray<PropertyInfo *> *)getPropertyInfoListForClass:(Class)clazz untilRootClass:(Class)clazz;

- (NSArray *)getValueListWithPropertyList:(NSArray *)propertyList forRecord:(Record *)record;

- (void)removePropertyInfoListForClasss:(Class)clazz;

- (void)removeValueListForRecord:(Record *)record;

@end
