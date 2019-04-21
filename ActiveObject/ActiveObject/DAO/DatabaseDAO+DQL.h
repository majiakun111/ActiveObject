//
//  DatabaseDAO+DQL.h
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseDAO.h"

@interface DatabaseDAO (DQL)

- (NSArray <__kindof NSDictionary *> *)queryWithColumns:(NSString *)field where:(NSString *)where groupBy:(NSString *)groupBy having:(NSString *)having orderBy:(NSString *)orderBy limit:(NSString *)limit forTable:(NSString *)tableName;

@end
