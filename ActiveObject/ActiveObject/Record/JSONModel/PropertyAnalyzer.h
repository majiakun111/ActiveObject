//
//  PropertyAnalyzer.h
//  ActiveObject
//
//  Created by Ansel on 2019/4/22.
//  Copyright © 2019 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class JSONModel;

NS_ASSUME_NONNULL_BEGIN

@interface PropertyInfo : NSObject

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *propertyType;
@property (nonatomic, copy) NSString *databaseType;

- (instancetype)initWithProperty:(objc_property_t)property;

@end

@interface PropertyAnalyzer : NSObject

+ (NSArray<PropertyInfo *> *)getPropertyInfoListForClass:(Class)clazz untilRootClass:(Class)rootClazz;

+ (NSArray *)getPropertyValueListWithPropertyList:(NSArray<NSString *> *)propertyList forRecord:(JSONModel *)record;

@end

NS_ASSUME_NONNULL_END
