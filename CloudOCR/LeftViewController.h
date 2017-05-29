//
//  LeftViewController.h
//  SlideMenuControllerOC
//
//  Created by ChipSea on 16/2/27.
//  Copyright © 2016年 pluto-y. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OcrType;

@protocol LeftMenuProtocol <NSObject>

@required
-(void)changeViewController:(OcrType*) selType;

@end

@interface LeftViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) UIViewController *mainViewControler;

@property (retain, nonatomic) id<LeftMenuProtocol> delegate;

@end
