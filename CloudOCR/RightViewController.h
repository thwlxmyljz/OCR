//
//  RightViewController.h
//  SlideMenuControllerOC
//
//  Created by ChipSea on 16/2/27.
//  Copyright © 2016年 pluto-y. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SysViewController.h"


@interface RightViewController : UIViewController <InputDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
