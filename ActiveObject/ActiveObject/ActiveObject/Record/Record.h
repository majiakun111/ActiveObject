//
//  Record.h
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseDAO.h"

/**
*1. 支持的属性类型: 整形, 浮点型, NSNumber, NSString, NSArray, NSDictionary, Record
*2. 若属性是NSArray 可以存 Record (但是必须调用 arrayTransformerWithModelClass: forPropertyName: 指定NSArray存的是那个Class, 支持嵌套), 也可以存 NSNumber, NSString, NSArray, NSDictionary
*3. NSDictionary(不能包含 Record对象)
*4. 支持迁移
*5. 对于column add and delete, index add and delete支持自动迁移, 只需要更改DatabaseVersion即可和配置
*/

@interface Record : NSObject

@property (nonatomic, assign) NSInteger rowId; //与 ROW_ID 对应,是 primary key autoincrement

+ (NSString *)tableName;

- (NSString *)tableName;

- (void)arrayContainerClass:(Class)class forPropertyName:(NSString *)propertyName;

- (Class)arrayContainerClassForPropertyName:(NSString *)propertyName;

#pragma mark - May Override

/** 
 *    {
 *      columnName -> {}
 *    }
 *
 *    {
 *       @"age" :  @"check (age >= 0)",
 *       @"name" : @"not null",
 *       @"cid"  : @"unique not null",
 *       @"telphones" : @"default ''"
 *    }
 *
 */

//此方法返回置建表时列的约束
+ (NSDictionary<NSString*, NSString*> *)constraints;

/**
 *    {
 *      columnName -> {}
 *    } 
 *
 *    {
 *       @"age" :  {
 *                     INDEX_NAME: @"age_index",
 *                     IS_UNIQUE: @(NO),
 *                 },
 *       @"idNo":  {
 *                     INDEX_NAME: @"idNo_index",
 *                     IS_UNIQUE: @(YES),
 *                 },
 *    }
 *
 */

//此方法需要建立的索引
+ (NSDictionary<NSString*, NSDictionary*> *)indexes;

@end
