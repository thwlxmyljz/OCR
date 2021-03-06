//
//  WSOperator.m
//  mtsm
//
//  Created by yiqiao on 14-6-13.
//  Copyright (c) 2014年 yiqiao. All rights reserved.
//

#import "WSOperator.h"
#include <libxml/xmlreader.h>
#import "ASIHttpRequest/ASIDataDecompressor.h"
#import "ASIHttpRequest/ASIDataCompressor.h"
#import "BooksOp.h"
#import "OcrCard.h"

#define UPLOAD_TIMEOUT 30
#define SERVER_OCR [NSString stringWithFormat:@"http://%@/ocr",[BooksOp Instance].SvrAddr]

@implementation WSOperator

#pragma mark - web service common
//生成soap消息函数getASISOAP11Request
+(NSString*)getASISOAP11Request:(NSString *) WebURL
                 webServiceFile:(NSString *) wsFile
                   xmlNameSpace:(NSString *) xmlNS
                 webServiceName:(NSString *) wsName
                   wsParameters:(NSMutableArray *) wsParas
{
    //1、初始化SOAP消息体
    NSString * soapMsgBody1 = [[NSString alloc] initWithFormat:
                               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                               "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
                               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\n"
                               "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                               "<soap:Body>\n"
                               "<%@ xmlns=\"%@\">\n", wsName, xmlNS];
    
    NSString * soapMsgBody2 = [[NSString alloc] initWithFormat:
                               @"</%@>\n"
                               "</soap:Body>\n"
                               "</soap:Envelope>", wsName];
    
    //2、生成SOAP调用参数
    NSString * soapParas = [[NSString alloc] init];
    soapParas = @"";
    if (![wsParas isEqual:nil]) {
        int i = 0;
        for (i = 0; i < [wsParas count]; i = i + 2) {
            if ([[wsParas objectAtIndex:i+1] isMemberOfClass:[NSNull class]]){
                soapParas = [soapParas stringByAppendingFormat:@"<%@>%@</%@>\n",
                             [wsParas objectAtIndex:i],
                             @"null",
                             [wsParas objectAtIndex:i]];
            }
            else{
                soapParas = [soapParas stringByAppendingFormat:@"<%@>%@</%@>\n",
                         [wsParas objectAtIndex:i],
                         [wsParas objectAtIndex:i+1],
                         [wsParas objectAtIndex:i]];
            }
        }
    }
    
    //3、生成SOAP消息
    NSString * soapMsg = [soapMsgBody1 stringByAppendingFormat:@"%@%@", soapParas, soapMsgBody2];
    //NSLog(@"%@",soapMsg);
    return soapMsg;
}
//发送Soap消息
+(ASIHTTPRequest*)requestServiceUrl:(NSString*)WebURL ServiceMethodName:(NSString*)strMethod SoapMessage:(NSString*)soapMsg
{
    //请求发送到的路径
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", WebURL]];
    
    //NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    //[theRequest setURL:url];
    ASIHTTPRequest * theRequest= [ASIHTTPRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", (int)[soapMsg length]];
    
    //以下对请求信息添加属性前四句是必有的，第五句是soap信息。
    [theRequest addRequestHeader:@"Host" value:[url host]];
    [theRequest addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [theRequest addRequestHeader:@"Content-Length" value:msgLength];
    [theRequest addRequestHeader:@"SOAPAction" value:[NSString stringWithFormat:@"%@%@",@"",strMethod]];
    [theRequest setRequestMethod:@"POST"];
    //传soap信息
    [theRequest appendPostData:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setValidatesSecureCertificate:NO];
    //[theRequest setTimeOutSeconds:NETWAIT_SECS];
    [theRequest setTimeOutSeconds:WS_TIMEOUT];
    [theRequest setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    return theRequest;
}

+(NSString*)SysServiceUrl:(NSString*)strUrl ServiceMethodName:(NSString*)strMethod SoapMessage:(NSString*)soap
{
     ASIHTTPRequest *request=[WSOperator requestServiceUrl:strUrl ServiceMethodName:strMethod SoapMessage:soap];
     [request startSynchronous];
     NSError *error=[request error];
     int statusCode = [request responseStatusCode];
     //NSLog(@"%d",statusCode);
     if (error || statusCode!=200) {
         NSLog(@"statusCode:%d",statusCode);
         if (error){
                NSLog(@"error, [%@] Method:(%@) Error:%@",strUrl,strMethod,error.description);
         }
         return nil;
     }
     NSString* retStr = [request responseString];
     return retStr;
}
+(NSString*)parseWSRespond:(NSString*)respondString withTag:(NSString*)tag
{
    if (!respondString || !tag){
        return @"";
    }
    xmlTextReaderPtr reader = xmlReaderForMemory([respondString UTF8String], (int)[respondString length], nil, nil, (XML_PARSE_NOENT|XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING));
    
    if(!reader){
        NSLog(@"failed to load soap respond xml !");
        return @"";
    }
    else
    {
        char *temp;
        NSString *currentTagName = nil;
        NSString *currentTagValue = nil;
        while (TRUE)
        {
            if(!xmlTextReaderRead(reader))
                break;
            //NSLog(@"========> %s",xmlTextReaderName(reader));
            if(xmlTextReaderNodeType(reader) == XML_READER_TYPE_ELEMENT)
            {
                temp = (char *)xmlTextReaderConstName(reader);
                currentTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                //NSLog(@"========> %s",temp);
                if([currentTagName isEqualToString:tag])
                {
                    temp = (char *)xmlTextReaderReadString(reader);
                    currentTagValue = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                    //NSLog(@"===> TagName: %@",currentTagName);
                    //NSLog(@"===> TagValue: %@",currentTagValue);
                    return currentTagValue;
                }
            }
        }
    }
    return @"";
}

+(BOOL)parseResultString:(NSString*)result
{
    if (!result){
        return FALSE;
    }
    
    NSError* error;
    id jsonobj = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:&error];
    if (!jsonobj || error)
    {
        NSLog(@"parseResultString parse json str[%@] error.",result);
        return FALSE;
    }

    return [[jsonobj objectForKey:@"result"] intValue] >=0;
}
#pragma mark - web service function
#pragma mark - upload Ocr
/*
 返回uuid
 */
+ (NSString*)uploadOCR:(NSString*)ocrType OcrImg:(UIImage*)ocrImg SvrType:(NSString*)svrType SvrFileName:(NSString*)svrFileName
{
    NSLog(@"uploadOCR(%@,%@,%@)...",ocrType,svrType,svrFileName);
    NSError *error=nil;
    NSString* path = [NSString stringWithFormat:@"%@/%@",SERVER_OCR,svrType];
    NSString* uuid = [BooksOp UUID];
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:UPLOAD_TIMEOUT];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //要上传的图片

    //得到图片的data
    NSData* data = UIImageJPEGRepresentation(ocrImg,1);
    if (data == nil)
        return @"";
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    
    /*
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //添加字段名称，换2行
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"format"];
    //添加字段的值
    [body appendFormat:@"%d\r\n",4];
    */
    
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //添加字段名称，换2行
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"uuid"];
    //添加字段的值
    [body appendFormat:@"%@\r\n",uuid];
    
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //添加字段名称，换2行
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"ocrType"];
    //添加字段的值
    [body appendFormat:@"%@\r\n",ocrType];
    
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //添加字段名称，换2行
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"userId"];
    //添加字段的值
    [body appendFormat:@"%@\r\n",[BooksOp Instance].UserId];
    
    
    ////添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //声明pic字段，文件名为boris.png
    [body appendFormat:@"Content-Disposition: form-data; name=\"files\"; filename=\"%@\"\r\n",svrFileName];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type: multipart/form-data\r\n\r\n"];
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将image的data加入
    [myRequestData appendData:data];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", (int)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    NSHTTPURLResponse *urlResponese = nil;
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request   returningResponse:&urlResponese error:&error];
    NSString* result= [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    if([urlResponese statusCode] >=200&&[urlResponese statusCode]<300)
    {
        NSLog(@"uploadOCR ok(result:%@)",result);
        return result;
    }
    else
    {
        NSLog(@"uploadOCR failed(status code:%d)",(int)[urlResponese statusCode]);
        return @"";
    }
}
+ (NSString*)insertOCR:(UIImage*)ocrImg SvrFileName:(NSString*)svrFileName Value:(NSString*)value
{
    NSLog(@"insertOCR(%@,%@)...",svrFileName,value);
    NSError *error=nil;
    NSString* path = [NSString stringWithFormat:@"%@/uploadFilesAndResult",SERVER_OCR];
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:UPLOAD_TIMEOUT];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //要上传的图片
    
    //得到图片的data
    NSData* data = UIImageJPEGRepresentation(ocrImg,1);
    if (data == nil)
        return @"";
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    
    /*
     //添加分界线，换行
     [body appendFormat:@"%@\r\n",MPboundary];
     //添加字段名称，换2行
     [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"format"];
     //添加字段的值
     [body appendFormat:@"%d\r\n",4];
     */
    
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //添加字段名称，换2行
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"userId"];
    //添加字段的值
    [body appendFormat:@"%@\r\n",[BooksOp Instance].UserId];
    
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //添加字段名称，换2行
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"jsonStr"];
    //添加字段的值
    [body appendFormat:@"%@\r\n",value];
    
    
    ////添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //声明pic字段，文件名为boris.png
    [body appendFormat:@"Content-Disposition: form-data; name=\"files\"; filename=\"%@\"\r\n",svrFileName];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type: multipart/form-data\r\n\r\n"];
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将image的data加入
    [myRequestData appendData:data];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", (int)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    NSHTTPURLResponse *urlResponese = nil;
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request   returningResponse:&urlResponese error:&error];
    NSString* result= [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    if([urlResponese statusCode] >=200&&[urlResponese statusCode]<300)
    {
        NSLog(@"insertOCR ok(result:%@)",result);
        return result;
    }
    else
    {
        NSLog(@"insertOCR failed(json:%@,status code:%d)",value,(int)[urlResponese statusCode]);
        return @"";
    }
}
+ (NSData*)downloadOCR_Img:(NSString*)svrId SvrFileName:(NSString*)svrFileName
{
    NSLog(@"downloadOCR_Img(%@,%@)...",svrId,svrFileName);
    NSError *error = nil;
    NSURLResponse* respond = nil;
    NSString* path = nil;
    path = [NSString stringWithFormat:@"%@/downloadadjustjpg?uuid=%@&filename=%@",SERVER_OCR,svrId,svrFileName];
    NSURL *url= [NSURL URLWithString:path];
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:url];
    NSData *imgData=[NSURLConnection sendSynchronousRequest:request returningResponse:&respond error:&error];
    if(imgData && imgData.length > 0 && !error){
        if (![respond.MIMEType isEqualToString:@"text/html"]){
            //包含文件数据
            NSLog(@"downloadOCR_Img(%@,%@) ok",svrId,svrFileName);
            return imgData;
        }
    }
    NSLog(@"downloadOCR_Img(%@,%@) request error",svrId,svrFileName);
    return nil;
}
+ (NSMutableDictionary*)downloadOCR_XML:(NSString*)svrId  DocKey:(NSString*)docKey DocValue:(NSString*)keyValue  Addtional:(NSMutableDictionary*)returnDict
{
    NSLog(@"downloadOCR_XML(%@,%@,%@)...",svrId,docKey,keyValue);
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
    NSError *error=nil;
    NSURLResponse* respond = nil;
    //@"09014f8a1"
    NSString* path = [NSString stringWithFormat:@"%@/download?uuid=%@&fileType=xml",SERVER_OCR,svrId];
    NSURL *url= [NSURL URLWithString:path];
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:url];
    BOOL docFound = FALSE;
    NSData *xmlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&respond error:&error];
    if(xmlData && xmlData.length > 0 && !error)
    {
        if (![respond.MIMEType isEqualToString:@"text/html"])
        {
            xmlTextReaderPtr reader = xmlReaderForMemory(xmlData.bytes , xmlData.length, nil, nil, (XML_PARSE_NOENT|XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING));
            
            if(!reader){
                NSLog(@"downloadOCR_XML xmlReaderForMemory(%@) error",[NSString stringWithCString:xmlData.bytes encoding:NSUTF8StringEncoding]);
                return nil;
            }
            else
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                char *temp;
                NSString *currentTagField = nil;
                NSString *currentTagName = nil;
                NSString *currentTagValue = nil;
                while (TRUE)
                {
                    if(!xmlTextReaderRead(reader))
                        break;
                    if(xmlTextReaderNodeType(reader) == XML_READER_TYPE_ELEMENT)
                    {
                        temp = (char *)xmlTextReaderConstName(reader);
                        currentTagField = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                        NSLog(@"========> %s",temp);
                        if([currentTagField isEqualToString:DOC])
                        {
                            char* szformName = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)DOC_FORM_C);
                            NSString* formName = [NSString stringWithCString:szformName encoding:NSUTF8StringEncoding];
                            
                            temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)[docKey UTF8String]);
                            currentTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                            NSLog(@"===> Doc Name: %@,Form:%@",currentTagName,formName);
                            if ([currentTagName isEqualToString:keyValue]){
                                docFound = TRUE;
                                NSLog(@"found key:%@ value:%@",docKey,currentTagName);
                                //设置返回的docid
                                temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)DOC_OBJECTID_C);
                                currentTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                                [returnDict setValue:currentTagName forKey:DOC_OBJECTID];
                                //设置返回的filename
                                temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)DOC_NAME_C);
                                currentTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                                [returnDict setValue:currentTagName forKey:DOC_NAME];
                                //设置返回的formname(ocrclass)
                                temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)DOC_FORM_C);
                                currentTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                                [returnDict setValue:currentTagName forKey:DOC_FORM];
                            }
                            else{
                                docFound = FALSE;
                            }
                        }
                        if([currentTagField isEqualToString:FIELD] && docFound)
                        {
                            //NSLog(@"===> TagField: %@",currentTagField);
                            
                            temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)FIELD_NAME_C);
                            currentTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                            //NSLog(@"===> TagName: %@",currentTagName);
                            
                            temp = (char *)xmlTextReaderReadString(reader);
                            if (!temp){
                                //NSLog(@"value empty");
                                [dict setValue:@"" forKey:currentTagName];
                                NSLog(@"new key:%@ value:%@",currentTagName,@"");
                                continue;
                            }
                            else{
                                currentTagValue = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                                
                                //NSLog(@"===> TagValue: %@",currentTagValue);
                                currentTagValue = [currentTagValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                [dict setValue:currentTagValue forKey:currentTagName];
                                NSLog(@"new key:%@ value:%@",currentTagName,currentTagValue);
                            }
                        }
                    }
                }
                
                NSLog(@"downloadOCR_XML(%@) over",svrId);
                [returnDict setValue:xmlData forKey:XML_MYKEY];
                return dict;
            }
        }
    }
    
    NSLog(@"downloadOCR_XML(%@) request error",svrId);
    
    return nil;
}
+ (NSMutableDictionary*)downloadOCR_XML:(NSString*)svrId FileName:(NSString*)fileName Addtional:(NSMutableDictionary*)returnDict
{
    return [WSOperator downloadOCR_XML:svrId DocKey:DOC_NAME DocValue:fileName Addtional:returnDict];
}
+ (NSMutableDictionary*)downloadOCR_XML:(NSString*)svrId DocId:(NSString*)docId Addtional:(NSMutableDictionary*)returnDict
{
    return [WSOperator downloadOCR_XML:svrId DocKey:DOC_OBJECTID DocValue:docId Addtional:returnDict];
}
+(NSMutableDictionary*)getAttrOCR_XML:(NSData*)xmlData forDocFileName:(NSString*)docName forAttr:(NSString*)attrName
{
    xmlTextReaderPtr reader = xmlReaderForMemory(xmlData.bytes , xmlData.length, nil, nil, (XML_PARSE_NOENT|XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING));
    
    if(!reader){
        NSLog(@"failed to load soap respond xml !");
        return nil;
    }
    else
    {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        char *temp;
        NSString *currentTagField = nil;
        NSString *currentTagName = nil;
        BOOL docFound = FALSE;
        while (TRUE)
        {
            if(!xmlTextReaderRead(reader))
                break;
            if(xmlTextReaderNodeType(reader) == XML_READER_TYPE_ELEMENT)
            {
                temp = (char *)xmlTextReaderConstName(reader);
                currentTagField = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                NSLog(@"========> %s",temp);
                if([currentTagField isEqualToString:DOC])
                {
                    char* szformName = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)DOC_FORM_C);
                    NSString* formName = [NSString stringWithCString:szformName encoding:NSUTF8StringEncoding];
                    
                    temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)DOC_NAME_C);
                    currentTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                    NSLog(@"===> Doc Name: %@, Form:%@",currentTagName,formName);
                    if ([currentTagName isEqualToString:docName]){
                        temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)DOC_OBJECTID_C);
                        currentTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                        NSLog(@"found %@",docName);
                        [dict setValue:currentTagName forKey:DOC_OBJECTID];
                        docFound = TRUE;
                    }
                    else{
                        docFound = FALSE;
                    }
                }
                else if([currentTagField isEqualToString:FIELD])
                {
                    if (docFound){
                        //NSLog(@"===> TagField: %@",currentTagField);
                        
                        temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)FIELD_NAME_C);
                        currentTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                        //NSLog(@"===> TagName: %@",currentTagName);
                        
                        temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)[attrName UTF8String]);
                        NSString *idTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                        //NSLog(@"===> idTagName: %@",idTagName);
                        
                        [dict setValue:idTagName forKey:currentTagName];
                        NSLog(@"new key:%@ value:%@",currentTagName,idTagName);
                    }
                }
            }
        }
        return dict;
        
    }
    return nil;
}
+(NSString*)updateOCR:(NSString*)svrId DocId:(NSString*)docId Value:(NSString*)value
{
    NSLog(@"updateOCR(%@,%@,%@)...",svrId,docId,value);
    NSError *error=nil;
    NSString* path = [NSString stringWithFormat:@"%@/save?srcDocId=%@&objId=%@",SERVER_OCR,svrId,docId];
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:UPLOAD_TIMEOUT];

    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
    //设置HTTPHeader
    NSString *content=[[NSString alloc]initWithFormat:@"text/html"];
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", (int)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    NSHTTPURLResponse *urlResponese = nil;
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request   returningResponse:&urlResponese error:&error];
    NSString* result= [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    if([urlResponese statusCode] >=200&&[urlResponese statusCode]<300)
    {
        NSLog(@"updateOCR ok(result:%@)",result);
        return result;
    }
    else
    {
        NSLog(@"updateOCR failed(status code:%d)",(int)[urlResponese statusCode]);
        return @"";
    }
}
+ (NSArray*)downloadOCR_Last:(NSString*)svrId
{
    NSLog(@"downloadOCR_Last(%@)...",svrId);
    NSError *error=nil;
    NSURLResponse* respond = nil;
    NSString* path = [NSString stringWithFormat:@"%@/getList?user=%@",SERVER_OCR,[BooksOp Instance].UserId];
    NSURL *url= [NSURL URLWithString:path];
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:url];
    NSData *jsonData=[NSURLConnection sendSynchronousRequest:request returningResponse:&respond error:&error];
    if(jsonData && jsonData.length > 0 && !error)
    {
        if (![respond.MIMEType isEqualToString:@"text/html"])
        {
            NSError* error;
            //NSLog(@"%@",json);
            id jsonobj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            if (!jsonobj || error){
                NSLog(@"downloadOCR_Last parse json str[%@] error.",[NSString stringWithCString:jsonData.bytes encoding:NSUTF8StringEncoding]);
                return nil;
            }
            NSLog(@"downloadOCR_Last count %d",((NSArray*)jsonobj).count);
            return  (NSArray*)jsonobj;
        }
    }
    NSLog(@"downloadOCR_Last request error");
    return nil;
}
+ (NSMutableArray*)downloadOCR_Types
{
    NSLog(@"downloadOCR_Types...");
    NSError *error=nil;
    NSURLResponse* respond = nil;
    NSString* path = [NSString stringWithFormat:@"%@/getDocType?userId=%@",SERVER_OCR,[BooksOp Instance].UserId];
    NSURL *url= [NSURL URLWithString:path];
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:url];
    NSData *jsonData=[NSURLConnection sendSynchronousRequest:request returningResponse:&respond error:&error];
    if(jsonData && jsonData.length > 0 && !error)
    {
        if (![respond.MIMEType isEqualToString:@"text/html"])
        {
            NSError* error;
            id jsonobj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            if (!jsonobj || error){
                NSLog(@"downloadOCR_Types parse json str[%@] error.",[NSString stringWithCString:jsonData.bytes encoding:NSUTF8StringEncoding]);
                return nil;
            }
            NSLog(@"downloadOCR_Types count %d",((NSMutableArray*)jsonobj).count);
            return  (NSMutableArray*)jsonobj;
        }
    }
    NSLog(@"downloadOCR_Types request error");
    return nil;
}
@end
