//
//  DBManager.h
//  SQLiteBrowser
//
//  Created by Archuthan Vijayaratnam on 2/16/2014.
//  Copyright (c) 2014 Archuthan Vijayaratnam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject

+ (instancetype) sharedManager;
- (BOOL) openDatabase:(NSString *)dbPath completion:(void(^)(BOOL success, NSString *path, int sqliteStatus, NSString *error))completion;
- (NSString *) getSQLiteErrorMessage;

@end
