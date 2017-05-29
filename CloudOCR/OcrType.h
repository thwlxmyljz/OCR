//
//  SelType.h
//  HexOCR
//
//  Created by yiqiao on 2017/5/22.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum{
    //下面的分类值不要修改，会保存到数据库
    Class_Personal_IdCard=100 ,
    Class_Personal_BankCard=101,
    Class_Personal_DriverCard=102,
    Class_Personal_MyCard=103,
    
    Class_Financial_Money=200,
    Class_Financial_Cert=201,
    Class_Financial_Bank=202,
    Class_Financial_Paper=203,
    
    Class_Commercial_FaPiao=300,
    Class_Commercial_Table=301,
    Class_Commercial_Doc=302,
    Class_Commercial_Car=303
}EMOcrClass;

@interface OcrType : NSObject

@property (nonatomic, assign) EMOcrClass OcrClass;//分类
@property (nonatomic, strong) NSString*  TypeName;//类型名称

+(NSMutableArray*)Personals;
+(NSMutableArray*)Financials;
+(NSMutableArray*)Commercials;

@end

