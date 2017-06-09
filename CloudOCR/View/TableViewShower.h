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

//ocr历史记录列表显示控制
@interface TableViewShower  : NSObject <UITableViewDataSource,UITableViewDelegate>

//OCR显示数据
@property (nonatomic,assign) EMOcrClass OcrClass;//显示的ocr类型
@property (nonatomic,strong) NSString* KeyName;//关键属性名
@property (nonatomic,strong) NSMutableArray* Keys;//关键属性名首字母表
@property (nonatomic,strong) NSMutableDictionary* CardDict;//按关键名词首字母排列的OcrCard数据
@property (nonatomic,strong) UITableView* tableView;//tableView
@property (nonatomic,strong) OcrTableViewController* Owner;//tableView controller

//没有自定义的TableViewShower调用此公共
-(void)BaseUp:(UITableView*) tableView WithClass:(EMOcrClass)clas WithKeyName:(NSString*)keyName;

//派生类调用
-(void)Setup:(UITableView*) tableView;

-(void)FreshOcrCard:(int)cardId Operator:(int)op;
-(OcrCard*)GetCard:(NSIndexPath *)indexPath;

@end
