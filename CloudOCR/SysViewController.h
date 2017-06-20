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

typedef NS_ENUM(NSInteger, EM_SysSaveType){
    EM_SysSaveType_SvrAddr,
    EM_SysSaveType_ThirdAddr
};

@interface SysViewController : UIViewController

@property (nonatomic, assign) EM_SysSaveType SaveType;

@property (weak, nonatomic) IBOutlet UITextField *edtValue;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@end
