//
//  NSObject+JSONModel.h
//  ActiveObject
//
//  Created by Ansel on 2019/4/29.
//  Copyright © 2019 MJK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JSONModel)

- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (id)initWithJSONDictionary:(NSDictionary *)dictionary error:(NSError **)error;

+ (id)modelWithJSONDictionary:(NSDictionary *)dictionary;
+ (id)modelWithJSONDictionary:(NSDictionary *)dictionary error:(NSError **)error;

- (NSDictionary *)toJSONDictionary;

/**
 *  数组中需要转换的模型类
 *
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class（Class类型）
 */
- (NSDictionary<NSString*, Class> *)objectClassInArray;

@end

NS_ASSUME_NONNULL_END
