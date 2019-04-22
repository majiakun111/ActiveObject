//
//  DatabaseDAO+DML.m
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "DatabaseDAO+DML.h"

@implementation DatabaseDAO (DML)

- (BOOL)insertWithFields:(NSString *)fields values:(NSString *)values forTable:(NSString *)tableName
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"insert into %@ (%@) values (%@)", tableName, fields, values];

    return [self executeUpdate:sql];
}

- (BOOL)deleteWithWhere:(NSString *)where forTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ %@", tableName, where];
    return [self executeUpdate:sql];
}

- (BOOL)deleteAllForTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@", tableName];
    return [self executeUpdate:sql];
}

- (BOOL)updateWithUpdateField:(NSString *)updateField where:(NSString *)where forTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ %@", tableName, updateField, where];
    return [self executeUpdate:sql];
}

@end
