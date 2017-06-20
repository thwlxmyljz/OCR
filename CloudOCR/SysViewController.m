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
#import "UIViewController+SlideMenuControllerOC.h"

@interface SysViewController ()

@end

@implementation SysViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [BooksOp RoundBeautifulButton:self.btnSave];
    [BooksOp RoundBeautifulButton:self.btnCancel];
    
    if (self.SaveType == EM_SysSaveType_SvrAddr)
        self.edtValue.text = [BooksOp Instance].SvrAddr;
    else if (self.SaveType == EM_SysSaveType_ThirdAddr)
        self.edtValue.text = [BooksOp Instance].ThirdSvrAddr;
    
    [self.edtValue becomeFirstResponder];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self removeGestures];
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
    if (self.SaveType == EM_SysSaveType_SvrAddr){
        //识别服务器地址
        [BooksOp Instance].SvrAddr = newValue;
    }
    else if (self.SaveType == EM_SysSaveType_ThirdAddr){
        //三方服务器地址
        [BooksOp Instance].ThirdSvrAddr = newValue;
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
