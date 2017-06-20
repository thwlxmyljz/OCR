//
//  SelType.h
//  HexOCR
//
//  Created by yiqiao on 2017/5/22.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define Class_Normal @"其他"
#define Class_Personal_IdCard @"身份证"
#define Class_Personal_BankCard @"银行卡"

@interface OcrType : NSObject

@property (nonatomic, strong) NSString*  TypeName;//类型名称

-(id)initWith:(NSString*)typeName;
-(BOOL)equalWith:(NSString*)name;
//
+(NSMutableDictionary*)Ocrs;
+(OcrType*)GetOcrType:(NSString*)typeName;

//插入一个类型
+(void)insertType:(OcrType*)type;

//同步用户类型
+(void)syncSvrTypes;

@end

