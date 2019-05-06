//
//  ViewController.m
//  Database
//
//  Created by Ansel on 16/3/21.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "ViewController.h"
#import "ActiveObject.h"

#import "Person.h"
#import "BankCard.h"
#import "TestDatabaseMigrator.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *databasePath = [documentDirectory stringByAppendingPathComponent:@"Test.db"];
    [[DatabaseDAO sharedInstance] configDatabasePath:databasePath databaseVersion:@"2.0"];
    
    TestDatabaseMigrator *databaseMigrator = [[TestDatabaseMigrator alloc] init];
    [[DatabaseDAO sharedInstance] setDatabaseMigrator:databaseMigrator];
    
    Person *person = [[Person alloc] init];
    
    person.age = 35;
    person.height = 170.5;
    person.weight = 120;
    person.name = @"Ansel";
    person.cid = @"17";
    person.telphones = @[@"138", @"135"];
    person.info = @{@"hello" : @"world"};
    person.address = @"Beijing";
    
    BankCard *mainBankCard = [[BankCard alloc] init];
    mainBankCard.cardId = @"1234567890";
    mainBankCard.money = @"1300000000";
    person.mainBankCard = mainBankCard;
    
    BankCard *bankCard1 = [[BankCard alloc] init];
    bankCard1.cardId = @"54567683421";
    bankCard1.money = @"213456578900";
    
    BankCard *bankCard2 = [[BankCard alloc] init];
    bankCard2.cardId = @"987654321";
    bankCard2.money = @"54657875643";
    
    person.bankCards =@[bankCard1, bankCard2];
    
    [person save];
//
//    NSArray <Person *> *persons = [person query];
//
//    [person setWhere:@{@"cid" : @"15"}];
//    [person delete];
//
//    [person setWhere:nil];
//
//    persons = [person query];


//for (NSInteger index = 0; index < 6; index++) {
//    [[AsyncQueue sharedInstance] inDatabase:^{
//        NSLog(@"xxxxx: %@", [NSThread currentThread]);
//        [person save];
//    } forSqlType:SqlForDMLType];
//}
    
    //for (NSInteger index = 0; index < 6; index++) {
        [[AsyncQueue sharedInstance] inDatabase:^{
            NSArray<Person *> *persons = [person query];
            NSLog(@"xxxxx: %@,  yyyy:%@", [NSThread currentThread], persons);
        } forSqlType:SqlForDQLType];
    //}
    //
    //    person.height = 17;
    //    person.age = 35;
    //    person.name = @"dff";
    //    person.cid  = @"4";
    //    [person save];
    //
    //    [person setUpdateField:@{@"name" : @"Ansel"}];
    //    [person setWhere:@{@"cid" : @"4"}];
    //
    //    BOOL result = [person update];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
