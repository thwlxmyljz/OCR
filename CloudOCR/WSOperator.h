//
//  WSOperator.h
//  mtsm
//
//  Created by yiqiao on 14-6-13.
//  Copyright (c) 2014年 yiqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import <libxml2/libxml/parser.h>
#import <libxml2/libxml/tree.h>

#define WS_TIMEOUT 30

@interface WSOperator : NSObject

+(NSString*)getASISOAP11Request:(NSString *) WebURL
                 webServiceFile:(NSString *) wsFile
                   xmlNameSpace:(NSString *) xmlNS
                 webServiceName:(NSString *) wsName
                   wsParameters:(NSMutableArray *) wsParas;
+(ASIHTTPRequest*)requestServiceUrl:(NSString*)WebURL ServiceMethodName:(NSString*)strMethod SoapMessage:(NSString*)soapMsg;
+(NSString*)SysServiceUrl:(NSString*)strUrl ServiceMethodName:(NSString*)strMethod SoapMessage:(NSString*)soap;
+(NSString*)parseWSRespond:(NSString*)respondString withTag:(NSString*)tag;
+(BOOL)parseResultString:(NSString*)result;

/*
 提交一个ocr识别请求到服务器
 服务器返回此次识别请求的流水id(svrId)
 */
+ (NSString*)uploadOCR:(NSString*)ocrType OcrImg:(UIImage*)ocrImg SvrType:(NSString*)svrType SvrFileName:(NSString*)svrFileName;
/*
 修改某个流水id(svrId)的识别结果
 返回字串.length>0表示成功
 */
+ (NSString*)updateOCR:(NSString*)svrId DocId:(NSString*)docId Value:(NSString*)value;
/*
 本地识别身份证，银行卡后，保存到服务器
 服务器返回识别的流水id(svrId)
 */
+ (NSString*)insertOCR:(UIImage*)ocrImg SvrFileName:(NSString*)svrFileName Value:(NSString*)value;
/*
 xml文档示例：
 <Batch CompTime="Fri Jun 16 11:38:28 CST 2017" DocCount="1" Name="090153351" OcrStatus="10" WriteTime="2017-06-16 11:38:28">
 <Doc AttachStamp="0" Form="身份证正面" FormId="" FormObjectId="" MainAttachFlag="1" Name="3.jpg" ObjectId="090153351_0">
 <Field FieldId="Field_1" Name="姓名" Rect="">邱智勇</Field>
 <Field FieldId="Field_2" Name="出生" Rect="">1981-05-05</Field>
 <Field FieldId="Field_6" Name="公民身份号码" Rect="">420525198105050012</Field>
 </Doc>
 </Batch>
 */
/*
 获取某个识别请求(svrId)的识别结果
 返回识别xml结果内节点<Field FieldId="Field_5" Name="民族" Rect="">汉</Field>，按（Name，Value）字典返回
 输出参数returnDict包含:Doc的Name属性,ObjectId属性，xmldata数据
 */
+ (NSMutableDictionary*)downloadOCR_XML:(NSString*)svrId FileName:(NSString*)fileName Addtional:(NSMutableDictionary*)returnDict;
+ (NSMutableDictionary*)downloadOCR_XML:(NSString*)svrId DocId:(NSString*)docId Addtional:(NSMutableDictionary*)returnDict;
/*
 返回识别服务器处理后的图片数据
 */
+ (NSData*)downloadOCR_Img:(NSString*)svrId SvrFileName:(NSString*)svrFileName;
/*
 返回识别xml结果内节点Field的attrName属性值对
 */
+(NSMutableDictionary*)getAttrOCR_XML:(NSData*)xmlData forDocFileName:(NSString*)docName forAttr:(NSString*)attrName;
/*
 返回比svrId更新的ocr识别列表
 */
+ (NSArray*)downloadOCR_Last:(NSString*)svrId;
+ (NSMutableArray*)downloadOCR_Types;
@end
