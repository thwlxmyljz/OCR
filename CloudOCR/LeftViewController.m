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
    
    NSMutableDictionary* _tableData;
}

@property (retain, nonatomic) ImageHeaderView *imageHeaderView;

@end

NSString* g_OcrClass[] = {@"个人证件",@"金融票据",@"商业票据"};

@implementation LeftViewController

@synthesize delegate = _delegate;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _tableData = [[NSMutableDictionary alloc] init];
    [_tableData setObject:[OcrType Personals] forKey:g_OcrClass[0]];
    [_tableData setObject:[OcrType Financials] forKey:g_OcrClass[1]];
    [_tableData setObject:[OcrType Commercials] forKey:g_OcrClass[2]];
    
    //_headView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headshow4"]];
    //[self.view addSubview:_headView];
    
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
    NSArray* objs = [_tableData objectForKey:g_OcrClass[section]];
    return objs.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sizeof(g_OcrClass)/sizeof(NSString*);
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * view = [[UILabel alloc] init];
    view.backgroundColor = SECTIONBKCOLOR;
    view.font = [UIFont systemFontOfSize:14.0f];
    view.frame = CGRectMake(0, 0, tableView.frame.size.width, 32.0f);
    view.textColor = [UIColor colorFromHexString:@"689F38"];
    view.textAlignment = NSTextAlignmentLeft;
    view.text = [NSString stringWithFormat:@"  %@",g_OcrClass[section]];
    return view;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell *cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[BaseTableViewCell identifier]];
    NSArray* objs = [_tableData objectForKey:g_OcrClass[indexPath.section]];
    OcrType *ocrType = [objs objectAtIndex:indexPath.row];
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
    
    NSArray* objs = [_tableData objectForKey:g_OcrClass[indexPath.section]];
    OcrType *ocrType = [objs objectAtIndex:indexPath.row];
    [self.slideMenuController changeMainViewController:self.mainViewControler close:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeViewController:)]){
        [self.delegate changeViewController:ocrType];
    }
}

@end
