//
//  OcrCard.h
//  CloudOCR
//
//  Created by yiqiao on 2017/5/25.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "OcrType.h"

@class OcrCard;

@protocol DBProtocol <NSObject>

@required
-(BOOL)Insert;
-(BOOL)Update;
-(BOOL)Delete;

@end

@interface OcrCard : NSObject <DBProtocol>//OcrType <DBProtocol>

@property (nonatomic, assign) EMOcrClass OcrClass;//分类
@property (nonatomic, strong) UIImage*   CardImg;//本地图片
@property (nonatomic, strong) UIImage*   CardSvrImg;//服务器图片
@property (nonatomic, assign) NSInteger  CardId; //卡片id
@property (nonatomic, strong) NSString*  CardSvrId;//卡片服务器标记id
@property (nonatomic, strong) NSMutableDictionary* CardDetail;//识别的详细信息
@property (nonatomic, strong) NSData* SvrDetail;//服务器识别的xml结果
@property (nonatomic, strong) NSMutableDictionary* ModifyDetail;//

-(NSString*) GetFileName;
+(NSString*) GetFileName:(int)cardId;

+(NSMutableArray*)Load:(EMOcrClass)clas;
+(OcrCard*)LoadOne:(int)cardId;
+(NSMutableDictionary*)TransHeadedDict:(NSMutableArray*)lst ForKey:(NSString*)key ResultHeadKeys:(NSMutableArray*)keyLst;
+(NSString*)GetHeadKey:(NSString*)value;
+(void)SortHeadKeys:(NSMutableArray*)keyLst;

//获取xml文档某图片文件的识别Name和FieldId对应关系
+(NSMutableDictionary*)getXmlKeyId:(NSData*)xmlData forDocFileName:(NSString*)docName;
//获取xml文档某图片文件的识别Name和Rect对应关系
+(NSMutableDictionary*)getXmlKeyRect:(NSData*)xmlData forDocFileName:(NSString*)docName;

-(BOOL)isEqual:(id)object;
-(BOOL)Update_noImg;

@end
