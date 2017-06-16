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
 返回服务器流水svrId
 */
+ (NSString*)uploadOCR:(NSString*)ocrType OcrImg:(UIImage*)ocrImg SvrType:(NSString*)svrType SvrFileName:(NSString*)svrFileName;
/*
 返回result字串表示成功
 */
+ (NSString*)updateOCR:(NSString*)svrId DocId:(NSString*)docId Value:(NSString*)value;
/*
 返回服务器流水svrId
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
 返回识别的<Field FieldId="Field_5" Name="民族" Rect="">汉</Field>对于的（Name，Value）对
  returnDict包含:Doc的Name属性,ObjectId属性，xmldata数据
 */
+ (NSMutableDictionary*)downloadOCR_XML:(NSString*)svrId FileName:(NSString*)fileName Addtional:(NSMutableDictionary*)returnDict;
/*
 返回识别的<Field FieldId="Field_5" Name="民族" Rect="">汉</Field>对于的（Name，Value）对
 returnDict包含:Doc的Name属性,ObjectId属性，xmldata数据
 */
+ (NSMutableDictionary*)downloadOCR_XML:(NSString*)svrId DocId:(NSString*)docId Addtional:(NSMutableDictionary*)returnDict;
/*
 返回xml文档的Field指定的attrName属性值对
 */
+(NSMutableDictionary*)getAttrOCR_XML:(NSData*)xmlData forDocFileName:(NSString*)docName forAttr:(NSString*)attrName;
/*
 返回服务器处理后图片数据
 */
+ (NSData*)downloadOCR_Img:(NSString*)svrId SvrFileName:(NSString*)svrFileName;
/*
 返回比svrId更新的ocr识别列表
 */
+ (NSArray*)downloadOCR_Last:(NSString*)svrId;

@end
