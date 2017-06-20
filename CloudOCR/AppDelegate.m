//
//  AppDelegate.m
//  CloudOCR
//
//  Created by yiqiao on 2017/5/23.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "AppDelegate.h"
#import "OcrTableViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "SlideMenuController.h"
#import "UIColor+SlideMenuControllerOC.h"
#import "BooksOp.h"
#import "ViewController.h"
#import "constants.h"
#import "YQSlideMenuController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(void)createMenuView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    OcrTableViewController *mainViewController = (OcrTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"OcrTableViewController"];
    LeftViewController *leftViewController = (LeftViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LeftViewController"];
    RightViewController *rightViewController = (RightViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RightViewController"];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    [UINavigationBar appearance].tintColor = [UIColor darkGrayColor];//[UIColor colorFromHexString:@"689F38"];
    leftViewController.mainViewControler = nvc;
    leftViewController.delegate = mainViewController;
    
    YQSlideMenuController *slideMenuController = [[YQSlideMenuController alloc] initWithMainViewController:nvc leftMenuViewController:leftViewController rightMenuViewController:rightViewController];
    [slideMenuController changeLeftViewWidth:200];
    [slideMenuController changeRightViewWidth:SCREEN_WIDTH-20];//20要和storyboard的tableView的left约束一致
    slideMenuController.automaticallyAdjustsScrollViewInsets = YES;
    slideMenuController.delegate = mainViewController;
    self.window.backgroundColor = [UIColor colorWithRed:236.0 green:238.0 blue:241.0 alpha:1.0];
    self.window.rootViewController = slideMenuController;
    [self.window makeKeyWindow];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[BooksOp Instance] initializeDatabase];
    [self performSelectorInBackground:@selector(initOcr) withObject:nil];
    [self createMenuView];
    return YES;
}
-(void)initOcr
{
    [OcrTableViewController initOcrEngine];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[BooksOp Instance] finalizeDatabase];
    [OcrTableViewController unitOcrEngine];
}

@end
