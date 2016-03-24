//
//  Record+DQL.h
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record.h"
//SELECT 查询中字句的位置
//SELECT
//FROM
//WHERE
//GROUP BY
//HAVING
//ORDER BY
//LIMIT

@interface Record (DQL)

- (NSArray <Record *> *)query;

- (NSArray <Record *> *)queryAll;

/*
 * 返回的不是 Record的数据结构 
 * eg select sum(salary) as salary_sum from tableName group by name
 */
- (NSArray <NSDictionary *> *)queryDictionary;

@end
