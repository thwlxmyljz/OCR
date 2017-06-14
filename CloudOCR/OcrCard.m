//
//  OcrCard.m
//  CloudOCR
//
//  Created by yiqiao on 2017/5/25.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "OcrCard.h"
#import <sqlite3.h>
#import "BooksOp.h"
#import "Chk2Asi.h"
#import "WSOperator.h"
#include <libxml/xmlreader.h>

@implementation OcrCard

@synthesize CardImg = _CardImg;
@synthesize CardDetail = _CardDetail;
@synthesize SvrDetail = _SvrDetail;
@synthesize CardId = _CardId;
@synthesize CardSvrId = _CardSvrId;
-(NSString*) GetFileName
{
    return [OcrCard GetFileName:self.CardId];
}
+(NSString*) GetFileName:(int)cardId
{
    return [NSString stringWithFormat:@"%d.jpg",cardId];
}
-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[OcrCard class]]){
        OcrCard* other = (OcrCard*)object;
        return other.CardId==self.CardId;
    }
    return FALSE;
}
-(BOOL)Insert
{
    if (!_CardImg)
        return FALSE;
    if (!self.CardDetail)
        return FALSE;
    
    [self insertSvr];
    
    //mb_card(ID INTEGER PRIMARY KEY, USERID TEXT, USERNAME TEXT, CARDCLASS INTEGER, CARDID INTEGER,LINKID TEXT,CARDIMG BLOB, SVRIMG BLOB,CARDDETAIL BLOB,SVRDETAIL BLOB)

    NSData * cardDetail = [BooksOp ToJSONData:self.CardDetail];
    const  char * sql = "insert into mb_card (USERID,USERNAME,CARDCLASS,CARDID,LINKID,CARDIMG,CARDDETAIL,SVRDETAIL) values(?,?,?,?,?,?,?,?)";
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [[BooksOp Instance].UserId UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [[BooksOp Instance].UserName UTF8String], -1, NULL);
        sqlite3_bind_int(statement, 3, self.OcrClass);
        sqlite3_bind_int(statement, 4, self.CardId);
        sqlite3_bind_text(statement, 5, [self.CardSvrId UTF8String], -1, NULL);
        if (self.CardImg){
            NSData * imgData = UIImagePNGRepresentation(_CardImg);
            sqlite3_bind_blob(statement, 6, [imgData bytes], [imgData length], NULL);
        }
        else{
            sqlite3_bind_blob(statement, 6, NULL,0,NULL);
        }
        
        sqlite3_bind_blob(statement, 7, [cardDetail bytes], [cardDetail length], NULL);
        
        if (self.SvrDetail){
            sqlite3_bind_blob(statement, 8, [self.SvrDetail bytes], [self.SvrDetail length], NULL);
        }
        else{
            sqlite3_bind_blob(statement, 8, NULL, 0, NULL);
        }
        
        if( sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"insert ok");
            sqlite3_finalize(statement);
            return TRUE;
        }
        
        sqlite3_finalize(statement);
    }
    return FALSE;
}
-(void)insertSvr
{
    if ([BooksOp Instance].SvrScan == 0){
        //不同步到服务器
        return;
    }
    if ([[BooksOp Instance].UserId isEqualToString:@""]){
        //没有账号不能同步
        return;
    }
    if (![self.CardSvrId isEqualToString:@""]){
        //新识别是从服务器识别的，不用再上传
        return;
    }
    NSString* jsonStr = [self createInsertValueJson];
    if ([jsonStr isEqualToString:@""]){
        return;
    }
    self.CardSvrId = [WSOperator insertOCR:self.CardImg SvrFileName:[self GetFileName] Value:jsonStr];
    if (![self.CardSvrId isEqualToString:@""]){
        //插入服务器成功，下载xml文件和服务器识别图
        NSMutableDictionary* svrOcrData = [WSOperator downloadOCR_XML:self.CardSvrId FileName:[self GetFileName]];
        if (svrOcrData){
            self.SvrDetail = [svrOcrData objectForKey:@"xmldata"];
            /*
             //目前服务器为原图
            //下载识别处理过后的图片
            NSData* svrImg = [WSOperator downloadOCR_Img:self.CardSvrId SvrFileName:[self GetFileName]];
            if (svrImg){
                self.CardImg = [UIImage imageWithData:svrImg];
            }
            else{
                NSLog(@"sync insert downloadOCR_Img error");
            }*/
        }
        else{
            NSLog(@"sync insert  insertOCR error");
        }
    }
}
-(NSString*)createInsertValueJson
{
    if (self.OcrClass != Class_Personal_IdCard && self.OcrClass != Class_Personal_BankCard)
        return @"";
    //只有身份证和银行卡支持本地识别后上传插入
    NSString* json = [NSString stringWithFormat:@"[{\"fileName\":\"%@\"",[self GetFileName]];
    if (self.OcrClass == Class_Personal_IdCard){
        json = [json stringByAppendingString:@",\"formType\":\"身份证正面\",\"content\":["];
    }
    else if (self.OcrClass == Class_Personal_IdCard){
        json = [json stringByAppendingString:@",\"formType\":\"银行卡正面\",\"content\":["];
    }
    for (NSString* key in self.CardDetail){
        json = [json stringByAppendingString:[NSString stringWithFormat:@"{\"name\":\"%@\",",key]];
        json = [json stringByAppendingString:[NSString stringWithFormat:@"\"strValue\":\"%@\",\"rect\":\"\"},",[self.CardDetail objectForKey:key]]];
    }
    json = [json substringToIndex:json.length-1];
    json = [json stringByAppendingString:@"]}]"];
    return json;
}
-(BOOL)Update
{
    if (!_CardImg)
        return FALSE;
    if (!self.CardDetail)
        return FALSE;
    
    //服务器更新
    [self updateSvr];
    
    //本地更新
    const  char * sql = "update mb_card  set CARDIMG=?,CARDDETAIL=?,SVRDETAIL=? where CARDID=?";
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
    {
        NSData * cardDetail = [BooksOp ToJSONData:self.CardDetail];
        if (self.CardImg){
            NSData * imgData = UIImagePNGRepresentation(_CardImg);
            sqlite3_bind_blob(statement, 1, [imgData bytes], [imgData length], NULL);
        }
        else{
            sqlite3_bind_blob(statement, 1, NULL, 0, NULL);
        }
        
        sqlite3_bind_blob(statement, 2, [cardDetail bytes], [cardDetail length], NULL);
        
        if (self.SvrDetail){
            sqlite3_bind_blob(statement, 3, [self.SvrDetail bytes], [self.SvrDetail length], NULL);
        }
        else{
            sqlite3_bind_blob(statement, 3, NULL, 0, NULL);
        }
        sqlite3_bind_int(statement, 4, self.CardId);
        
        if( sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"update %d ok",self.CardId);
            sqlite3_finalize(statement);
            return TRUE;
        }
        sqlite3_finalize(statement);
    }
    return FALSE;
}
-(BOOL)Update_noImg
{
    if (!_CardImg)
        return FALSE;
    if (!self.CardDetail)
        return FALSE;
    
    //服务器更新
    [self updateSvr];
    
    //本地更新
    const  char * sql = "update mb_card  set CARDDETAIL=?,SVRDETAIL=? where CARDID=?";
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
    {
        
        NSData * cardDetail = [BooksOp ToJSONData:self.CardDetail];
    
        sqlite3_bind_blob(statement, 1, [cardDetail bytes], [cardDetail length], NULL);
        
        if (self.SvrDetail){
            sqlite3_bind_blob(statement, 2, [self.SvrDetail bytes], [self.SvrDetail length], NULL);
        }
        else{
            sqlite3_bind_blob(statement, 2, NULL, 0, NULL);
        }
        sqlite3_bind_int(statement, 3, self.CardId);
        
        if( sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"update %d ok",self.CardId);
            sqlite3_finalize(statement);
            return TRUE;
        }
        sqlite3_finalize(statement);
    }
    return FALSE;
}
-(void)updateSvr
{
    //服务器更新
    if ([self.CardSvrId isEqualToString:@""]){
        //没有上传过，走上传流程
        [self insertSvr];
    }
    else{
        if (self.ModifyDetail != nil && self.ModifyDetail.count > 0){
            NSMutableDictionary* keyIdDic = [OcrCard getXmlKeyId:self.SvrDetail forDocFileName:[self GetFileName]];
            if (keyIdDic){
                NSString* svrId = self.CardSvrId;
                NSString* objId = [keyIdDic objectForKey:@"ObjectId"];
                NSString* newValue = [self createModifyValueJson:self.ModifyDetail MapId:keyIdDic];
                NSLog(@"newValue:%@",newValue);
                if (newValue.length > 0){
                    [WSOperator updateOCR:svrId DocId:objId Value:newValue];
                }
            }
        }
    }
}
-(NSString*)createModifyValueJson:(NSMutableDictionary*)dict MapId:(NSMutableDictionary*)mapId
{
    NSString* json = @"[";
    for (NSString* key in [dict allKeys]){
        NSString* keyId = [mapId objectForKey:key];
        NSString* line = [NSString stringWithFormat:@"{\"FieldId\":\"%@\",\"strValue\":\"%@\"},",keyId,[dict objectForKey:key]];
        json = [json stringByAppendingString:line];
    }
    if (json.length > 1){
        json = [json substringToIndex:json.length-1];
        json = [json stringByAppendingString:@"]"];
        return json;
    }
    return @"";
}
-(BOOL)Delete
{
    const  char * sql = "delete from mb_card where CARDID=?";
    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
    {
        sqlite3_bind_int(statement, 1,self.CardId);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"delete %d ok",self.CardId);
            sqlite3_finalize(statement);
            return TRUE;
        }
    }
    sqlite3_finalize(statement);
    return FALSE;
}
+(void)printDic:(NSDictionary*)dic
{
    for (NSString *key in dic) {
        NSLog(@"%@:%@",key,[dic objectForKey:key]);
    }
}
+(void)fill:(sqlite3_stmt *)statement toCard:(OcrCard*) card
{
    card.CardId = sqlite3_column_int(statement, 0);
    char* szvalue = (char*)sqlite3_column_text(statement, 1);
    NSString* linkid = szvalue?[NSString stringWithUTF8String:szvalue]:@"";
    card.CardSvrId = linkid;
    card.OcrClass = sqlite3_column_int(statement, 2);
    int bytes = sqlite3_column_bytes(statement, 3);
    Byte * value = (Byte*)sqlite3_column_blob(statement, 3);
    if (bytes !=0 && value != NULL)
    {
        NSData * data = [NSData dataWithBytes:value length:bytes];
        card.CardImg = [UIImage imageWithData:data];
    }
    
    bytes = sqlite3_column_bytes(statement, 4);
    value = (Byte*)sqlite3_column_blob(statement, 4);
    if (bytes !=0 && value != NULL)
    {
        NSData * data = [NSData dataWithBytes:value length:bytes];
        card.CardDetail = [BooksOp ToArrayOrNSDictionary:data];
    }
    
    bytes = sqlite3_column_bytes(statement, 5);
    value = (Byte*)sqlite3_column_blob(statement, 5);
    if (bytes !=0 && value != NULL)
    {
        NSData * data = [NSData dataWithBytes:value length:bytes];
        card.SvrDetail = data;
    }
}
+(NSMutableArray*)Load:(EMOcrClass)clas
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    const char * sql = "select CARDID,LINKID,CARDCLASS,CARDIMG,CARDDETAIL,SVRDETAIL from mb_card where CARDCLASS=? order by ID desc";
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
    {
        sqlite3_bind_int(statement, 1,clas);
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            OcrCard* card = [[OcrCard alloc] init];
            [OcrCard fill:statement toCard:card];
            [array addObject:card];
        }
        sqlite3_finalize(statement);
    }
    return array;
}
+(OcrCard*)LoadOne:(int)cardId
{
    const char * sql = "select CARDID,LINKID,CARDCLASS,CARDIMG,CARDDETAIL,SVRDETAIL from mb_card where CARDID=?";
    sqlite3_stmt * statement;
    OcrCard* card = nil;
    if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
    {
        sqlite3_bind_int(statement, 1,cardId);
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            card = [[OcrCard alloc] init];
            [OcrCard fill:statement toCard:card];
        }
        sqlite3_finalize(statement);
    }
    return card;
}
+(NSString*)GetHeadKey:(NSString*)value
{
    NSString* chKey = @"#";
    if (value){
        NSString* engName = [Chk2Asi GetHMTAsi:value];
        if (engName.length >0){
            chKey = [engName substringToIndex:1];
        }
    }
    return chKey;
}
+(void)SortHeadKeys:(NSMutableArray*)keyLst
{
    [keyLst sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString* s1 = (NSString*)obj1;
        NSString* s2 = (NSString*)obj2;
        if ([s1 isEqualToString:@"#"]){
            return NSOrderedDescending;
        }
        else if ([s2 isEqualToString:@"#"]){
            return NSOrderedAscending;
        }
        else{
            return [s1 compare:s2];
        }
    }];
}
+(NSMutableDictionary*)TransHeadedDict:(NSMutableArray*)lst ForKey:(NSString*)key ResultHeadKeys:(NSMutableArray*)keyLst
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    //转换到按首字母排列的字典数据
    for (OcrCard* card in lst){
        NSString* chKey = [OcrCard GetHeadKey:[card.CardDetail objectForKey:key]];
        
        if(![dict objectForKey:chKey]){
            [dict setValue:[[NSMutableArray alloc] init] forKey:chKey];
        }
        [[dict objectForKey:chKey] addObject:card];
        if (![keyLst containsObject:chKey]){
            [keyLst addObject:chKey];
        }
    }
    
    [OcrCard SortHeadKeys:keyLst];
    
    return dict;
}
+(NSMutableDictionary*)_getXmlKeyAttr:(NSData*)xmlData forDocFileName:(NSString*)docName forAttr:(NSString*)attrName
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
            NSLog(@"========> %s",xmlTextReaderName(reader));
            if(xmlTextReaderNodeType(reader) == XML_READER_TYPE_ELEMENT)
            {
                temp = (char *)xmlTextReaderConstName(reader);
                currentTagField = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                NSLog(@"========> %s",temp);
                if([currentTagField isEqualToString:@"Doc"])
                {
                    temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)"Name");
                    currentTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                    NSLog(@"===> TagName: %@",currentTagName);
                    if ([currentTagName isEqualToString:docName]){
                        temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)"ObjectId");
                        currentTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                        NSLog(@"===> TagName: %@",currentTagName);
                        [dict setValue:currentTagName forKey:@"ObjectId"];
                        docFound = TRUE;
                    }
                    else{
                        docFound = FALSE;
                    }
                }
                else if([currentTagField isEqualToString:@"Field"])
                {
                    if (docFound){
                        NSLog(@"===> TagField: %@",currentTagField);
                        
                        temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)"Name");
                        currentTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                        NSLog(@"===> TagName: %@",currentTagName);
                        
                        temp = (char* )xmlTextReaderGetAttribute(reader,(const xmlChar *)[attrName UTF8String]);
                        NSString *idTagName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                        NSLog(@"===> idTagName: %@",idTagName);
                        
                        [dict setValue:idTagName forKey:currentTagName];
                    }
                }
            }
        }
        return dict;
        
    }
    return nil;
}
+(NSMutableDictionary*)getXmlKeyId:(NSData*)xmlData forDocFileName:(NSString*)docName
{
    //FieldId="Field_3"
    return [OcrCard _getXmlKeyAttr:xmlData forDocFileName:docName forAttr:@"FieldId"];
}
+(NSMutableDictionary*)getXmlKeyRect:(NSData*)xmlData forDocFileName:(NSString*)docName
{
    //Rect="683, 224, 197, 33"
    return [OcrCard _getXmlKeyAttr:xmlData forDocFileName:docName forAttr:@"Rect"];
}
@end
