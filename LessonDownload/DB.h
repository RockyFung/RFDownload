//
//  DB.h
//  LessonDownload
//
//  Created by lanou on 15/11/12.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "DownloadingManagement.h"
#import "DownloadManagementFinish.h"



@interface DB : NSObject

+ (sqlite3 *)open;

+ (void)close;

// 返回所有下载完成的数据
+ (NSArray *)allDownloadFinish;

// 返回左右正在下载的数据
+ (NSArray *)allDownloading;

// 添加一个下载完成的数据（内部已实现对正在下载的删除）
+ (void)addDownloadFinishWithFinish:(DownloadManagementFinish *)finish;

// 添加一个正在下载的数据
+ (void)addDownloadingWithDownloading:(DownloadingManagement *)downloading;

// 根据url找到一个下载完成的数据
+ (DownloadManagementFinish *)findDownloadFinishWithURL:(NSString *)url;

// 根据url找到一个下载中的数据
+ (DownloadingManagement *)findDownloadingWithURL:(NSString *)url;

// 根据url删除一个下载完成的数据
+ (void)deleteDownloadFinishWithURL:(NSString *)url;

// 根据url删除一个下载中的数据
+ (void)deleteDownloadingWithURL:(NSString *)url;

// 根据url改变一个下载中的进度显示
+ (void)updateDownloadProgress:(int)progress WithURL:(NSString *)url;



































@end
