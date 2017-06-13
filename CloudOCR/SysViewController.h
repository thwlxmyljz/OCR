//
//  SysViewController.h
//  CloudOCR
//
//  Created by yiqiao on 2017/6/13.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputDelegate <NSObject>

@required

-(void) Save:(NSString*)newValue;

@end

@interface SysViewController : UIViewController

@property (nonatomic, strong) NSString* oldValue;
@property (nonatomic, assign) int clickSection;
@property (nonatomic, assign) int clickRow;

@property (weak, nonatomic) IBOutlet UITextField *edtValue;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@end
