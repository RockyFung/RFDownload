//
//  SqliteManager.h
//  LessonDownload
//
//  Created by lanou on 15/11/11.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface SqliteManager : NSObject

// 单例
+ (SqliteManager *)shareInstance;

// 打开数据库（程序在第一次运行的时候会创建数据库，非第一次运行的时候，已经有了数据库，则直接打开）
- (sqlite3 *)openDB;

// 在数据库中创建表
- (void)creatTableWithTableName:(NSString *)tableName style:(NSString *)style;

@end
