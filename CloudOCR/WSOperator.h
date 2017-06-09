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
+ (NSMutableDictionary*)downloadOCR_XML:(NSString*)svrId;
+ (NSData*)downloadOCR_Img:(NSString*)svrId SvrFileName:(NSString*)svrFileName;
@end
