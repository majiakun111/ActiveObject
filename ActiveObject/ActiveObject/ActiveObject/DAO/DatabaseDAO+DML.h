//
//  DatabaseDAO+DML.h
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseDAO.h"

@interface DatabaseDAO (DML)

- (BOOL)insertWithFields:(NSString *)field values:(NSString *)values forTable:(NSString *)tableName;

- (BOOL)deleteWithWhere:(NSString *)where forTable:(NSString *)tableName;

- (BOOL)deleteAllForTable:(NSString *)tableName;

- (BOOL)updateWithUpdateField:(NSString *)updateField where:(NSString *)where forTable:(NSString *)tableName;
@end
