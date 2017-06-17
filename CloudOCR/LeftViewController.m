//
//  LeftViewController.m
//  SlideMenuControllerOC
//
//  Created by ChipSea on 16/2/27.
//  Copyright © 2016年 pluto-y. All rights reserved.
//

#import "LeftViewController.h"
#import "OcrType.h"
#import "SlideMenuController.h"
#import "OcrTableViewController.h"
#import "BaseTableViewCell.h"
#import "UITableView+SlideMenuControllerOC.h"
#import "BooksOp.h"
#import "constants.h"
#import "UIColor+SlideMenuControllerOC.h"
#import "ImageHeaderView.h"
#import "UIView+SlideMenuController.h"

@interface LeftViewController ()
{
    UIImageView* _headView;//logo
    
    UIViewController* _bankViewController;
    UIViewController* _IdCardViewController;
    
    NSMutableArray* _tableSectionKeys;
}

@property (retain, nonatomic) ImageHeaderView *imageHeaderView;

@end


@implementation LeftViewController

@synthesize delegate = _delegate;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [BooksOp setExtraCellLineHidden:self.tableView];

    _tableSectionKeys = [NSMutableArray arrayWithArray:[[OcrType Ocrs] allKeys]];
  
    self.imageHeaderView = (ImageHeaderView *)[ImageHeaderView loadNib];
    [self.view addSubview:self.imageHeaderView];
    
    self.tableView.separatorColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1];
    [_tableView registerCellClass:[BaseTableViewCell class]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.imageHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
    [self.view layoutIfNeeded];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  [BaseTableViewCell height];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* ocrsForType = [[OcrType Ocrs] objectForKey:[_tableSectionKeys objectAtIndex:section]];
    return ocrsForType.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tableSectionKeys.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * view = [[UILabel alloc] init];
    view.backgroundColor = WEB_VIEWBK_COLOR;
    view.font = [UIFont systemFontOfSize:14.0f];
    view.frame = CGRectMake(0, 0, tableView.frame.size.width, 32.0f);
    view.textColor = [UIColor colorFromHexString:@"689F38"];
    view.textAlignment = NSTextAlignmentLeft;
    //view.text = [NSString stringWithFormat:@"  %@",g_OcrClass[section]];
    return view;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell *cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[BaseTableViewCell identifier]];
    NSArray* ocrsForType = [[OcrType Ocrs] objectForKey:[_tableSectionKeys objectAtIndex:indexPath.section]];
    OcrType *ocrType = [ocrsForType objectAtIndex:indexPath.row];
    [cell setData:ocrType.TypeName];
    if (ocrType.OcrClass == [BooksOp Instance].CurClass){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:FALSE];
    
    NSArray* ocrsForType = [[OcrType Ocrs] objectForKey:[_tableSectionKeys objectAtIndex:indexPath.section]];
    OcrType *ocrType = [ocrsForType objectAtIndex:indexPath.row];
    [self.slideMenuController changeMainViewController:self.mainViewControler close:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeViewController:)]){
        [self.delegate changeViewController:ocrType];
    }
}

@end
