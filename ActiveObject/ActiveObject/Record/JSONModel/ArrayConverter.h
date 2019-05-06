//
//  ArrayConverter.h
//  ActiveObject
//
//  Created by Ansel on 2019/5/6.
//  Copyright © 2019 MJK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArrayConverter : NSObject

//如果value是jsonString，需要解析出来对应的对象
+ (id)getArrayValueWithValue:(id)value propertyName:(NSString *)propertyName forObject:(NSObject *)object block:(NSDictionary* (^)(long long rowId, Class clazz))block;

// 如果arrayValue里面的元素不是基本类型就转成jsonString
+ (id)getValuesWithArrayValue:(NSArray *)arrayValue propertyName:(NSString *)propertyName forObject:(NSObject *)object;

@end

NS_ASSUME_NONNULL_END
