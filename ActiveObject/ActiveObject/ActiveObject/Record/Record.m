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
#import <objc/runtime.h>

//下面静态无需初始化，因为用于关联对象的key的时候只会用到其地址
static const char * kAssociatedArrayContainerClassMapDictioanry;

@implementation Record

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createTable];
        [self resetAll];
        
        [self setupArrayContaineClassMapDictioanry];
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

- (void)arrayContainerClass:(Class)class forPropertyName:(NSString *)propertyName
{
    NSMutableDictionary *arrayContainerClassMapDictioanry = objc_getAssociatedObject(self.class, &kAssociatedArrayContainerClassMapDictioanry);
    [arrayContainerClassMapDictioanry setObject:class forKey:propertyName];
}

- (Class)arrayContainerClassForPropertyName:(NSString *)propertyName
{
    NSMutableDictionary *arrayContainerClassMapDictioanry = objc_getAssociatedObject(self.class, &kAssociatedArrayContainerClassMapDictioanry);
    return [arrayContainerClassMapDictioanry objectForKey:propertyName];
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
    NSLog(@"WARNING: %@ %@ %@", NSStringFromClass([self class]),  NSStringFromSelector(_cmd), key);
#endif
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
#ifdef DEBUG
    NSLog(@"WARNING: %@ setValue:%@ forUndefinedKey:%@", NSStringFromClass([self class]),  value, key);
#endif
}

- (id)valueForUndefinedKey:(NSString *)key {
#ifdef DEBUG
    NSLog(@"WARNING: %@ %@ %@", NSStringFromClass([self class]),  NSStringFromSelector(_cmd), key);
#endif
    
    return nil;
}

#pragma mark - PrivateMethod

//此Dictionary可以用来描述model容器中元素对应的类@{"propertyNameA":ClassA}
- (void)setupArrayContaineClassMapDictioanry
{
    if (objc_getAssociatedObject(self.class, &kAssociatedArrayContainerClassMapDictioanry) == nil) {
        NSMutableDictionary *arrayContaineClassMapDictioanry = [[NSMutableDictionary alloc] init];
        
        objc_setAssociatedObject(self.class, &kAssociatedArrayContainerClassMapDictioanry, arrayContaineClassMapDictioanry, OBJC_ASSOCIATION_RETAIN);
        
        arrayContaineClassMapDictioanry = nil;
    }
}

@end
