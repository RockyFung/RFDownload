//
//  DownloadManagment.m
//  LessonDownload
//
//  Created by lanou on 15/11/11.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import "DownloadManagment.h"



@interface DownloadManagment()

@property (nonatomic, strong) NSMutableDictionary *downloadingDic;

@end


@implementation DownloadManagment

// 单例初始化方法
+(instancetype)shareDownloadManagment
{
    static DownloadManagment *downloadManagement = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManagement = [[DownloadManagment alloc]init];
    });
    return downloadManagement;
}



// 初始化方法
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.downloadingDic = [NSMutableDictionary dictionary];
    }
    return self;
}



// 根据URL添加一个下载类
- (DownLoad *)addDownloadWithURL:(NSString *)url
{
    // 先从字典里面取对应的下载类
    DownLoad *download = self.downloadingDic[url];
    
    // 如果字典里面没有，就重新创建
    if (download == nil) {
        download = [[DownLoad alloc]initWithURL:url];
        // 添加到字典中
        [self.downloadingDic setObject:download forKey:url];
    }
    
    // 下载完成以后，让单例不在持有下载类，从字典里面移除
    [download downloadComplted:^(NSString *url) {
        [self.downloadingDic removeObjectForKey:url];
        NSLog(@"对象销毁");
    }];
    
    return download;
}



// 根据URL找到一个下载类
- (DownLoad *)findDownloadWithURL:(NSString *)url
{
    return self.downloadingDic[url];
}

// 返回所有正在下载的类
- (NSArray *)allDownload
{
    return [self.downloadingDic allValues];
}


@end
