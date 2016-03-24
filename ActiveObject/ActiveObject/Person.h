//
//  Person.h
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record.h"

@interface Person : Record

@property (nonatomic, assign) float height;
@property (nonatomic, assign) int age;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *cid;

@end
