//
//  SelType.m
//  HexOCR
//
//  Created by yiqiao on 2017/5/22.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "OcrType.h"
#import "BankTableCell.h"
#import "WSOperator.h"
#import <sqlite3.h>
#import "BooksOp.h"
#import "constants.h"
#import "NotificationView.h"
#import "NSNotificationAdditions.h"

@implementation OcrType

@synthesize TypeName = _TypeName;
-(id)initWith:(NSString*)typeName
{
    id my = [super init];
    self.TypeName = typeName;
    return my;
}
-(BOOL)equalWith:(NSString*)name
{
    if ([name containsString:@"身份证"] && [self.TypeName containsString:@"身份证"])
        return TRUE;
    return [self.TypeName isEqualToString:name];
}
+(NSMutableDictionary*)Ocrs
{
    static NSMutableDictionary* ocrDict = nil;
    if (!ocrDict){
        ocrDict = [[NSMutableDictionary alloc] init];
        NSMutableArray* array = [[NSMutableArray alloc] init];
        OcrType* type = nil;
        
        //先加2个默认值
        type = [[OcrType alloc] init];
        type.TypeName = Class_Personal_IdCard;
        [array addObject:type];
        
        type = [[OcrType alloc] init];
        type.TypeName = Class_Personal_BankCard;
        [array addObject:type];
        
        //mb_class(USERID TEXT, CARDCLASS TEXT, SVRID TEXT)
        const char * sql = "select CARDCLASS,SVRID from mb_class where USERID=?";
        sqlite3_stmt * statement;
        
        if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(statement, 1, [[BooksOp Instance].UserId UTF8String], -1, NULL);
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                type = [[OcrType alloc] init];
                char* szvalue = (char*)sqlite3_column_text(statement, 0);
                NSString* txt = szvalue?[NSString stringWithUTF8String:szvalue]:@"";
                type.TypeName = txt;
                
                [array addObject:type];
            }
            sqlite3_finalize(statement);
        }
     
        //加一个其他
        type = [[OcrType alloc] init];
        type.TypeName = @"其他";
        [array addObject:type];
        
        [ocrDict setValue:array forKey:@""];
    }
    return ocrDict;
}
+(void)insertType:(OcrType*)type
{
    NSMutableDictionary* oldDict = [OcrType Ocrs];
    NSMutableArray* oldArray = [oldDict objectForKey:@""];
    [oldArray insertObject:type atIndex:oldArray.count-1];
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NOTIFY_TYPEFRESH object:nil
                                                                      userInfo:nil];
}
+(OcrType*)GetOcrType:(NSString*)typeName
{
    NSMutableDictionary* dict = [OcrType Ocrs];
    for (NSString* key in [dict allKeys]){
        NSMutableArray* arr  = [dict objectForKey:key];
        for (OcrType* ocr in arr){
            if ([ocr.TypeName isEqualToString:typeName] ){
                return ocr;
            }
        }
    }
    return nil;
}
+(void)handleSvrType:(NSString*)svrName ObjectId:(NSString*)objectId
{
    NSMutableDictionary* dict = [OcrType Ocrs];
    for (NSString* key in dict){
        NSMutableArray* array = [dict objectForKey:key];
        for (OcrType* type in array){
            if ([type equalWith:svrName]){
                return;
            }
        }
    }
    //新类型
    void (^insertNewType)(NSString* name,NSString* objId) = ^(NSString* name,NSString* objId){
        sqlite3_stmt * statement;
        //mb_class(USERID TEXT, CARDCLASS TEXT, SVRID TEXT)
        const char* sql = "insert into mb_class (USERID,CARDCLASS,SVRID) values(?,?,?)";
        if (sqlite3_prepare_v2([[BooksOp Instance] GetDatabase], sql, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(statement,1, [[BooksOp Instance].UserId UTF8String], -1, NULL);
            sqlite3_bind_text(statement,2, [svrName UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 3, [objectId UTF8String], -1, NULL);
            
            if( sqlite3_step(statement) == SQLITE_DONE){
                NSLog(@"card insert DB ok");
            }
        }
        sqlite3_finalize(statement);
        
        OcrType* type = [[OcrType alloc] init];
        type.TypeName = svrName;
        [OcrType insertType:type];
    };
    if ([NSThread isMainThread]){
        insertNewType(svrName,objectId);
    }
    else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            insertNewType(svrName,objectId);
        });
    }
}
+(void)syncSvrTypes
{
    NSArray* typeArray = [WSOperator downloadOCR_Types];
    if (typeArray && typeArray.count > 0){
        NSLog(@"download Ocr type, count:%lu",(unsigned long)typeArray.count);
        for (NSDictionary * dict in typeArray){
            NSString* newName = [dict objectForKey:@"name"];
            NSString* newObjId = [dict objectForKey:@"objectId"];
            if (newName && newObjId){
                [OcrType handleSvrType:newName ObjectId:newObjId];
            }
            else{
                NSLog(@"syncSvrTypes name or objectid is null");
            }
        }
    }
}
@end

