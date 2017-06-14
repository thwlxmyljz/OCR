//
//  TableViewShower.h
//  CloudOCR
//
//  Created by yiqiao on 2017/5/26.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OcrCard.h"
#import "OcrType.h"

@class OcrTableViewController;
@class OcrCard;

//将TableViewShower的KeyName设置到KEYNAME_NULL,会将识别列表全部归类到#分组下，然后隐藏tableview的分组，达到可控制的分组显示
#define KEYNAME_NULL @"1234"

//ocr历史记录列表显示控制
@interface TableViewShower  : NSObject <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign) EMOcrClass OcrClass;//显示的ocr类型
@property (nonatomic,strong) NSString* KeyName;//关键属性名
@property (nonatomic,strong) UITableView* tableView;//tableView
@property (nonatomic,strong) OcrTableViewController* Owner;//tableView controller

@property (nonatomic,strong) NSMutableArray* Keys;//关键属性名首字母表
@property (nonatomic,strong) NSMutableDictionary* CardDict;//按关键名词首字母排列的OcrCard数据


//没有自定义的TableViewShower调用此公共
-(void)BaseSetUp:(UITableView*) tableView WithClass:(EMOcrClass)clas;

//派生类调用
-(void)Setup:(UITableView*) tableView;

//释放数据
-(void)UnloadData;

-(void)FreshOcrCard:(int)cardId Operator:(int)op;

-(OcrCard*)GetCard:(NSIndexPath *)indexPath;

@end
