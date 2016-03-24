//
//  Record+DDL.m
//  Database
//
//  Created by Ansel on 16/3/22.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Record+DDL.h"
#import "DatabaseDAO.h"
#import "NSObject+Record.h"

@interface TableBuilder : NSObject

@property (nonatomic, strong) NSMutableDictionary *tableBuiltFlags;

+ (instancetype)sharedInstance;

- (BOOL)buildTableForClass:(Class)class;

- (BOOL)buildTableForClass:(Class)class untilRootClass:(Class)rootClass;

@end

@implementation TableBuilder

+ (instancetype)sharedInstance
{
    static TableBuilder *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == instance) {
            instance = [[TableBuilder alloc] init];
        }
    });
    
    return instance;
}


- (BOOL)buildTableForClass:(Class)class
{
    return [self buildTableForClass:class untilRootClass:nil];
}

- (BOOL)buildTableForClass:(Class)class untilRootClass:(Class)rootClass
{
    BOOL buildFlag = [self isTableBuiltForClass:class];
    if (buildFlag) {
        return YES;
    }

    NSArray *propertyAndTypeList = [class getPropertyAndTypeListUntilRootClass:rootClass];
    if (!propertyAndTypeList || [propertyAndTypeList count] <= 0) {
        NSLog(@"Could not create not field table");
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (rowId integer primary key autoincrement, %@)", [(Record *)class tableName], [propertyAndTypeList componentsJoinedByString:@","]];
    BOOL result = [DATABASE executeUpdate:sql];
    if (result) {
        [self.tableBuiltFlags setObject:@(YES) forKey:[(Record *)class tableName]];
    }
    
    return result;
}

#pragma mark - PrivateMethod

- (BOOL)isTableBuiltForClass:(Class)class
{
    BOOL result = NO;
    
    NSString * tableName = [(Record *)class tableName];
    NSNumber * builtFlag = [self.tableBuiltFlags objectForKey:tableName];
    if ( builtFlag && builtFlag.boolValue ) {
        result = YES;
    }
    
    return result;
}

#pragma mark - property

- (NSMutableDictionary *)tableBuiltFlags
{
    if (nil == _tableBuiltFlags) {
        _tableBuiltFlags = [[NSMutableDictionary alloc] init];
    }
    
    return _tableBuiltFlags;
}

@end


@implementation Record (DDL)

- (BOOL)createTable
{
    return [[TableBuilder sharedInstance] buildTableForClass:[self class] untilRootClass:[Record class]];
}

- (BOOL)dropTable
{
    NSString *sql = [NSString stringWithFormat:@"drop table %@", [self tableName]];
    return [DATABASE executeUpdate:sql];
}

- (BOOL)createIndex:(NSString *)indexName onColumn:(id)column isUnique:(BOOL )isUnique
{
    NSString *unique = @"";
    NSString *indexColumn = nil;
    if (isUnique) {
        unique = @"UNIQUE";
    }
    
    if ([column isKindOfClass:[NSString class]]) {
        indexColumn = column;
    } else if ([column isKindOfClass:[NSArray class]]) {
        indexColumn = [column componentsJoinedByString:@", "];
    }
    
    NSString *sql = [NSString stringWithFormat:@"create %@ index if not exists %@ on %@ (%@)", unique, indexName, [self tableName], indexColumn];
    
    return [DATABASE executeUpdate:sql];
}

- (BOOL)dropIndex:(NSString *)indexName
{
    NSString *sql = [NSString stringWithFormat:@"drop index %@", indexName];
    
    return [DATABASE executeUpdate:sql];
}

- (BOOL)renameToNewName:(NSString *)tableNewName
{
    NSString *sql = [NSString stringWithFormat:@"alter table %@ RENAME TO %@", [self tableName], tableNewName];

    return [DATABASE executeUpdate:sql];
}

- (BOOL)addColumn:(NSString *)column type:(NSString *)type
{
    return [self addColumn:column type:type constraint:nil];
}

- (BOOL)addColumn:(NSString *)column type:(NSString *)type constraint:(NSString *)constraint
{
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add column %@ %@ ", [self tableName], column, type];
    if (constraint) {
        sql = [sql stringByAppendingString:constraint];
    }
    
    return [DATABASE executeUpdate:sql];
}

@end
