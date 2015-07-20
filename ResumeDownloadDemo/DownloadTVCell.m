//
//  DownloadTVCell.m
//  ResumeDownloadDemo
//
//  Created by Calios on 7/15/15.
//  Copyright (c) 2015 Calios. All rights reserved.
//

#import "DownloadTVCell.h"
#import <PureLayout.h>
#import <AFNetworking.h>

@implementation DownloadTVCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _nameLabel                   = [[UILabel alloc]init];
        _downloadBtn                 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadBtn setBackgroundColor:[UIColor orangeColor]];
        [_downloadBtn setImage:[UIImage imageNamed:@"play-25"] forState:UIControlStateNormal];
        [_downloadBtn addTarget:self action:@selector(downloadBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        _stopBtn                     = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stopBtn setBackgroundColor:[UIColor orangeColor]];
        [_stopBtn setImage:[UIImage imageNamed:@"stop-25"] forState:UIControlStateNormal];
        [_stopBtn addTarget:self action:@selector(stopBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        _progressView                = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressLabel               = [[UILabel alloc]init];
        _progressLabel.font          = [UIFont systemFontOfSize:14.f];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_downloadBtn];
        [self.contentView addSubview:_stopBtn];
        [self.contentView addSubview:_progressView];
        [self.contentView addSubview:_progressLabel];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

#pragma mark - DownloadTVCellDelegate

- (void)downloadBtnPressed:(UIButton *)sender
{
    [self.delegate startOrPauseDownloadingSingleFile:sender];
    /*
    NSURL *url = [NSURL URLWithString:[_model.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    NSString *fullPath = [self fullPathWithFile:[url lastPathComponent]];
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        [_progressLabel setText:[NSString stringWithFormat:@"%@/%@",[self fileSizeWithBytes:totalBytesRead],[self fileSizeWithBytes:totalBytesExpectedToRead]]];
        _progressView.progress = (float)totalBytesRead/totalBytesExpectedToRead;
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //        NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
        
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        
        if (error) {
            NSLog(@"ERR: %@", [error description]);
            _progressView.progress = 0.0;
        } else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERR: %@", [error description]);
    }];
    
    [operation start];
     */
}

- (void)stopBtnPressed:(UIButton *)sender
{
    [self.delegate stopDownloading:sender];
}

#pragma mark - Private

- (void)updateConstraints
{
    [_nameLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(7, 10, 7, 110) excludingEdge:ALEdgeBottom];
    [_nameLabel autoSetDimension:ALDimensionHeight toSize:21];
    
    [@[_downloadBtn,_stopBtn] autoSetViewsDimensionsToSize:CGSizeMake(40, 25)];
    [_downloadBtn autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_stopBtn];
    [_downloadBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_nameLabel withOffset:17];
    [_downloadBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
    [_stopBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    
    [_progressView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_nameLabel withOffset:10];
    [_progressView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [_progressView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [_progressView autoSetDimension:ALDimensionHeight toSize:5];
    
    [_progressLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 7, 10) excludingEdge:ALEdgeTop];
    [_progressLabel autoSetDimension:ALDimensionHeight toSize:15];
    
    [super updateConstraints];
}

- (NSString *)fullPathWithFile:(NSString *)file
{
    NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Download"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if(![fileManager fileExistsAtPath:downloadPath isDirectory:&isDir])
    {
        [fileManager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fullPath = [downloadPath stringByAppendingPathComponent:file];
    return fullPath;
}

- (void)configureWithData:(FileDownloadInfo *)file
{
    _nameLabel.text = file.fileTitle;
    
    if (!file.isDownloading) {
//        _stopBtn.enabled = NO;
        
        BOOL isComplete = (file.downloadComplete) ? YES: NO;
        _downloadBtn.hidden = isComplete;
        _stopBtn.hidden = isComplete;
        
        if (isComplete) {
            _progressView.hidden = YES;
            _progressLabel.text = @"已下载";
        }
        else{
            _progressView.progress = file.downloadProgress;
            _progressLabel.text = [NSString stringWithFormat:@"%@/%@",file.downloadedSize,file.totalSize];
        }
    }
    else{
        _progressView.hidden = NO;
        _progressView.progress = file.downloadProgress;
//        _stopBtn.enabled = YES;
    }

    NSString *imgName = file.isDownloading ? @"pause-25" : @"play-25";
    [_downloadBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
}


@end
