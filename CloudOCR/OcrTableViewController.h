//
//  OcrTableViewController.h
//  CloudOCR
//
//  Created by yiqiao on 2017/5/24.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideMenuController.h"
#import "LeftViewController.h"

@class OcrCard;

@interface OcrTableViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(void) OnSelectOcrCard:(OcrCard*)card;
-(void) OnSetting;

+(void) initOcrEngine;
+(void) unitOcrEngine;

@end
