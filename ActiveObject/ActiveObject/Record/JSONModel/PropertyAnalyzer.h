//
//  PropertyAnalyzer.h
//  ActiveObject
//
//  Created by Ansel on 2019/4/22.
//  Copyright © 2019 MJK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface PropertyInfo : NSObject

@property (nonatomic, readonly, copy) NSString *propertyName;
@property (nonatomic, readonly, strong) Class propertyClass;
@property (nonatomic, readonly, getter = isFromFoundation) BOOL fromFoundation;
@property (nonatomic, readonly, copy) NSString *databaseType;

- (instancetype)initWithProperty:(objc_property_t)property;

@end

@interface PropertyAnalyzer : NSObject

+ (NSArray<PropertyInfo *> *)getPropertyInfoListForClass:(Class)clazz;

+ (NSArray *)getPropertyValueListWithPropertyList:(NSArray<NSString *> *)propertyList forObject:(NSObject *)object;

@end

NS_ASSUME_NONNULL_END
