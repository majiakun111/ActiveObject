//
//  Record.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record.h"
#import "Record+DDL.h"
#import "Record+Condition.h"

@interface Record ()
{
    NSMutableDictionary<NSString *, Class> *_arrayTransformerModelClassMap;
}

@end

@implementation Record

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createTable];
        [self resetAll];
        
        _arrayTransformerModelClassMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (NSString *)tableName
{
    return [[self class] tableName];
}

+ (NSString *)tableName
{
    return NSStringFromClass([self class]);
}

- (void)arrayTransformerWithModelClass:(Class)class forKeyPath:(NSString *)keyPath
{
    [_arrayTransformerModelClassMap setObject:class forKey:keyPath];
}

- (Class)getArrayTransformerModelClassWithKeyPath:(NSString *)keyPath
{
    return [_arrayTransformerModelClassMap objectForKey:keyPath];
}

- (NSDictionary<NSString *, Class> *)getArrayTransformerModelClassMap
{
    return _arrayTransformerModelClassMap;
}

#pragma mark -Overrride 避免崩溃

- (void)setNilValueForKey:(NSString *)key
{
#ifdef DEBUG
    NSLog(@"%@", NSStringFromSelector(_cmd));
#endif
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
#ifdef DEBUG
    NSLog(@"%@", NSStringFromSelector(_cmd));
#endif
}

@end
