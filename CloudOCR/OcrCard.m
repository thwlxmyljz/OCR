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
#import "constants.h"
#import "NotificationView.h"
#import "NSNotificationAdditions.h"

@implementation OcrCard

@synthesize CardImg = _CardImg;
@synthesize CardDetail = _CardDetail;
@synthesize SvrDetail = _SvrDetail;
@synthesize CardId = _CardId;
@synthesize CardSvrId = _CardSvrId;
@synthesize CardDocId = _CardDocId;
@synthesize CardFileName = _CardFileName;

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

    if ([NSThread isMainThread]){
        [self _insert];
    }
    else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _insert];
        });
    }
    return TRUE;
}
-(BOOL)_insert
{
    NSData * cardDetail = [BooksOp ToJSONData:self.CardDetail];
    const  char * sql = "insert into mb_card (USERID,USERNAME,CARDCLASS,CARDID,LINKID,DOCID,FILENAME,CARDIMG,CARDDETAIL,SVRDETAIL) values(?,?,?,?,?,?,?,?,?,?)";
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [[BooksOp Instance].UserId UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [[BooksOp Instance].UserName UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 3, [self.OcrClass UTF8String], -1, NULL);
        sqlite3_bind_int(statement, 4, self.CardId);
        sqlite3_bind_text(statement, 5, [self.CardSvrId UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 6, [self.CardDocId UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 7, [self.CardFileName UTF8String], -1, NULL);
        if (self.CardImg){
            NSData * imgData = UIImagePNGRepresentation(_CardImg);
            sqlite3_bind_blob(statement, 8, [imgData bytes], [imgData length], NULL);
        }
        else{
            sqlite3_bind_blob(statement, 8, NULL,0,NULL);
        }
        
        sqlite3_bind_blob(statement, 9, [cardDetail bytes], [cardDetail length], NULL);
        
        if (self.SvrDetail){
            sqlite3_bind_blob(statement, 10, [self.SvrDetail bytes], [self.SvrDetail length], NULL);
        }
        else{
            sqlite3_bind_blob(statement, 10, NULL, 0, NULL);
        }
        
        if( sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"card insert DB ok");
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
        //已有CardSvrId，不再上传
        return;
    }
    NSString* jsonStr = [self createInsertValueJson];
    if ([jsonStr isEqualToString:@""]){
        return;
    }
    
    self.CardSvrId = [WSOperator insertOCR:self.CardImg SvrFileName:self.CardFileName Value:jsonStr];
    
    if (![self.CardSvrId isEqualToString:@""]){
        //插入服务器成功，下载xml文件和服务器识别图
        NSMutableDictionary* returnDict = [[NSMutableDictionary alloc] init];
        
        for (int i = 0; i < DOWNLOAD_LOOP; i++){
            
            [NSThread sleepForTimeInterval:DOWNLOAD_SLEEP_ONE];
        
            NSMutableDictionary* svrOcrData = [WSOperator downloadOCR_XML:self.CardSvrId FileName:self.CardFileName Addtional:returnDict];
            if (svrOcrData){
                self.SvrDetail = [returnDict objectForKey:XML_MYKEY];
                /*
                //下载识别处理过后的图片//目前服务器为原图
                NSData* svrImg = [WSOperator downloadOCR_Img:self.CardSvrId SvrFileName:self.CardFileName];
                if (svrImg){
                    self.CardImg = [UIImage imageWithData:svrImg];
                }
                else{
                    NSLog(@"sync insert downloadOCR_Img error");
                }*/
                NSLog(@"insertSvr ok");
                break;
            }
            else{
                NSLog(@"insertSvr error");
            }
        }
    }
}
-(NSString*)createInsertValueJson
{
    if (![self.OcrClass isEqualToString: Class_Personal_IdCard] && ![self.OcrClass isEqualToString: Class_Personal_BankCard])
        return @"";
    //只有身份证和银行卡支持本地识别后上传插入
    NSString* json = [NSString stringWithFormat:@"[{\"fileName\":\"%@\"",self.CardFileName];
    if ([self.OcrClass isEqualToString: Class_Personal_IdCard]){
        json = [json stringByAppendingString:@",\"formType\":\"身份证正面\",\"content\":["];
    }
    else if ([self.OcrClass isEqualToString:Class_Personal_IdCard]){
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
    
    if ([NSThread isMainThread]){
        [self _updateDB];
    }
    else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _updateDB];
        });
    }
    return TRUE;
}
-(BOOL)_updateDB
{
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
            NSLog(@"card update DB %d ok",(int)self.CardId);
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
    
    if ([NSThread isMainThread]){
        [self _update_noImg_DB];
    }
    else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _update_noImg_DB];
        });
    }
    return TRUE;
}
-(BOOL)_update_noImg_DB
{
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
            NSLog(@"card update DB %d ok",self.CardId);
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
            NSMutableDictionary* keyIdDic = [OcrCard getXmlKeyId:self.SvrDetail forDocFileName:self.CardFileName];
            if (keyIdDic){
                NSString* svrId = self.CardSvrId;
                NSString* objId = [keyIdDic objectForKey:DOC_OBJECTID];
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
    
    szvalue = (char*)sqlite3_column_text(statement, 2);
    NSString* docid = szvalue?[NSString stringWithUTF8String:szvalue]:@"";
    card.CardDocId = docid;
    
    szvalue = (char*)sqlite3_column_text(statement, 3);
    NSString* fileName = szvalue?[NSString stringWithUTF8String:szvalue]:@"";
    card.CardFileName = fileName;
    
    szvalue = (char*)sqlite3_column_text(statement, 4);
    NSString* className = szvalue?[NSString stringWithUTF8String:szvalue]:@"";
    card.OcrClass = className;
    
    int bytes = sqlite3_column_bytes(statement, 5);
    Byte * value = (Byte*)sqlite3_column_blob(statement, 5);
    if (bytes !=0 && value != NULL)
    {
        NSData * data = [NSData dataWithBytes:value length:bytes];
        card.CardImg = [UIImage imageWithData:data];
    }
    
    bytes = sqlite3_column_bytes(statement, 6);
    value = (Byte*)sqlite3_column_blob(statement, 6);
    if (bytes !=0 && value != NULL)
    {
        NSData * data = [NSData dataWithBytes:value length:bytes];
        card.CardDetail = [BooksOp ToArrayOrNSDictionary:data];
    }
    
    bytes = sqlite3_column_bytes(statement, 7);
    value = (Byte*)sqlite3_column_blob(statement, 7);
    if (bytes !=0 && value != NULL)
    {
        NSData * data = [NSData dataWithBytes:value length:bytes];
        card.SvrDetail = data;
    }
}
+(NSMutableArray*)Load:(NSString*)clas
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    const char * sql = "select CARDID,LINKID,DOCID,FILENAME,CARDCLASS,CARDIMG,CARDDETAIL,SVRDETAIL from mb_card where CARDCLASS=? and (USERID=? or USERID='') order by ID desc";
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [clas UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [[BooksOp Instance].UserId UTF8String], -1, NULL);
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
    const char * sql = "select CARDID,LINKID,DOCID,FILENAME,CARDCLASS,CARDIMG,CARDDETAIL,SVRDETAIL from mb_card where CARDID=?";
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
+(int)Count:(NSString*)clas
{
    const char * sql = "select count(*) as CNT from mb_card where CARDCLASS=? and (USERID=? or USERID='')";
    sqlite3_stmt * statement;
    int count = 0;
    if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [clas UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [[BooksOp Instance].UserId UTF8String], -1, NULL);
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            count = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return count;
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
+(int)GetCardId:(NSString*)svrId DocId:(NSString*)docId
{
    const char * sql = "select CARDID from mb_card where LINKID=? and DOCID=?";
    sqlite3_stmt * statement;
    int cardId = 0;//0:不存在此svrId的识别
    if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [svrId UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [docId UTF8String], -1, NULL);
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            cardId = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return cardId;
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

+(NSMutableDictionary*)getXmlKeyId:(NSData*)xmlData forDocFileName:(NSString*)docName
{
    //FieldId="Field_3"
    return [WSOperator getAttrOCR_XML:xmlData forDocFileName:docName forAttr:FIELD_ID];
}
+(NSMutableDictionary*)getXmlKeyRect:(NSData*)xmlData forDocFileName:(NSString*)docName
{
    //Rect="683, 224, 197, 33"
    return [WSOperator getAttrOCR_XML:xmlData forDocFileName:docName forAttr:FIELD_RECT];
}
+(void)syncSvrCards
{
    //[{\"ckey\":\"\",\"createTime\":\"2017-06-13 16:41:13\",\"formtype\":\"身份证正面\",\"objectId\":\"080100004cf51\",\"ocrstatus\":\"10\",\"srcdocid\":\"090150dd1\"},{\"ckey\":\"\",\"createTime\":\"2017-06-13 16:41:13\",\"formtype\":\"身份证正面\",\"objectId\":\"080100004cf61\",\"ocrstatus\":\"10\",\"srcdocid\":\"090150dd1\"},{\"ckey\":\"\",\"createTime\":\"2017-06-07 10:35:01\",\"formtype\":\"\",\"objectId\":\"080100004bd11\",\"ocrstatus\":\"10\",\"srcdocid\":\"09014f621\"},{\"ckey\":\"\",\"createTime\":\"2017-06-05 17:16:04\",\"formtype\":\"不动产登记证\",\"objectId\":\"080100004bc91\",\"ocrstatus\":\"10\",\"srcdocid\":\"09014f4d1\"}]
    NSArray* svrArray = [WSOperator downloadOCR_Last:@""];
    if (!svrArray)
        return;
    if (svrArray.count == 0)
        return;
    NSLog(@"syncOcr count:%lu",(unsigned long)svrArray.count);
    //由于接口返回按时间递减顺序，本地需按递增顺序操作
    NSArray* reversedArray = [[svrArray reverseObjectEnumerator] allObjects];
    for (NSDictionary* dict in reversedArray){
        NSString* svrId = [dict objectForKey:@"srcdocid"];
        NSString* docId = [dict objectForKey:@"xmldocobject"];
        //NSString* createTime = [dict objectForKey:@"createTime"];
        NSString* formtype = [dict objectForKey:@"formtype"];
        if (!docId){
            NSLog(@"syncOcr(%@) no docId",svrId);
            continue;
        }
        //本地没有的识别，插入进来，本地有的不管
        __block BOOL existId = FALSE;
        dispatch_sync(dispatch_get_main_queue(), ^{
            existId = ([OcrCard GetCardId:svrId DocId:docId] != 0)?TRUE:FALSE;
        });
        if (existId){
            NSLog(@"syncOcr(%@,%@,%@) already exist",svrId,docId,formtype);
            continue;
        }
        
        NSMutableDictionary* returnDict = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* ocrData = [WSOperator downloadOCR_XML:svrId DocId:docId Addtional:returnDict];
        if (ocrData && ocrData.count > 0){
            
            NSData* ocrXml = [returnDict objectForKey:XML_MYKEY];
            NSString* fileName = [returnDict objectForKey:DOC_NAME];
            
            if (!ocrXml || !fileName){
                NSLog(@"syncOcr(%@,%@) XML format error",svrId,docId);
                continue;
            }
            NSData* ocrImage = [WSOperator downloadOCR_Img:svrId SvrFileName:fileName];
            if (!ocrImage){
                NSLog(@"syncOcr(%@,%@,%@) downloadOCR_Img error",svrId,docId,fileName);
                continue;
            }
            
            OcrCard* card = [[OcrCard alloc] init];
            card.OcrClass = formtype;
            NSLog(@"new OcrCard(Name:%@,ClassName:%@)",formtype,card.OcrClass);
            card.CardId = [BooksOp Instance].CardID;
            card.CardSvrId = svrId;
            card.CardDocId = docId;
            card.CardDetail = ocrData;
            card.CardFileName = fileName;
            card.ModifyDetail = nil;
            card.CardImg = [UIImage imageWithData:ocrImage];;
            card.SvrDetail = ocrXml;
            
            if ([card Insert]){
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NOTIFY_OCRFRESH object:nil
                                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                        [NSNumber numberWithInt:card.CardId], @"cardid",
                                                                                        [NSString stringWithString:card.OcrClass], @"ocrclass",
                                                                                        [NSNumber numberWithInt:1]/*新卡片*/, @"op",
                                                                                        nil]];
            }
        }
    }
    NSLog(@"syncOcr count:%lu over",(unsigned long)svrArray.count);
}
@end
