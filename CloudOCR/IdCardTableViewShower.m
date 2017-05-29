//
//  IdCardTableViewController.m
//  CloudOCR
//
//  Created by yiqiao on 2017/5/24.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "IdCardTableViewShower.h"
#import "UIViewController+SlideMenuControllerOC.h"
#import "UITableView+SlideMenuControllerOC.h"
#import "IdCardTableCell.h"
#import "DataTableViewCell.h"
#import "OcrCard.h"
#import "Chk2Asi.h"
#import "UIColor+SlideMenuControllerOC.h"
#import "CardKey.h"
#import "OcrType.h"

@interface IdCardTableViewShower ()
{
}
@end

@implementation IdCardTableViewShower

#pragma mark - Table view data source
-(void)Setup:(UITableView*) tableView
{
    [tableView registerCellNib:[IdCardTableCell class]];
    self.OcrClass = Class_Personal_IdCard;
    self.KeyName = IDCARD_KEY_NAME;
    
    [super Setup:tableView];
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  [IdCardTableCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IdCardTableCell *cell = (IdCardTableCell *)[tableView dequeueReusableCellWithIdentifier:[IdCardTableCell identifier]];
    IdCardTableCellData *data = [IdCardTableCellData new];
    
    OcrCard* ocrdata = [self GetCard:indexPath];
    data.image = ocrdata.CardImg;
    [data loadData:ocrdata.CardDetail];
    
    [cell setData:data];
    return cell;
}

@end
