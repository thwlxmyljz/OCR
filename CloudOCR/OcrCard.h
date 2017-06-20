//
//  OcrCard.h
//  CloudOCR
//
//  Created by yiqiao on 2017/5/25.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "OcrType.h"

#define DOC       @"Doc" //表示一个图片识别
#define DOC_C      "Doc"

#define DOC_NAME   @"Name"//此图片识别的文件名
#define DOC_NAME_C  "Name"

#define DOC_OBJECTID   @"ObjectId" //此图片识别的对象id
#define DOC_OBJECTID_C  "ObjectId"

#define DOC_FORM   @"Form" //此图片识别的分类
#define DOC_FORM_C  "Form"

#define FIELD   @"Field" //此图片识别的已识别某项数据
#define FIELD_C  "Field"

#define FIELD_NAME   @"Name"//某项已识别数据的名称
#define FIELD_NAME_C  "Name"

#define FIELD_ID @"FieldId" //某项已识别数据的id
#define FIELD_RECT @"Rect" //某项已识别数据在识别图上的位置

#define XML_MYKEY @"xmldata999"//xml文件数据

//数据下载超时控制
#define DOWNLOAD_LOOP 10
#define DOWNLOAD_SLEEP_ONE 2.0f

@class OcrCard;

@protocol DBProtocol <NSObject>

@required
-(BOOL)Insert;
-(BOOL)Update;
-(BOOL)Delete;

@end

@interface OcrCard : NSObject <DBProtocol>//OcrType <DBProtocol>

@property (nonatomic, strong) NSString*  OcrClass;//分类
@property (nonatomic, strong) UIImage*   CardImg;//图片
@property (nonatomic, assign) NSInteger  CardId; //卡片id
@property (nonatomic, strong) NSString*  CardSvrId;//卡片服务器标记id
@property (nonatomic, strong) NSString*  CardDocId;//卡片服务器文档标记id，CardSvrId+CardDocId唯一标记服务器的一个图片识别
@property (nonatomic, strong) NSString*  CardFileName;//卡片文件名
@property (nonatomic, strong) NSMutableDictionary* CardDetail;//识别的详细信息
@property (nonatomic, strong) NSData* SvrDetail;//服务器识别的xml结果
@property (nonatomic, strong) NSMutableDictionary* ModifyDetail;//被修改的数据

+(NSMutableArray*)Load:(NSString*)clas;
+(OcrCard*)LoadOne:(int)cardId;
+(int)Count:(NSString*)clas;

//分类型显示
+(NSMutableDictionary*)TransHeadedDict:(NSMutableArray*)lst ForKey:(NSString*)key ResultHeadKeys:(NSMutableArray*)keyLst;
+(NSString*)GetHeadKey:(NSString*)value;
+(void)SortHeadKeys:(NSMutableArray*)keyLst;

+(int)GetCardId:(NSString*)svrId DocId:(NSString*)docId;

//获取xml文档某图片文件的识别Field节点的属性Name和属性FieldId对应关系
+(NSMutableDictionary*)getXmlKeyId:(NSData*)xmlData forDocFileName:(NSString*)docName;

//获取xml文档某图片文件的识别Field节点的属性Name和属性Rect对应关系
+(NSMutableDictionary*)getXmlKeyRect:(NSData*)xmlData forDocFileName:(NSString*)docName;

-(BOOL)isEqual:(id)object;
-(BOOL)Update_noImg;

+(void)syncSvrCards;

@end
