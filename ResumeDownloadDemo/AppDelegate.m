//
//  AppDelegate.m
//  ResumeDownloadDemo
//
//  Created by Calios on 7/14/15.
//  Copyright (c) 2015 Calios. All rights reserved.
//

#import "AppDelegate.h"
#import "SimpleDownloadViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) UIImageView *splashView;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    SimpleDownloadViewController *downloadViewController = [[SimpleDownloadViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:downloadViewController];
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
    // Add local notification.
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone) {
    }
    else{
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    }
    
    // Change splash imageview.
    _splashView = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [_splashView setImage:[UIImage imageNamed:@"Default-568h"]];
    
    return YES;
}

// 后台下载的处理
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.backgroundTransferCompletionHandler = completionHandler;
}

// 调用过用户注册通知方法后执行。
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings != UIUserNotificationTypeNone) {
//        [self addLocalNotification];
    }
}

// 进入前台后设置消息信息
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [_splashView removeFromSuperview];
}

// 后台获取
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNewData);
}

// 设置后台显示图片
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.window addSubview:_splashView];
    [self.window bringSubviewToFront:_splashView];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
