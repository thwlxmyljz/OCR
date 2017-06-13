//
//  YQSlideMenuController.m
//  CloudOCR
//
//  Created by yiqiao on 2017/6/13.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "YQSlideMenuController.h"
#import "RightViewController.h"
#import "OcrTableViewController.h"

@interface YQSlideMenuController ()

@end

@implementation YQSlideMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (void)openRight
{
    NSLog(@"open right");
    
    UINavigationController *nvc = (UINavigationController *)self.mainViewController;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RightViewController *rightViewController = (RightViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RightViewController"];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:nil];
    nvc.navigationController.navigationItem.backBarButtonItem = backItem;
    
    [nvc pushViewController:rightViewController animated:TRUE];
    
}
 */
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
