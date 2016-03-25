//
//  BankCard.h
//  ActiveObject
//
//  Created by Ansel on 16/3/24.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record.h"

@interface BankCard : Record

@property (nonatomic, strong) NSString *cardId;
@property (nonatomic, copy) NSString *money;

@end
