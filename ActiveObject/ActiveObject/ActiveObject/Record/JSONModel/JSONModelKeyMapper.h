//
//  JSONModelKeyMapper.h
//  ActiveObject
//
//  Created by Ansel on 2016/10/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONModelKeyMapper : NSObject

//以JSON的key作为字典的key, 以model的属性作为字典的value
- (id)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)getModelProperyNameWithJSONKey:(NSString *)jsonKey;
- (NSString *)getJSONKeyWithModelPropertyName:(NSString *)propertyName;


@end
