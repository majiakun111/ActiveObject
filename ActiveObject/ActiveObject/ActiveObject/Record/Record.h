//
//  Record.h
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ROW_ID @"rowId"

/**
*1. 支持的属性类型: 整形, 浮点型, NSNumber, NSString, NSArray, NSDictionary, Record
*2. 若属性是NSArray 可以存 Record (但是必须调用 arrayTransformerWithModelClass: forKeyPath: 指定NSArray存的是那个Class, 也可以存 NSNumber, NSString, NSArray, NSDictionary
*3. NSDictionary(不能包含 Record对象)
*/

@interface Record : NSObject

- (NSString *)tableName;

// may override
+ (NSString *)tableName;

- (void)arrayTransformerWithModelClass:(Class)class forKeyPath:(NSString *)keyPath;

- (Class)getArrayTransformerModelClassWithKeyPath:(NSString *)keyPath;

- (NSDictionary<NSString *, Class> *)getArrayTransformerModelClassMap;

@end
