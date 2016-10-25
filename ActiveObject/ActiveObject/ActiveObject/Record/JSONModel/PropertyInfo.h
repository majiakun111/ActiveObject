//
//  PropertyInfo.h
//  ActiveObject
//
//  Created by Ansel on 2016/10/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface PropertyInfo : NSObject

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *propertyType;
@property (nonatomic, copy) NSString *databaseType;

- (instancetype)initWithProperty:(objc_property_t)property;

@end
