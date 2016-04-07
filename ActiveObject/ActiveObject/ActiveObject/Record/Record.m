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

//子类都需要重写
+(void)load
{
    registerConstraints([self tableName], [self constraints]);
    registerIndexes([self tableName], [self indexes]);
}

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

#pragma mark - HookMethod

+ (NSDictionary<NSString*, NSString*> *)constraints
{
    return nil;
}

+ (NSDictionary<NSString*, NSDictionary*> *)indexes
{
    return nil;
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
