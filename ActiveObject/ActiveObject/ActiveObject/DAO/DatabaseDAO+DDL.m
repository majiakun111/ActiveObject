//
//  DatabaseDAO+DDL.m
//  ActiveObject
//
//  Created by Ansel on 16/3/25.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "DatabaseDAO+DDL.h"
#import "ActiveObjectDefine.h"
#import "NSObject+Record.h"

@interface TableBuilder : NSObject

@property (nonatomic, strong) NSMutableDictionary *tableBuiltFlags;

+ (instancetype)sharedInstance;

- (BOOL)buildTable:(NSString *)tableName forClass:(Class)class untilRootClass:(Class)rootClass;

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

- (BOOL)buildTable:(NSString *)tableName forClass:(Class)class untilRootClass:(Class)rootClass
{
    BOOL buildFlag = [self isBuiltTable:tableName forClass:class];
    if (buildFlag) {
        return YES;
    }
    
    NSArray *propertyInfoList = [class getPropertyInfoListUntilRootClass:rootClass];
    if (!propertyInfoList || [propertyInfoList count] <= 0) {
        NSLog(@"Could not create not field table");
        return NO;
    }
    
    NSMutableArray *propertyAndTypeList = [[NSMutableArray alloc] init];
    [propertyInfoList enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull propertyInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        [propertyAndTypeList addObject:[NSString stringWithFormat:@"%@ %@", propertyInfo[PROPERTY_NAME], propertyInfo[DATABASE_TYPE]]];
    }];
    
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer primary key autoincrement, %@)", tableName, ROW_ID, [propertyAndTypeList componentsJoinedByString:@","]];
    BOOL result = [[DatabaseDAO sharedInstance] executeUpdate:sql];
    if (result) {
        [self.tableBuiltFlags setObject:@(YES) forKey:tableName];
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

- (BOOL)createTable:(NSString *)tableName forClass:(Class)class untilRootClass:(Class)rootClass
{
    return [[TableBuilder sharedInstance] buildTable:tableName forClass:class untilRootClass:rootClass];
}

- (BOOL)dropTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"drop table %@", tableName];
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
    NSString *sql = [NSString stringWithFormat:@"drop index %@", indexName];
    
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
