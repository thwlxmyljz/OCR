//
//  SysViewController.m
//  CloudOCR
//
//  Created by yiqiao on 2017/6/13.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "SysViewController.h"
#import "SlideMenuController.h"
#import "BooksOp.h"
#import "RightViewController.h"

@interface SysViewController ()

@end

@implementation SysViewController

@synthesize oldValue = _oldValue;
@synthesize clickRow = _clickRow;
@synthesize clickSection = _clickSection;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [BooksOp RoundBeautifulButton:self.btnSave];
    [BooksOp RoundBeautifulButton:self.btnCancel];
    
    self.edtValue.text = self.oldValue;
    if (self.clickSection == 0 && (self.clickRow == 1)){
        self.edtValue.text = [BooksOp Instance].UserPwd;
        self.edtValue.secureTextEntry = YES;
    }
    else{
        self.edtValue.secureTextEntry = NO;
    }
    [self.edtValue becomeFirstResponder];
}
- (IBAction)onCancel:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RightViewController *v = (RightViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"RightViewController"];
    [self.slideMenuController changeRightViewController:v close:FALSE];
}
- (IBAction)onSave:(id)sender {
    [self Save:self.edtValue.text];
    
    [self onCancel:sender];
}
-(void) Save:(NSString*)newValue
{
    if (_clickSection == 0){
        if (_clickRow == 0){
            //用户名
            [BooksOp Instance].UserId = newValue;
        }
        else if (_clickRow == 1){
            //密码
            [BooksOp Instance].UserPwd = newValue;
        }
    }
    else if (_clickSection == 1){
        if (_clickRow == 0){
            //识别服务器地址
            [BooksOp Instance].SvrAddr = newValue;
        }
        else if (_clickRow == 1){
            //三方服务器地址
            [BooksOp Instance].ThirdSvrAddr = newValue;
        }
    }
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

@end
