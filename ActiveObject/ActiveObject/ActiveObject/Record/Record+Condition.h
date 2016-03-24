//
//  Record+Condition.h
//  Database
//
//  Created by Ansel on 16/3/24.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record.h"

@interface Record (Condition)

//重置筛选条件
- (void)resetAll;

/*
 *filed 可以是 NSString eg. @"age",
 *      也可以是NSArray  eg. [@"age", @"name"];
 */
- (void)setField:(id)field;
- (NSString *)field;

/**
 NSString:  age > 13 AND height < 40 AND weight  between 25 and 27 AND  name in ('Ansel', 'MJK') ... ,  //OR也行, 处理复杂情况
 NSDictionary: @{@"name" : @"Ansel",....}  //只处理等号
 */
- (void)setWhere:(id)where;
- (NSString *)where;

/**
 NSString   eg:@"name"  or @"age DESC, height ASC"
 NSDictionary eg:@{"ASC" : @["name", ...], @"DESC" : @["age", ...]};
 NSArray eg:@[@"name", ..]  or @[@"name DESC", @"age ASC", ...]
 */
- (void)setOrderBy:(id)orderBy;
- (NSString *)orderBy;

/**
 NSString   eg:@"name, ....."
 NSArray eg:@[@"name",...]
 */
- (void)setGroupBy:(id)groupBy;
- (NSString *)groupBy;

/**
* NSString:  sum(salary) = '100' AND ...  //OR也行, 处理复杂情况  参考where
* NSDictionary: @{@"sum(salary)" : @"100",....}   //只处理等号
*/
- (void)setHaving:(id)having;
- (NSString *)having;

/**
 *start : 开始位置
 *size: 查询的数目
 */
- (void)setLimitWithStart:(NSUInteger)start size:(NSUInteger)size;
- (NSString *)limit;

/**
* @{@"name" : @"Ansel", ....}
*/

- (void)setUpdateField:(NSDictionary *)updateField;
- (NSString *)updateField;

@end
