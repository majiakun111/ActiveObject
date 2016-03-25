//
//  DatabaseDAO+Additions.h
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseDAO.h"

@interface DatabaseDAO (Additions)

- (long long)lastInsertRowId;

- (NSArray <NSDictionary *> *)getTableInfoForTable:(NSString *)tableName;

@end
