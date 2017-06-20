//
//  UserViewController.m
//  CloudOCR
//
//  Created by yiqiao on 2017/6/19.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "UserViewController.h"
#import "SlideMenuController.h"
#import "BooksOp.h"
#import "RightViewController.h"
#import "constants.h"
#import "NotificationView.h"
#import "NSNotificationAdditions.h"
#import "UIViewController+SlideMenuControllerOC.h"

@interface UserViewController ()
{
    NSString* _oldUserId;
}
@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _oldUserId = [NSString stringWithString:[BooksOp Instance].UserId];
    self.edtUser.text = [BooksOp Instance].UserId;
    self.edtPwd.text = [BooksOp Instance].UserPwd;
    self.edtPwd.secureTextEntry = YES;
    [self.edtUser becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self removeGestures];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)OnSave:(id)sender {
    
    [BooksOp Instance].UserId = self.edtUser.text;
    [BooksOp Instance].UserPwd = self.edtPwd.text;
    
    if (![[BooksOp Instance].UserId isEqualToString:@""] && ![[BooksOp Instance].UserId isEqualToString:_oldUserId]){
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NOTIFY_USERCHANGE object:nil
                                                                          userInfo:nil];
    }
    [self OnCancel:sender];
}

- (IBAction)OnCancel:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RightViewController *v = (RightViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"RightViewController"];
    [self.slideMenuController changeRightViewController:v close:FALSE];
}
@end
