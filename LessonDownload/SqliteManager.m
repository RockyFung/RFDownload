//
//  SqliteManager.m
//  LessonDownload
//
//  Created by lanou on 15/11/11.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import "SqliteManager.h"

static sqlite3 *db = nil;
@implementation SqliteManager
// 单例
+ (SqliteManager *)shareInstance
{
    static SqliteManager *sql = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sql = [[SqliteManager alloc]init];
    });
    return sql;
}

// 获取沙盒document下数据库的路径
- (NSString *)documentPathWithSqliteName:(NSString *)sqliteName
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject]stringByAppendingPathComponent:sqliteName];
}



// 打开数据库
- (sqlite3 *)openDB
{
    if (db != nil) {
        return db;
    }
    NSString *filePath = [self documentPathWithSqliteName:@"download.sqlite"];
    sqlite3_open([filePath UTF8String],&db);
    NSLog(@"%@",filePath);
    return db;
}

// 关闭数据库
- (void)closeDB
{
    sqlite3_close(db);
    db = nil;
}



// 在数据库中创建表
- (void)creatTableWithTableName:(NSString *)tableName style:(NSString *)style
{
    [self openDB];
    sqlite3_stmt *stmt = nil;
    NSString *string = [NSString stringWithFormat:@"create table if not exists %@ (%@)",tableName, style];
    NSInteger flag = sqlite3_prepare_v2(db, [string UTF8String], -1, &stmt, nil);
    NSLog(@"%ld",flag);
    if (SQLITE_OK == flag) {
        NSLog(@"创建表成功");
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
    [self closeDB];
}

















@end
