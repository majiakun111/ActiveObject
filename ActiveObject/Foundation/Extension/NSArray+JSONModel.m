//
//  NSArray+JSONModel.m
//  ActiveObject
//
//  Created by Ansel on 2016/10/24.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "NSArray+JSONModel.h"
#import "JSONModel.h"

@implementation NSArray (JSONModel)

- (NSArray *)modelArrayWithClass:(Class)modelClass
{
    NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    for (id object in self) {
        if ([object isKindOfClass:[NSArray class]]) {
            NSArray *subModelArray = [object modelArrayWithClass:modelClass];
            if (subModelArray) {
                [modelArray addObject:subModelArray];
            }
        } else if ([object isKindOfClass:[NSDictionary class]]){
            id model = [[modelClass alloc] initWithJSONDictionary:object];
            if (model) {
                [modelArray addObject:model];
            }
        } else{
            [modelArray addObject:object];
        }
    }
    
    return modelArray;
}


- (NSArray *)toJSONArray
{
    NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
    
    for (id object in self) {
        if ([object isKindOfClass:[JSONModel class]]) {
            NSDictionary *objectDictionary = [(JSONModel *)object toJSONDictionary];
            if (objectDictionary) {
                [jsonArray addObject:objectDictionary];
            }
        }else if ([object isKindOfClass:[NSArray class]]){
            NSArray *subJSONArray = [object toJSONArray];
            if (subJSONArray) {
                [jsonArray addObject:subJSONArray];
            }
        }else{
            [jsonArray addObject:object];
        }
    }
    
    return jsonArray;
}

@end
