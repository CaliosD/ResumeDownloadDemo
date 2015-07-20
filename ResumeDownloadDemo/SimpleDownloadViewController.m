//
//  SimpleDownloadViewController.m
//  ResumeDownloadDemo
//
//  Created by Calios on 7/14/15.
//  Copyright (c) 2015 Calios. All rights reserved.
//

#import "SimpleDownloadViewController.h"
#import "AppDelegate.h"
#import "DownloadTVCell.h"
#import "FileDownloadInfo.h"

#define BaseURL @"http://192.168.1.183:8899/download/"
#define DownloadCellIdentif    @"DownloadCellIdentif"

#define CellLabelTagValue               10
#define CellStartPauseButtonTagValue    20
#define CellStopButtonTagValue          30
#define CellProgressBarTagValue         40
#define CellLabelReadyTagValue          50

@interface SimpleDownloadViewController ()<UITableViewDelegate,UITableViewDataSource,NSURLSessionDelegate,DownloadTVCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *rightItem;
@property (nonatomic, strong) NSArray *data;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableArray *arrFileDownloadData;
@property (nonatomic, strong) NSURL *docDirectoryURL;

- (void)initializeFileDownloadDataArray;
- (int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier;

@end

@implementation SimpleDownloadViewController

- (void)initializeFileDownloadDataArray
{
    _arrFileDownloadData = [[NSMutableArray alloc]init];
    
//    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"iOS Programming Guide" andDownloadSource:@"https://developer.apple.com/library/ios/documentation/iphone/conceptual/iphoneosprogrammingguide/iphoneappprogrammingguide.pdf"]];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"Networking Overview" andDownloadSource:@"https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/NetworkingOverview.pdf"]];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"AV Foundation" andDownloadSource:@"https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf"]];
//    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"iPhone User Guide" andDownloadSource:@"http://manuals.info.apple.com/MANUALS/1000/MA1565/en_US/iphone_user_guide.pdf"]];

}

- (void)viewDidLoad
{
    [self initializeFileDownloadDataArray];
    
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    self.docDirectoryURL = [URLs objectAtIndex:0];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.BGTransferDemo"];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 1;
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    
    _tableView = [[UITableView alloc]initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _rightItem = [[UIBarButtonItem alloc]initWithTitle:@"全部下载" style:UIBarButtonItemStylePlain target:self action:@selector(startAllDownloads)];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"全部取消" style:UIBarButtonItemStylePlain target:self action:@selector(stopAllDownloads)];
    self.navigationItem.rightBarButtonItems = @[_rightItem,cancelItem];
}

#pragma mark - Private

- (NSString *)localeFullPathWithFile:(NSString *)file
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

- (NSString *)fileSizeWithBytes:(long long)bytes
{
    NSString *sizeString;
    if (bytes < 1024*1024*1024) {
        sizeString = [NSString stringWithFormat:@"%.2fM",(float)bytes/1024/1024];
    }
    else{
        sizeString = [NSString stringWithFormat:@"%.2fG",(float)bytes/1024/1024/1024];
    }
    
    return sizeString;
}

- (int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier
{
    int index = 0;
    for (int i = 0; i < _arrFileDownloadData.count; i++) {
        FileDownloadInfo *fdi = [_arrFileDownloadData objectAtIndex:i];
        if (fdi.taskIdentifier == taskIdentifier) {
            index = i;
            break;
        }
    }
    return index;
}

#pragma mark - Actions

- (void)startAllDownloads
{
    for (int i = 0; i < _arrFileDownloadData.count; i++) {
        FileDownloadInfo *fdi = [_arrFileDownloadData objectAtIndex:i];
        
        if (!fdi.isDownloading) {
            if (fdi.taskIdentifier == -1) {
                fdi.downloadTask = [_session downloadTaskWithURL:[NSURL URLWithString:fdi.downloadSource]];
            }
            else{
                fdi.downloadTask = [_session downloadTaskWithResumeData:fdi.taskResumeData];
            }
            fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
            
            [fdi.downloadTask resume];
            
            fdi.isDownloading = YES;
        }
    }
    
    [_tableView reloadData];
}

- (void)stopAllDownloads
{
    for (int i = 0; i < _arrFileDownloadData.count; i++) {
        FileDownloadInfo *fdi = [_arrFileDownloadData objectAtIndex:i];
        
        if (fdi.isDownloading) {
            [fdi.downloadTask cancel];
            
            fdi.isDownloading = NO;
            fdi.taskIdentifier = -1;
            fdi.downloadProgress = 0.0;
            fdi.downloadedSize = @"0.0M";
            fdi.totalSize = @"0.0M";
            fdi.downloadTask = nil;
        }
    }
    [_tableView reloadData];
}

- (void)initializeAll
{
    
}

#pragma mark - DownloadTVCellDelegate

- (void)startOrPauseDownloadingSingleFile:(UIButton *)sender
{
    // Calios: Get the position of pressed button and the index of cel.
    // Ref: http://stackoverflow.com/questions/4103643/custom-uitableviewcell-and-ibaction
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath != nil) {
        FileDownloadInfo *fdi = [_arrFileDownloadData objectAtIndex:indexPath.row];
        if (!fdi.isDownloading) {
            
            // Create a new task, but check whether it should be created using a URL or resume data.
            if (fdi.taskIdentifier == -1) {
                // If the taskIdentifier property of the fdi object has value -1, then create a new task
                // providing the appropriate URL as the download source.
                fdi.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:fdi.downloadSource]];
                
                // Keep the new task identifer.
                fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
                
                // Start the task.
                [fdi.downloadTask resume];
            }
            else{
                // Create a new download task, which will use the stored resume data.
                fdi.downloadTask = [_session downloadTaskWithResumeData:fdi.taskResumeData];
                [fdi.downloadTask resume];
                
                // Keep the new download task identifier.
                fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
            }
        }
        else{
            // Pause the task by canceling it and storing the resume data.
            [fdi.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                if (resumeData != nil) {
                    fdi.taskResumeData = [[NSData alloc] initWithData:resumeData];
                }
            }];
        }
        
        fdi.isDownloading = !fdi.isDownloading;
        
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)stopDownloading:(UIButton *)sender
{
    // Calios: exactly the same as above to get index of cell.
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath != nil) {
        FileDownloadInfo *fdi = [_arrFileDownloadData objectAtIndex:indexPath.row];
        [fdi.downloadTask cancel];
        
        fdi.isDownloading = NO;
        fdi.taskIdentifier = -1;
        fdi.downloadProgress = 0.0;
        fdi.downloadedSize = @"0.0M";
        fdi.totalSize = @"0.0M";
        
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *destinationFilename = downloadTask.originalRequest.URL.lastPathComponent;
    NSURL *destinationURL = [_docDirectoryURL URLByAppendingPathComponent:destinationFilename];
    NSLog(@"destination url: %@",destinationURL);
    
    if ([fileManager fileExistsAtPath:[destinationURL path]]) {
        [fileManager removeItemAtURL:destinationURL error:nil];
    }
    
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationURL error:&error];
    if (success) {
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        FileDownloadInfo *fdi = [_arrFileDownloadData objectAtIndex:index];
        
        fdi.isDownloading = NO;
        fdi.downloadComplete = YES;
        
        fdi.taskIdentifier = -1;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }else{
        NSLog(@"Unable to copy temp file. Error: %@",[error localizedDescription]);
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error != nil) {
        NSLog(@"Download completed with error: %@", [error localizedDescription]);
    }
    else{
        NSLog(@"Download finished successfully.");
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        NSLog(@"Unknown transfer size");
    }
    else{
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            fdi.downloadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
            fdi.downloadedSize = [self fileSizeWithBytes:totalBytesWritten];
            fdi.totalSize = [self fileSizeWithBytes:totalBytesExpectedToWrite];
            
            DownloadTVCell *cell = (DownloadTVCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            cell.progressView.progress = fdi.downloadProgress;
            cell.progressLabel.text = [NSString stringWithFormat:@"%@/%@",fdi.downloadedSize,fdi.totalSize];
        }];
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [_session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (downloadTasks.count == 0) {
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
                
                appDelegate.backgroundTransferCompletionHandler = nil;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionHandler();
                    
                    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
                    localNotification.alertBody = @"All files have been downloaded!";
                    localNotification.applicationIconBadgeNumber = 1;
                    localNotification.alertAction = @"Open it";
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }];
            }
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrFileDownloadData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadTVCell *cell = [tableView dequeueReusableCellWithIdentifier:DownloadCellIdentif];
    if (!cell) {
        cell = [[DownloadTVCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DownloadCellIdentif];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell configureWithData:(FileDownloadInfo *)[_arrFileDownloadData objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
