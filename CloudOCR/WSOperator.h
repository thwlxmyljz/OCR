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
 返回识别的（key，value）
 */
+ (NSMutableDictionary*)downloadOCR_XML:(NSString*)svrId FileName:(NSString*)fileName Addtional:(NSMutableDictionary*)returnDict;
/*
 返回识别的（key，value）
 */
+ (NSMutableDictionary*)downloadOCR_XML:(NSString*)svrId DocId:(NSString*)docId Addtional:(NSMutableDictionary*)returnDict;
/*
 返回服务器处理后图片数据
 */
+ (NSData*)downloadOCR_Img:(NSString*)svrId SvrFileName:(NSString*)svrFileName;
/*
 返回比svrId更新的ocr识别列表
 */
+ (NSArray*)downloadOCR_Last:(NSString*)svrId;

@end
