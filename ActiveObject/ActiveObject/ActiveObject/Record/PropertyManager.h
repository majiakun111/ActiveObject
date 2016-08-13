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

@interface PropertyInfo : NSObject

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *propertyType;
@property (nonatomic, copy) NSString *databaseType;

- (instancetype)initWithProperty:(objc_property_t)property;

@end

@interface PropertyManager : NSObject

+ (instancetype)shareInstance; 

- (NSArray<PropertyInfo *> *)getPropertyInfoListForClass:(Class)clazz untilRootClass:(Class)clazz;

- (NSArray *)getValueListWithPropertyList:(NSArray *)propertyList forRecord:(Record *)record;

@end
