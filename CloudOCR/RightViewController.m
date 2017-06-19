//
//  RightViewController.m
//  SlideMenuControllerOC
//
//  Created by ChipSea on 16/2/27.
//  Copyright © 2016年 pluto-y. All rights reserved.
//

#import "RightViewController.h"
#import "BooksOp.h"
#import "constants.h"
#import "UIColor+SlideMenuControllerOC.h"
#import "BooksOp.h"
#import "UIViewController+SlideMenuControllerOC.h"
#import "RightViewController.h"
#import "SlideMenuController.h"
#import "UserViewController.h"

@interface RightViewController()
{
    int _clickSection;
    int _clickRow;
}
@property (nonatomic,strong) UISwitch* swSvr;

@end

@implementation RightViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.frame = self.view.frame;
    self.view.alpha = 1.0f;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel* titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    titleView.text = @"设置";
    titleView.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableHeaderView = titleView;
    
    [BooksOp setExtraCellLineHidden:self.tableView];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else if (section == 1)
        return 3;
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * view = [[UILabel alloc] init];
    view.backgroundColor = SECTIONBKCOLOR;
    view.font = [UIFont systemFontOfSize:15.0f];
    view.frame = CGRectMake(0, 0, tableView.frame.size.width, 32.0f);
    view.textColor = [UIColor colorFromHexString:@"689F38"];
    view.textAlignment = NSTextAlignmentLeft;
    if (section == 0)
        view.text = @"  用户";
    else if (section == 1)
        view.text = @"  服务器";
    else
        view.text = @"";
    return view;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleValue1
                             reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:14.5 weight:-0.15];
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            cell.textLabel.text = @"用户名";
            cell.detailTextLabel.text = [BooksOp Instance].UserId;
        }
    }
    else if (indexPath.section == 1){
        if (indexPath.row == 0){
            cell.textLabel.text = @"识别保存到云端";
            self.swSvr = [[UISwitch alloc] init];
            self.swSvr.on = [BooksOp Instance].SvrScan;
            [self.swSvr addTarget:self action:@selector(onSW:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.swSvr;
        }
        else if (indexPath.row == 1){
            cell.textLabel.text = @"识别服务器";
            cell.detailTextLabel.text = [BooksOp Instance].SvrAddr;
        }
        else if (indexPath.row == 2){
            cell.textLabel.text = @"三方服务器";
            cell.detailTextLabel.text = [BooksOp Instance].ThirdSvrAddr;
        }
    }
    return cell;
}
-(void)onSW:(id)sw
{
    [BooksOp Instance].SvrScan = self.swSvr.on?1:0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    if (indexPath.section == 1 && indexPath.row == 0){
        //上传到云端是开关控制
        return;
    }
    _clickSection = (int)indexPath.section;
    _clickRow = (int)indexPath.row;
    
    if (indexPath.section == 0 && indexPath.row == 0){
        //用户设置
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UserViewController *v = (UserViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"UserViewController"];
        v.clickSection = _clickSection;
        v.clickRow = _clickRow;
        [self.slideMenuController changeRightViewController:v close:FALSE];
    }
    else{
        //其他单项设置
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SysViewController *v = (SysViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"SysViewController"];
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        v.oldValue = cell.detailTextLabel.text;
        v.clickSection = _clickSection;
        v.clickRow = _clickRow;
        [self.slideMenuController changeRightViewController:v close:FALSE];
    }
}
@end
