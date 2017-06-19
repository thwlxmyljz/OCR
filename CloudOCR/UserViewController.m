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

@interface UserViewController ()

@end

@implementation UserViewController

@synthesize clickRow = _clickRow;
@synthesize clickSection = _clickSection;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edtUser.text = [BooksOp Instance].UserId;
    self.edtPwd.text = [BooksOp Instance].UserPwd;
    self.edtPwd.secureTextEntry = YES;
    [self.edtUser becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [self OnCancel:sender];
}

- (IBAction)OnCancel:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RightViewController *v = (RightViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"RightViewController"];
    [self.slideMenuController changeRightViewController:v close:FALSE];
}
@end
