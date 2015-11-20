//
//  DownloadManagment.h
//  LessonDownload
//
//  Created by lanou on 15/11/11.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownLoad.h"
@interface DownloadManagment : NSObject

// 单例初始化方法
+(instancetype)shareDownloadManagment;

// 根据URL添加一个下载类
- (DownLoad *)addDownloadWithURL:(NSString *)url;

// 根据URL找到一个下载类
- (DownLoad *)findDownloadWithURL:(NSString *)url;

// 返回所有正在下载的类
- (NSArray *)allDownload;

@end
