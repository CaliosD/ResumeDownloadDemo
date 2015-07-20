//
//  FileDownloadInfo.h
//  ResumeDownloadDemo
//
//  Created by Calios on 7/17/15.
//  Copyright (c) 2015 Calios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDownloadInfo : NSObject

@property (nonatomic,strong) NSString                 *fileTitle;
@property (nonatomic,strong) NSString                 *downloadSource;
@property (nonatomic,strong) NSString                 *downloadedSize;  // Calios: used to show progress when suspended.
@property (nonatomic,strong) NSString                 *totalSize;       // Calios: used to show progress when suspended.
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic,strong) NSData                   *taskResumeData;
@property (nonatomic       ) double                   downloadProgress;
@property (nonatomic       ) BOOL                     isDownloading;
@property (nonatomic       ) BOOL                     downloadComplete;
@property (nonatomic       ) unsigned long            taskIdentifier;

- (id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source;

@end
