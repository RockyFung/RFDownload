//
//  ViewController.m
//  LessonDownload
//
//  Created by lanou on 15/11/11.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import "ViewController.h"
#import "DownLoad.h"
#import "DownloadManagment.h"
#import "DB.h"
@interface ViewController ()
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) DownLoad *download;

@property (weak, nonatomic) IBOutlet UILabel *progress;

@property (weak, nonatomic) IBOutlet UILabel *savePath;

@property (weak, nonatomic) IBOutlet UILabel *progress2;

@property (weak, nonatomic) IBOutlet UILabel *savePath2;

@end

@implementation ViewController


// 开始按钮
- (IBAction)btn1:(UIButton *)sender {
    
    [self.download resume];
}

// 暂停按钮
- (IBAction)btn2:(UIButton *)sender {
    
    [self.download suspend];
}

 
 
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DB open];
    
    // 创建单例
    DownloadManagment *downloadManagemnt = [DownloadManagment shareDownloadManagment];
    DownLoad *download = [downloadManagemnt addDownloadWithURL:@"http://baobab.cdn.wandoujia.com/14465602996337.mp4"];
    [download resume];
    
    [download downloadFinish:^(NSString *savePath) {
        self.savePath.text = savePath;
    } Downloading:^(float progress, float bytesWritten) {
        self.progress.text = [NSString stringWithFormat:@"%.1f %%",progress];
    }];
    
    
    self.download = download;
    
    
    /*
//    http://baobab.cdn.wandoujia.com/1447163643457322070435.mp4
    DownloadManagment *downloadManagemnt2 = [DownloadManagment shareDownloadManagment];
    DownLoad *download2 = [downloadManagemnt2 addDownloadWithURL:@"http://baobab.cdn.wandoujia.com/1447163643457322070435.mp4"];
    [download2 resume];
    
    [download2 downloadFinish:^(NSString *savePath) {
        self.savePath2.text = savePath;
    } Downloading:^(float progress, float bytesWritten) {
        self.progress2.text = [NSString stringWithFormat:@"%.1f %%",progress];
    }];
    */
    
    
    
    
    
    
    // 创建NSURLSession有几种方式
    // 1.单例创建
//    NSURLSession *session = [NSURLSession sharedSession];
    
    
    // 2.根据 NSURLSessionConfiguration 创建一个对象
    // NSURLSessionConfiguration的作用；指定一个下载完成存放的位置和下载类型
    // NSURLSessionConfiguration 的初始化方法,作用是什么
    //  》1.defaultSessionConfiguration 返回一个默认配置，下载信息保存在硬盘中（沙盒中）
    //  》2.ephemeralSessionConfiguration 下载的信息保存在内存中，和缓冲区中，但是程序退出或者系统断电，文件都会消失
    //  》3.backgroundSessionConfigurationWithIdentifier 开辟子线程下载数据，可能会导致下载失败，因为子线程有下载限制
//    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:cfg];
    
    
    // 3.根据NSURLSessionConfiguration创建一个对象，并且指定一个代理，还有一个下载队列
//    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    
    // 创建我们的DownloadTask
//    self.task = [session downloadTaskWithURL:[NSURL URLWithString:@"http://baobab.cdn.wandoujia.com/14465602996337.mp4"]];
    
    /*
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[NSURL URLWithString:@"http://baobab.cdn.wandoujia.com/14465602996337.mp4"] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 1.NSURL location 我们下载完成后的位置
        // 2.NSURLResponse response 下载文件的相关信息
        // 3.NSError error 下载错误的信息
        NSLog(@"%@",location);
        
    }];
   */
    // 开启
//    [_task resume];
    
   
    
    
}




/*

#pragma mark - 完成下载代理方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location;
{
    // location 我们下载完成后的位置
    // 把下载完成的文件转移，不然会被系统删除
    // 1.获取沙盒路径
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject];
    // downloadTask.response.suggestedFilename 使用服务器使用的名字
    NSString *savePath = [cache stringByAppendingPathComponent:downloadTask.response.suggestedFilename]; // 新保存文件地址
    NSLog(@"保存地址 %@",savePath);
    // 2.创建NSFileManager，进行文件转移
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // 3.转移文件（保存文件）
    [fm moveItemAtPath:location.path toPath:savePath error:nil];
    
    
    
}

#pragma mark - 显示下载进度方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // 1.bytesWritten 本次下载的字节数，下载速度
    // 2.totalBytesWritten 一共下载了多少字节数
    // 3.totalBytesExpectedToWrite 数据总字节数
    
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    NSLog(@"%f",progress);
    
}

*/








@end
