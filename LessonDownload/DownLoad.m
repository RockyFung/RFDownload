//
//  DownLoad.m
//  LessonDownload
//
//  Created by lanou on 15/11/11.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import "DownLoad.h"
#import "SqliteManager.h"
#import "DownloadingManagement.h"
#import "DownloadManagementFinish.h"
#import "DB.h"

@interface DownLoad()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSessionDownloadTask *task;

// 定义两个block属性
@property (nonatomic, copy) DownloadFinish downloadFinish;

@property (nonatomic, copy) Downloading downloading;

@property (nonatomic, copy) DownloadComplted complted;

@property (nonatomic, strong) NSURLSession *session;

@end


@implementation DownLoad

{
    BOOL _isFirst; // 第一次走下载进度的时候，暂停保存数据
}

- (void)dealloc
{
    NSLog(@"对象被销毁");
}


// 根据url创建一个下载类
- (instancetype)initWithURL:(NSString *)url
{
    self = [super init];
    if (self) {
        
        _url = url;
        
        // 根据NSURLSessionConfiguration创建一个对象，并且指定一个代理，还有一个下载队列
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        
        // 创建我们的DownloadTask
        self.task = [_session downloadTaskWithURL:[NSURL URLWithString:url]];
        
        
        // 先去数据库中查找是否已经下载了，如果已经下载了，我们就把_isFirst赋值为YES，防止重复添加数据
        _isFirst = [DB findDownloadingWithURL:url];
        // 如果已经下载了，更换task
        if (_isFirst) {
            [self.task cancel];
            NSData *data = [self resumeDataWithURL:url];
            self.task = [self.session downloadTaskWithResumeData:data];
        }
    }
    return self;
}


- (NSData *)resumeDataWithURL:(NSString *)url
{
    // 1.找到下载中的model
    DownloadingManagement *downloading = [DB findDownloadingWithURL:url];
    
    // 2.获取当前下载文件的大小
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *nowFileSize = [NSString stringWithFormat:@"%llu",[fm attributesOfItemAtPath:downloading.filePath error:nil].fileSize];
    
    // 3.对resumeDataStr进行替换
    downloading.resumeDataStr = [downloading.resumeDataStr stringByReplacingOccurrencesOfString:downloading.fileSize withString:nowFileSize];
    
    // 4.生成NSData，返回
    return [downloading.resumeDataStr dataUsingEncoding:NSUTF8StringEncoding];
    
}



// ⚠️下载中的状态，block回调
- (void)downloadFinish:(DownloadFinish)downloadFinish Downloading:(Downloading)downloading
{
    self.downloadFinish = downloadFinish;
    self.downloading = downloading;
}


// ⚠️下载完成的回调方法（用户不要使用，系统内部使用，目的是使该对象被销毁，如果使用以后会造成无法被销毁）
- (void)downloadComplted:(DownloadComplted)complted
{
    self.complted = complted;
}




// 开始、继续
- (void)resume
{
    [self.task resume];
}

// 暂停
- (void)suspend
{
    [self.task suspend];
}



#pragma mark - 完成下载代理方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location;
{
    // location 我们下载完成后的位置
    // 把下载完成的文件转移，不然会被系统删除
    // 1.获取沙盒路径
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject];
    // downloadTask.response.suggestedFilename 使用服务器使用的名字
    NSString *savePath = [cache stringByAppendingPathComponent:downloadTask.response.suggestedFilename]; // 保存文件地址
    
    // 2.创建NSFileManager，进行文件转移
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // 3.转移文件（保存文件）
    [fm moveItemAtPath:location.path toPath:savePath error:nil];
    
    // 4.保存到数据库
    DownloadManagementFinish *finish = [[DownloadManagementFinish alloc]init];
    finish.url = self.url;
    finish.savePath = savePath;
    [DB addDownloadFinishWithFinish:finish];
    
    NSLog(@"下载完成数据保存地址 %@",savePath);
    

    // block 回调，添加一个判断，如果有实现，就调用
    if (self.downloadFinish) {
        self.downloadFinish(savePath);
    }
    
    // 下载完成后回调，目的是让单例不在持有该对象，从而可以删除
    if (self.complted) {
        self.complted(_url);
    }
    
}

#pragma mark - 显示下载进度方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
    // 定一个BOOL值，为NO的时候，暂停，把resumeData解析保存，再把值改为YES，让它继续下载，就不会再走暂停方法
    if (_isFirst == NO) {
        // 执行暂停方法
        [self cancelDownloadTask];
        _isFirst = YES;
    }
    
    
    
    // 1.bytesWritten 本次下载的字节数，下载速度
    // 2.totalBytesWritten 一共下载了多少字节数
    // 3.totalBytesExpectedToWrite 数据总字节数
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
//    NSLog(@"%f",progress);
    
    // 对数据库中的下载进度做更新
    [DB updateDownloadProgress:(int)(progress * 100)WithURL:self.url];
    
    
    // block回调
    if (self.downloading) {
        self.downloading(progress * 100,(float)bytesWritten);
    }
    
}

// 暂停task的方法
 - (void)cancelDownloadTask
{
    __weak typeof (self) vc = self;
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
       // 解析保存 resumeData
        [self parsingResumeData:resumeData];
        // 继续开始下载
        vc.task = [self.session downloadTaskWithResumeData:resumeData];
        [vc.task resume];
    }];
}

// 解析保存resumeData
- (void)parsingResumeData:(NSData *)resumeData
{
    NSString *resumeDataStr = [[NSString alloc]initWithData:resumeData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",resumeDataStr);
    
    // 截取fileSize字节
    // 截取指定字符串之后的字符串
    NSString *fileSize = [resumeDataStr componentsSeparatedByString:@"<key>NSURLSessionResumeBytesReceived</key>\n\t<integer>"].lastObject;
    // 截取指定字符串之前的字符串
    fileSize = [fileSize componentsSeparatedByString:@"</integer>"].firstObject;
    NSLog(@"%@",fileSize);
    
    // 截取filePath
    NSString *filePath = [resumeDataStr componentsSeparatedByString:@"<key>NSURLSessionResumeInfoTempFileName</key>\n\t<string>"].lastObject;
    filePath = [filePath componentsSeparatedByString:@"</string>"].firstObject;
     // Xcode7文件的截取需要做拼接
    NSString *tmp = NSTemporaryDirectory(); // tmp文件路径
    filePath = [tmp stringByAppendingPathComponent:filePath];
    NSLog(@"Xcode7下 %@",filePath);
    
    // Xcode6下
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath] == NO) { // 如果我们获取到的路劲打不开，就换种方式解析
        filePath = [resumeDataStr componentsSeparatedByString:@"<key>NSURLSessionResumeInfoLocalPath</key>\n\t<string>"].lastObject;
        filePath = [filePath componentsSeparatedByString:@"</string>"].firstObject;
        NSLog(@"Xcode6下 %@",filePath);
    }
    
    
    // 保存数据
    DownloadingManagement *downloading = [[DownloadingManagement alloc]init];
    downloading.resumeDataStr = resumeDataStr;
    downloading.fileSize = fileSize;
    downloading.filePath = filePath;
    downloading.url = self.url;
    
    // 保存到数据库
    [DB addDownloadingWithDownloading:downloading];
    
    
    
    
    
    
    
    // 我们需要数据库保存当前的信息
    /*
     1.resumeDataStr (NSString) 保存我们resumeData的数据，取出的时候做一个转码
     2.filePath (NSString) 我们要找到文件的路径并求出大小，做替换
     3.fileSize (int) 保存暂定下载后resumeData的文件大小，要知道和谁做替换
     4.progress (float) 下载的进度是多少
     5.url (NSString) 唯一标示，让我们知道在哪里能找到这条数据
     6.time (double) 添加下载的时间戳（创建数据库的时候，都带上这个属性，一定会用到，比如做一个排序）
     */
    
    // 下载完成需要的属性
    /*
     1.url (NSString) 唯一标示，让我们知道在哪里能找到这条数据
     2.savePath (NSString) 保存的路径
     3.time （double） 时间戳，用来排序
     */
    

    
}


























@end
