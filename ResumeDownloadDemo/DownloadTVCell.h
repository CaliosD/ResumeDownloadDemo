//
//  DownloadTVCell.h
//  ResumeDownloadDemo
//
//  Created by Calios on 7/15/15.
//  Copyright (c) 2015 Calios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileDownloadInfo.h"

@protocol DownloadTVCellDelegate <NSObject>

- (void)startOrPauseDownloadingSingleFile:(UIButton *)sender;
- (void)stopDownloading:(UIButton *)sender;

@end

@interface DownloadTVCell : UITableViewCell

@property (nonatomic, strong) UILabel                *nameLabel;
@property (nonatomic, strong) UIButton               *downloadBtn;// Download or pause button.
@property (nonatomic, strong) UIButton               *stopBtn;
@property (nonatomic, strong) UIProgressView         *progressView;
@property (nonatomic, strong) UILabel                *progressLabel;

@property (nonatomic, assign) id<DownloadTVCellDelegate> delegate;

- (void)configureWithData:(FileDownloadInfo *)file;

@end
