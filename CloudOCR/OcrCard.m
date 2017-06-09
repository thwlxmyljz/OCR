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

@implementation OcrCard

@synthesize CardImg = _CardImg;
@synthesize CardSvrImg = _CardSvrImg;
@synthesize CardDetail = _CardDetail;
@synthesize CardId = _CardId;
@synthesize CardLinkId = _CardLinkId;

//mb_card(ID INTEGER PRIMARY KEY, USERID TEXT, USERNAME TEXT, CARDCLASS INTEGER, CARDID INTEGER,LINKID TEXT,CARDIMG BLOB, SVRIMG BLOB,CARDDETAIL BLOB)

-(BOOL)Insert
{
    if (!_CardSvrImg && !_CardImg)
        return FALSE;
    if (!self.CardDetail)
        return FALSE;
    
    
    NSData * cardDetail = [BooksOp ToJSONData:self.CardDetail];
    
    const  char * sql = "insert into mb_card (USERID,USERNAME,CARDCLASS,CARDID,LINKID,CARDIMG,SVRIMG,CARDDETAIL) values(?,?,?,?,?,?,?,?)";
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [[BooksOp Instance].UserId UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [[BooksOp Instance].UserName UTF8String], -1, NULL);
        sqlite3_bind_int(statement, 3, self.OcrClass);
        sqlite3_bind_int(statement, 4, self.CardId);
        sqlite3_bind_text(statement, 5, [self.CardLinkId UTF8String], -1, NULL);
        if (self.CardImg){
            NSData * imgData = UIImagePNGRepresentation(_CardImg);
            sqlite3_bind_blob(statement, 6, [imgData bytes], [imgData length], NULL);
        }
        else{
            sqlite3_bind_blob(statement, 6, NULL,0,NULL);
        }
        if (self.CardSvrImg){
            NSData * imgData = UIImagePNGRepresentation(_CardSvrImg);
            sqlite3_bind_blob(statement, 7, [imgData bytes], [imgData length], NULL);
        }
        else{
            sqlite3_bind_blob(statement, 7, NULL, 0, NULL);
        }
        
        sqlite3_bind_blob(statement, 8, [cardDetail bytes], [cardDetail length], NULL);
        if( sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"insert ok");
            sqlite3_finalize(statement);
            return TRUE;
        }
        sqlite3_finalize(statement);
    }
    return FALSE;
}
-(BOOL)Update
{
    if (!_CardSvrImg && !_CardImg)
        return FALSE;
    if (!self.CardDetail)
        return FALSE;
    
    const  char * sql = "update mb_card  set CARDIMG=?,SVRIMG=?,CARDDETAIL=? where CARDID=?";
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
        
        if (self.CardSvrImg){
            NSData * imgData = UIImagePNGRepresentation(_CardSvrImg);
            sqlite3_bind_blob(statement, 2, [imgData bytes], [imgData length], NULL);
        }
        else{
            sqlite3_bind_blob(statement, 2, NULL, 0, NULL);
        }
        sqlite3_bind_blob(statement, 3, [cardDetail bytes], [cardDetail length], NULL);
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
    card.CardLinkId = linkid;
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
        card.CardSvrImg = [UIImage imageWithData:data];
    }
    
    bytes = sqlite3_column_bytes(statement, 5);
    value = (Byte*)sqlite3_column_blob(statement, 5);
    if (bytes !=0 && value != NULL)
    {
        NSData * data = [NSData dataWithBytes:value length:bytes];
        card.CardDetail = [BooksOp ToArrayOrNSDictionary:data];
    }
}
+(NSMutableArray*)Load:(EMOcrClass)clas
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    const char * sql = "select CARDID,LINKID,CARDCLASS,CARDIMG,SVRIMG,CARDDETAIL from mb_card where CARDCLASS=?";
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
    const char * sql = "select CARDID,LINKID,CARDCLASS,CARDIMG,SVRIMG,CARDDETAIL from mb_card where CARDID=?";
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
-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[OcrCard class]]){
        OcrCard* other = (OcrCard*)object;
        return other.CardId==self.CardId;
    }
    return FALSE;
}
@end
