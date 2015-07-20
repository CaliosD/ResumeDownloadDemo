//
//  DownLoadModel.h
//  ResumeDownloadDemo
//
//  Created by Calios on 7/15/15.
//  Copyright (c) 2015 Calios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownLoadModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) float total;
@property (nonatomic, assign) float finished;
@property (nonatomic, assign) NSInteger index;

@end
