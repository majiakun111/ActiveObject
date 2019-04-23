//
//  JSONModel.h
//  ActiveObject
//
//  Created by Ansel on 2016/10/24.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import <UIKit/UIKit.h>

//还需要考虑 model key 和 json key的映射
@interface JSONModel : NSObject

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
