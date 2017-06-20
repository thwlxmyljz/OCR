//
//  UserViewController.h
//  CloudOCR
//
//  Created by yiqiao on 2017/6/19.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UITextField *edtUser;
@property (weak, nonatomic) IBOutlet UITextField *edtPwd;

- (IBAction)OnSave:(id)sender;
- (IBAction)OnCancel:(id)sender;

@end
