//
//  BankTableViewController.m
//  CloudOCR
//
//  Created by yiqiao on 2017/5/24.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "BankTableViewShower.h"
#import "UIViewController+SlideMenuControllerOC.h"
#import "OcrType.h"
#import "UITableView+SlideMenuControllerOC.h"
#import "BankTableCell.h"
#import "DataTableViewCell.h"
#import "CardKey.h"
#import "UIColor+SlideMenuControllerOC.h"

@interface BankTableViewShower ()
{
}
@end

@implementation BankTableViewShower

-(void)Setup:(UITableView*) tableView
{
    [tableView registerCellNib:[BankTableCell class]];
    self.KeyName = BANKCARD_KEY_BANKNAME_CH;
    self.OcrClass = Class_Personal_BankCard;
    
    [super Setup:tableView];
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  [BankTableCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BankTableCell *cell = (BankTableCell *)[tableView dequeueReusableCellWithIdentifier:[BankTableCell identifier]];
    BankTableCellData *data = [BankTableCellData new];
    
    OcrCard* ocrdata = [self GetCard:indexPath];
    data.image = ocrdata.CardImg;
    data.BankName = [ocrdata.CardDetail objectForKey:BANKCARD_KEY_BANKNAME_CH];
    data.BankNo = [ocrdata.CardDetail objectForKey:BANKCARD_KEY_CARDNO_CH];
    
    [cell setData:data];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
