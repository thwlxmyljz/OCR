//
//  SelType.m
//  HexOCR
//
//  Created by yiqiao on 2017/5/22.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "OcrType.h"
#import "BankTableCell.h"

@implementation OcrType

@synthesize OcrClass = _OcrClass;
@synthesize TypeName = _TypeName;

+(NSMutableArray*)Personals
{
    static NSMutableArray* array = nil;
    if (!array){
        array = [[NSMutableArray alloc] init];
        
        OcrType* type = nil;
        
        type = [[OcrType alloc] init];
        type.OcrClass = Class_Personal_IdCard;
        type.TypeName = @"身份证";
        [array addObject:type];
        
        type = [[OcrType alloc] init];
        type.OcrClass = Class_Personal_BankCard;
        type.TypeName = @"银行卡";
        [array addObject:type];
        
        
        
        type = [[OcrType alloc] init];
        type.OcrClass = Class_Personal_DriverCard;
        type.TypeName = @"驾驶证";
        [array addObject:type];
        
        type = [[OcrType alloc] init];
        type.OcrClass = Class_Personal_MyCard;
        type.TypeName = @"名片";
        [array addObject:type];
    }
    return array;
}
+(NSMutableArray*)Financials
{
    static NSMutableArray* array = nil;
    if (!array){
        array = [[NSMutableArray alloc] init];
        
        OcrType* type = [[OcrType alloc] init];
        type.OcrClass = Class_Financial_Money;
        type.TypeName = @"企业财报";
        [array addObject:type];
        
        type = [[OcrType alloc] init];
        type.OcrClass = Class_Financial_Cert;
        type.TypeName = @"企业证件";
        [array addObject:type];
        
        type = [[OcrType alloc] init];
        type.OcrClass = Class_Financial_Bank;
        type.TypeName = @"银行存单";
        [array addObject:type];
        
        type = [[OcrType alloc] init];
        type.OcrClass = Class_Financial_Paper;
        type.TypeName = @"商业票据";
        [array addObject:type];
    }
    return array;
}
+(NSMutableArray*)Commercials
{
    static NSMutableArray* array = nil;
    if (!array){
        array = [[NSMutableArray alloc] init];
        
        OcrType* type = [[OcrType alloc] init];
        type.OcrClass = Class_Commercial_FaPiao;
        type.TypeName = @"发票识别";
        [array addObject:type];
        
        type = [[OcrType alloc] init];
        type.OcrClass = Class_Commercial_Table;
        type.TypeName = @"表格识别";
        [array addObject:type];
        
        type = [[OcrType alloc] init];
        type.OcrClass = Class_Commercial_Doc;
        type.TypeName = @"文档识别";
        [array addObject:type];
        
        type = [[OcrType alloc] init];
        type.OcrClass = Class_Commercial_Car;
        type.TypeName = @"车牌识别";
        [array addObject:type];
    }
    return array;
}
@end

