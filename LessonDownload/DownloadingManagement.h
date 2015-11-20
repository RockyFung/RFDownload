//
//  DownloadingManagement.h
//  LessonDownload
//
//  Created by lanou on 15/11/12.
//  Copyright © 2015年 RockyFung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadingManagement : NSObject

@property (nonatomic, copy) NSString *resumeDataStr;

@property (nonatomic, copy) NSString *fileSize;

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, assign) float progress;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) double time;

@end
