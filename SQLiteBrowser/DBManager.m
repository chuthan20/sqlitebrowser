//
//  DBManager.m
//  SQLiteBrowser
//
//  Created by Archuthan Vijayaratnam on 2/16/2014.
//  Copyright (c) 2014 Archuthan Vijayaratnam. All rights reserved.
//

#import "DBManager.h"

@interface DBManager ()
@property (nonatomic) sqlite3* database;
@property (nonatomic) NSString* dbpath;
@end

@implementation DBManager

static DBManager *_sharedManager;
+ (instancetype) sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[[self class] alloc] init];
    });
    return _sharedManager;
}

- (NSString *) getSQLiteErrorMessage
{
    return [[NSString alloc] initWithFormat:@"%s", sqlite3_errmsg(_database)];
}

- (BOOL) openDatabase:(NSString *)dbPath completion:(void(^)(BOOL success, NSString *path, int sqliteStatus, NSString *error))completion
{
    _dbpath = dbPath;
    if (_database != NULL)
    {
        sqlite3_close(_database);
    }
    BOOL isSuccess = NO;
    int ret = sqlite3_open([_dbpath UTF8String], &_database);
    if (ret != SQLITE_OK)
    {
        isSuccess = NO;
        sqlite3_close(_database);
        _database = NULL;
        if (completion)
            completion(NO, _dbpath, ret, [[NSString alloc] initWithFormat:@"%s", sqlite3_errmsg(_database)]);
    }
    else
    {
        isSuccess = YES;
        if (completion)
            completion(YES, _dbpath, ret, nil);
    }
    return isSuccess;
}


- (void) executeQuery:(NSString *)query
            bindBlock:(void(^)(sqlite3_stmt *stmt))bindBlock
        columnHeaders:(void(^)(sqlite3_stmt *stmt, int index, NSString *name, NSString *type))columnHeaderBlock
            stepBlock:(void(^)(sqlite3_stmt *stmt))stepBlock
           completion:(void(^)(BOOL success, int status, NSString *error))completion
{

    sqlite3_stmt* statement = NULL;
    int status = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, NULL);
    if (status == SQLITE_OK)
    {
        if (bindBlock)
            bindBlock(statement);

        if (columnHeaderBlock)
        {
            for(int i=0; i<sqlite3_column_count(statement); i++)
            {
                const char *name = sqlite3_column_name(statement, i);
                const char *type = sqlite3_column_type(statement, i);

                NSString *identifier = [[NSString alloc] initWithFormat:@"%s",name];
                NSString *typeID = nil;

                if (type != NULL)
                    typeID = [[NSString alloc] initWithFormat:@"%s",type];

                columnHeaderBlock(statement, i, identifier, typeID);
            }
        }


        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            if (stepBlock)
                stepBlock(statement);
        }

        sqlite3_finalize(statement);
        if (completion)
            completion(YES, status, nil);
    }
    else
    {
        if (completion)
            completion(NO, status, [NSString stringWithFormat:@"%s", sqlite3_errmsg(_database)]);
    }
}
@end
