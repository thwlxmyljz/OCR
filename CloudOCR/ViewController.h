//
//  ViewController.h
//  HexMOcrSample
//
//  Created by Hex on 15/5/27.
//  Copyright (c) 2015年 Hex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HexMOcr.h" 
#import "OcrType.h"
#import "OcrCard.h"

typedef NS_ENUM(NSInteger, EMOcrAction) {
    EMOcrAction_Photo,
    EMOcrAction_Camera
};

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

//新建调用
@property (nonatomic,assign) EMOcrAction OcrAction;
@property (nonatomic,assign) EMOcrClass OcrClass;
@property (nonatomic,strong) UIImage*   OcrImage;
@property (nonatomic,strong) NSMutableDictionary* OcrData;

//编辑调用
@property (nonatomic,strong) OcrCard* ModifyCard;

-(void)OnBack:(id)sender;

+(CGFloat) SectionHeight;

@end

