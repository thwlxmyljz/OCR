//
//  BooksOp.h
//  mtsm
//
//  Created by yiqiao on 14-4-21.
//  Copyright (c) 2014年 yiqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <UIKit/UIKit.h>

@interface BooksOp : NSObject
{
    sqlite3 *database;
}

@property (nonatomic,assign,getter=getCardID) NSInteger CardID;
@property (nonatomic,assign) NSInteger CurClass;
@property (nonatomic,strong) NSString* UserId;
@property (nonatomic,strong) NSString* UserName;
@property (nonatomic,strong) NSString* UserPwd;
@property (nonatomic,assign) int SvrScan;//服务器识别
@property (nonatomic,strong) NSString* SvrAddr;//服务器地址
@property (nonatomic,strong) NSString* ThirdSvrAddr;//三方服务器地址

- (void)initializeDatabase;
- (void)finalizeDatabase;

- (sqlite3*)GetDatabase;
- (BOOL) hasDataRow:(NSString*)sql;
- (BOOL) execsql:(NSString*)sql;
- (BOOL) execTransactionSql:(NSMutableArray *)transactionSql;

//系统变量
- (int)  GetSysVarInt:(NSString*)var;
- (int)  SetSysVarInt:(NSString*)var WithIValue:(int)val;
//---------------------------------------------------------
/**
 通用函数
 */
+ (BooksOp*) Instance;
+ (NSData *)UTF8WithGB2312Data:(NSData *)gb2312Data;
+ (NSString*) GetSSFrom2DT:(NSString*)dt1 toDT:(NSString*)dt2;
+ (NSString*) GetSSFromSecs:(int)sp;
+ (int) GetSecsFrom2DT:(NSString*)dt1 toDT:(NSString*)dt2;
+ (NSString*)FormatBCBDateTime:(NSString*)dt;
+ (NSString*)GetNowDTString;
+ (NSString*)GetNowDTFileString;
+ (NSString*)FormatStringFromDT:(NSDate*)dt;
+ (NSString*)GetAfterNowDTString:(int)afterSecs;
+ (NSString*)GetCoolDTString:(NSString*)datetime;
+ (NSString*)GetCoolDTString_OnlyHM:(NSString*)datetime;
+ (NSString*)GetCoolDTString_HisMessage:(NSString*)datetime;
+ (NSString*)GetCoolDTString_ForOrder:(NSString*)datetime;
+ (NSString*)GetCoolDTStringFromDT:(NSDate*)date;
+ (NSString*)GetCoolFee:(float)fen;
+ (NSString*)GetIOSJson:(NSString*)json;
+ (NSString*)CreateJsonStr:(NSString*)json;
+ (NSData  *)ToJSONData:(NSDictionary*)theData;
+ (id)ToArrayOrNSDictionary:(NSData *)jsonData;
+ (NSString*)GetDBString:(NSString*)txt;
+ (NSString*)GetHoumanPhone:(NSString*)Info;

+ (UIImage*)scaleImage:(UIImage *)image toScale:(float)scale;//缩放图片
+ (UIImage*)scaleImage:(UIImage *)image toSize:(CGSize)size;//缩放图片
+ (UIImage*)imageWithColor:(UIColor *)color size:(CGSize)size;//根据颜色大小生成一个img

+ (void) ChangeLabelSelColor:(UILabel*)lblChange selTxt:(NSString*)selTxt SetColor:(UIColor*)selCol;
+ (void) removeTableCellContentViews:(UITableViewCell*)cell;
+ (void) RoundBeautifulButton:(UIButton*)btn;

+ (void) setExtraCellLineHidden:(UITableView *)tableView;
+ (void) scrollTableViewToTop:(UITableView*)tableView Animated:(BOOL)animated;
+ (void) scrollTableViewToBottom:(UITableView*)tableView Animated:(BOOL)animated;
+ (CGSize)sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode;
+(void)displayError:(NSString *)error withTitle:(NSString *)title;

+(NSString *)UUID;

@end
