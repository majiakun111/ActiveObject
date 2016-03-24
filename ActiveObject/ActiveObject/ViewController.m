//
//  ViewController.m
//  Database
//
//  Created by Ansel on 16/3/21.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "ViewController.h"
#import "DatabaseQueue.h"
#import "Database.h"
#import "Database+Transaction.h"

#import "Person.h"
#import "Record+DDL.h"
#import "Record+DML.h"
#import "Record+DQL.h"
#import "Record+Condition.h"

@interface ViewController ()

@property (nonatomic, strong) DatabaseQueue *databaseQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    Person *person = [[Person alloc] init];
    person.height = 78;
    person.age = 35;
    person.name = @"wqr";
    person.cid  = @"3";
    
    [person save];
    
    person.height = 17;
    person.age = 35;
    person.name = @"dff";
    person.cid  = @"4";
    [person save];
    
    [person setUpdateField:@{@"name" : @"Ansel"}];
    [person setWhere:@{@"cid" : @"4"}];
    
    BOOL result = [person update];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
