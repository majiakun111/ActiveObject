//
//  DatabaseDAO+DQL.m
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "DatabaseDAO+DQL.h"

@implementation DatabaseDAO (DQL)

- (NSArray <__kindof NSDictionary *> *)queryWithColumns:(NSString *)field where:(NSString *)where groupBy:(NSString *)groupBy having:(NSString *)having orderBy:(NSString *)orderBy limit:(NSString *)limit forTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@ %@ %@ %@ %@ %@", field, tableName, where, groupBy, having, orderBy, limit];

    return [self executeQuery:sql];
}

@end
