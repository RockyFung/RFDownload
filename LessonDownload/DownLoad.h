//
//  DownLoad.h
//  LessonDownload
//
//  Created by lanou on 15/11/11.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import <Foundation/Foundation.h>

// 下载完成后调用的Block,参数是下载完成后的地址
typedef void (^DownloadFinish) (NSString *savePath);

// 下载中调用的block，参数是当前进度和当前速度
typedef void (^Downloading) (float progress , float bytesWritten);

// 下载完成的回调方法（用户不要使用，系统内部使用，目的是使该对象被销毁，如果使用以后会造成无法被销毁）
typedef void (^DownloadComplted) (NSString *url);





@interface DownLoad : NSObject

@property (nonatomic, strong, readonly) NSString *url; // 返回该下载类的url


// ⚠️下载完成的回调方法（用户不要使用，系统内部使用，目的是使该对象被销毁，如果使用以后会造成无法被销毁）
- (void)downloadComplted:(DownloadComplted)complted __deprecated_msg("⚠️使用此方法后，会造成内存泄露。此方法是内部使用的");

// 下载中的状态，block回调
- (void)downloadFinish:(DownloadFinish)downloadFinish Downloading:(Downloading)downloading;

// 根据url创建一个下载类
- (instancetype)initWithURL:(NSString *)url;

// 开始、继续
- (void)resume;

// 暂停
- (void)suspend;


@end
