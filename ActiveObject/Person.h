//
//  Person.h
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"
#import "BankCard.h"

@interface Person : Record

@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat weight;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *cid;
@property (nonatomic, strong) NSArray *telphones;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, copy) NSString *address;

@property (nonatomic, strong) BankCard *mainBankCard;

@property (nonatomic, strong) NSArray<BankCard *> *bankCards; //副卡

@end
