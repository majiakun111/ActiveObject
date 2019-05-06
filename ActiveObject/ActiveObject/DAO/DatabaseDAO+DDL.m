//
//  DatabaseDAO+DDL.m
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 MJK. All rights reserved.
//

#import "DatabaseDAO+DDL.h"
#import "ActiveObjectDefine.h"
#import "PropertyAnalyzer.h"

@interface TableBuilder : NSObject

@property (nonatomic, strong) NSMutableDictionary *tableBuiltFlags;

+ (instancetype)sharedInstance;

- (BOOL)buildTable:(NSString *)tableName constraints:(NSDictionary *)constraints indexes:(NSDictionary *)indexes forClass:(Class)clazz untilRootClass:(Class)rootClazz;

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

- (BOOL)buildTable:(NSString *)tableName constraints:(NSDictionary *)constraints indexes:(NSDictionary *)indexes forClass:(Class)clazz untilRootClass:(Class)rootClazz
{
    BOOL buildFlag = [self isBuiltTable:tableName forClass:clazz];
    if (buildFlag) {
        return YES;
    }
    
    NSArray *propertyInfoList = [PropertyAnalyzer getPropertyInfoListForClass:clazz];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"create table if not exists %@ (%@ integer primary key autoincrement,", tableName, ROW_ID];
    
    NSInteger count = [propertyInfoList count];
    for (NSInteger i = 0; i < count; i++) {
        
        PropertyInfo *propertyInfo = propertyInfoList[i];
        if ([propertyInfo.propertyName isEqualToString:ROW_ID]) {
            continue;
        }
        
        [sql appendFormat:@" %@ %@", propertyInfo.propertyName, propertyInfo.databaseType];
        
        NSString *constraint = constraints[propertyInfo.propertyName];
        if (constraint) {
            [sql appendFormat:@" %@", constraint];
        }
        
        if (i != count -1) {
            [sql appendFormat:@","];
        } else {
            [sql appendFormat:@")"];
        }
        
    }
    
    //create table
    BOOL result = [[DatabaseDAO sharedInstance] executeUpdate:sql];
    if (result) {
        [self.tableBuiltFlags setObject:@(YES) forKey:tableName];
    }
    
    //create index
    for (NSString *columnName in indexes) {
        NSDictionary *indexInfo = indexes[columnName];
        [[DatabaseDAO sharedInstance] createIndex:indexInfo[INDEX_NAME] onColumn:columnName isUnique:[indexInfo[IS_UNIQUE] boolValue] forTable:tableName];
    }
    
    return result;
}

#pragma mark - PrivateMethod

- (BOOL)isBuiltTable:(NSString *)tableName forClass:(Class)class
{
    BOOL result = NO;
    
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


@implementation DatabaseDAO (DDL)

- (BOOL)createTable:(NSString *)tableName constraints:(NSDictionary<NSString* , NSString *> *)constraints indexes:(NSDictionary<NSString*, NSDictionary*> *)indexes forClass:(Class)clazz untilRootClass:(Class)rootClazz;
{
    return [[TableBuilder sharedInstance] buildTable:tableName constraints:constraints indexes:indexes forClass:clazz untilRootClass:rootClazz];
}

- (BOOL)dropTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"drop table if exists %@", tableName];
    return [self executeUpdate:sql];
}

- (BOOL)createIndex:(NSString *)indexName onColumn:(id)column isUnique:(BOOL )isUnique forTable:(NSString *)tableName
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
    
    NSString *sql = [NSString stringWithFormat:@"create %@ index if not exists %@ on %@ (%@)", unique, indexName, tableName, indexColumn];
    
    return [self executeUpdate:sql];
}

- (BOOL)dropIndex:(NSString *)indexName
{
    NSString *sql = [NSString stringWithFormat:@"drop index if exists %@", indexName];
    
    return [self executeUpdate:sql];
}

- (BOOL)renameTable:(NSString *)tableName toTableNewName:(NSString *)tableNewName
{
    NSString *sql = [NSString stringWithFormat:@"alter table %@ rename to %@", tableName, tableNewName];
    
    return [self executeUpdate:sql];
}

- (BOOL)addColumn:(NSString *)column type:(NSString *)type constraint:(NSString *)constraint forTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add column %@ %@ ", tableName, column, type];
    if (constraint) {
        sql = [sql stringByAppendingString:constraint];
    }
    
    return [self executeUpdate:sql];
}

@end
