//
//  FileDownloadInfo.m
//  ResumeDownloadDemo
//
//  Created by Calios on 7/17/15.
//  Copyright (c) 2015 Calios. All rights reserved.
//

#import "FileDownloadInfo.h"

@implementation FileDownloadInfo

- (id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source
{
    if (self == [super init]) {
        self.fileTitle = title;
        self.downloadSource = source;
        self.downloadProgress = 0.0;
        self.isDownloading = NO;
        self.downloadComplete = NO;
        self.taskIdentifier = -1;
        self.downloadedSize = @"0.0M";
        self.totalSize = @"0.0M";
    }
    return self;
}

@end
