//
//  JSONModelKeyMapper.m
//  ActiveObject
//
//  Created by Ansel on 2016/10/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "JSONModelKeyMapper.h"

@interface JSONModelKeyMapper()

@property(strong,nonatomic) NSMutableDictionary *jsonKeyToModelPropertyNameMap; //以JSON的key作为字典的key, 以model的属性作为字典的value
@property(strong,nonatomic) NSMutableDictionary *modelPropertyNameToJSONKeyMap; //以model的属性作为字典的key, 以JSON的key作为字典的value

@end

@implementation JSONModelKeyMapper

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self != nil) {
        self.jsonKeyToModelPropertyNameMap = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
        self.modelPropertyNameToJSONKeyMap = [[NSMutableDictionary alloc] initWithCapacity:[dictionary count]];
       
        for (NSString *key in dictionary) {
            self.modelPropertyNameToJSONKeyMap[dictionary[key]] = key;
        }
    }
    
    return self;
}


- (NSString *)getModelProperyNameWithJSONKey:(NSString *)jsonKey
{
    NSString *properyName =  [self.jsonKeyToModelPropertyNameMap objectForKey:jsonKey];
    return properyName ? properyName : jsonKey;
}

- (NSString *)getJSONKeyWithModelPropertyName:(NSString *)properyName
{
    NSString *jsonKey = [self.modelPropertyNameToJSONKeyMap objectForKey:properyName];
    return jsonKey ? jsonKey : properyName;
}

@end

