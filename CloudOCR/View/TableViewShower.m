//
//  TableViewShower.m
//  CloudOCR
//
//  Created by yiqiao on 2017/5/26.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "TableViewShower.h"
#import "CardTableViewCell.h"
#import "UITableView+SlideMenuControllerOC.h"
#import "BooksOp.h"
#import "constants.h"
#import "ViewController.h"
#import "UIColor+SlideMenuControllerOC.h"
#import "CardKey.h"
#import "OcrTableViewController.h"
#import "DataTableViewCell.h"

@implementation TableViewShower

@synthesize OcrClass = _OcrClass;
@synthesize Owner = _Owner;
@synthesize CardDict = _CardDict;
@synthesize Keys = _Keys;
@synthesize KeyName = _KeyName;

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return  [NSArray arrayWithArray: self.Keys];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSString *key = [self.Keys objectAtIndex:index];
    NSLog(@"sectionForSectionIndexTitle %@",key);
    if (key == UITableViewIndexSearch) {
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    return index;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.Keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString* keyStr = [self.Keys objectAtIndex:section];
    return ((NSMutableArray*)[self.CardDict objectForKey:keyStr]).count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * view = [[UILabel alloc] init];
    view.backgroundColor = SECTIONBKCOLOR;
    view.font = [UIFont systemFontOfSize:14.0f];
    view.frame = CGRectMake(0, 0, tableView.frame.size.width, 22);
    view.textColor = [UIColor colorFromHexString:@"689F38"];
    view.textAlignment = NSTextAlignmentLeft;
    view.text = [NSString stringWithFormat:@"  %@",[self.Keys objectAtIndex:section]];
    return view;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexpath{
    return @"删除";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        OcrCard* ocrdata = [self GetCard:indexPath];
        [self DeleteOcrCard:ocrdata];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OcrCard* ocrdata = [self GetCard:indexPath];
    [self.Owner OnSelectOcrCard:ocrdata];
}
-(void)BaseUp:(UITableView*) tableView WithClass:(EMOcrClass)clas WithKeyName:(NSString*)keyName
{
    [tableView registerCellNib:[DataTableViewCell class]];
    self.OcrClass = clas;
    self.KeyName = keyName;
    
    [self Setup:tableView];
    
}
-(void)Setup:(UITableView*) tableView
{
    self.tableView = tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionIndexColor = [UIColor colorFromHexString:@"689F38"];

    self.Keys = [[NSMutableArray alloc] init];
    self.CardDict = [OcrCard TransHeadedDict:[OcrCard Load:self.OcrClass] ForKey:self.KeyName ResultHeadKeys:self.Keys];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source


#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  [DataTableViewCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DataTableViewCell *cell = (DataTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[DataTableViewCell identifier]];
    DataTableViewCellData *data = [DataTableViewCellData new];
    
    OcrCard* ocrdata = [self GetCard:indexPath];
    data.image = ocrdata.CardImg;
    [data loadData:ocrdata.CardDetail];
    
    [cell setData:data];
    return cell;
}


-(OcrCard*)GetCard:(NSIndexPath *)indexPath
{
    if (!self.Keys || !self.CardDict){
        return nil;
    }
    return [[self.CardDict objectForKey:[self.Keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
}
-(void)InsertOcrCard:(OcrCard*)newCard
{
    NSString* chKey = [OcrCard GetHeadKey:[newCard.CardDetail objectForKey:self.KeyName]];
    for (NSString* key in self.Keys){
        if ([key isEqualToString:chKey]){
            [[self.CardDict objectForKey:chKey] insertObject:newCard atIndex:0];
            if (self.tableView){
                [self.tableView reloadData];
            }
            return;
        }
    }
    //新key
    [self.Keys addObject:chKey];
    [self.CardDict setValue:[[NSMutableArray alloc] init] forKey:chKey];
    [[self.CardDict objectForKey:chKey] insertObject:newCard atIndex:0];
    [OcrCard SortHeadKeys:self.Keys];
    if (self.tableView){
        [self.tableView reloadData];
    }
}
-(void)UpdateOcrCard:(OcrCard*)newCard
{
    for (NSString* key in [self.CardDict allKeys]){
        NSMutableArray* array = [self.CardDict objectForKey:key];
        for (int idx = 0; idx < array.count; idx++){
            OcrCard* oldCard = [array objectAtIndex:idx];
            if (oldCard.CardId == newCard.CardId){
                [array replaceObjectAtIndex:idx withObject:newCard];
                if (self.tableView){
                    [self.tableView reloadData];
                }
                return;
            }
        }
    }
}
-(void)DeleteOcrCard:(OcrCard*)ocrdata
{
    if (ocrdata && [ocrdata Delete]){
        for (NSString* key in [self.CardDict allKeys]){
            NSMutableArray *value = [self.CardDict objectForKey:key];
            for (OcrCard* deldata in value){
                if ([deldata isEqual:ocrdata] ){
                    [value removeObject:deldata];
                    if (value.count == 0){
                        [self.CardDict removeObjectForKey:key];
                        [self.Keys removeObject:key];
                    }
                    [self.tableView reloadData];
                    return;
                }
            }
        }
    }
}
-(void)FreshOcrCard:(int)cardId Operator:(int)op
{
    OcrCard* newCard = [OcrCard LoadOne:cardId];
    if (!newCard){
        NSLog(@"not load new card");
        return;
    }
    if (op == 1){
        [self InsertOcrCard:newCard];
        return;
    }
    if (op == 2){
        [self UpdateOcrCard:newCard];
        return;
    }
}
@end
