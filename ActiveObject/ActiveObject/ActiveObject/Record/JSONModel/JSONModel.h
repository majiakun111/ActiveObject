//
//  JSONModel.h
//  ActiveObject
//
//  Created by Ansel on 2016/10/24.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <UIKit/UIKit.h>

//还需要考虑 model key 和 json key的映射
@interface JSONModel : NSObject

- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (id)initWithJSONDictionary:(NSDictionary *)dictionary error:(NSError **)error;

+ (id)modelWithJSONDictionary:(NSDictionary *)dictionary;
+ (id)modelWithJSONDictionary:(NSDictionary *)dictionary error:(NSError **)error;

- (NSDictionary *)toJSONDictionary;

- (void)arrayContainerClass:(Class)class forPropertyName:(NSString *)propertyName;

- (Class)arrayContainerClassForPropertyName:(NSString *)propertyName;

- (NSDictionary <NSString *, NSString *> *)jsonKeyToModelPropertyNameMap;

@end
