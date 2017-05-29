//
//  BooksOp.m
//  mtsm
//
//  Created by yiqiao on 14-4-21.
//  Copyright (c) 2014年 yiqiao. All rights reserved.
//

#import "BooksOp.h"
#include <libxml/xmlreader.h>
#import <AddressBook/AddressBook.h>
#import <pthread.h>
#import "constants.h"

@interface BooksOp ()
@end

@implementation BooksOp

@synthesize CardID = _CardID;
@synthesize CurClass = _CurClass;
@synthesize UserId = _UserId;
@synthesize UserName = _UserName;

static BooksOp* OneMe = nil;
+ (BooksOp*) Instance
{
    static dispatch_once_t once;
    dispatch_once(&once,^{
        OneMe = [[self alloc] init];
    });
    return OneMe;
}
-(id) init
{
    self = [super init];
    return self;
}

#pragma mark - 数据库操作
// Open the database connection and retrieve minimal information for all objects.
- (void)initializeDatabase
{
    [self finalizeDatabase];
    // The database is stored in the application bundle.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* dbname = [NSString stringWithFormat:@"ocr.sql"];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:dbname];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        [self execsql:@"CREATE TABLE IF NOT EXISTS mb_sys(ID INTEGER PRIMARY KEY, VAR TEXT, VARVALUE INTEGER, CHARVALUE TEXT)"];
        [self execsql_noerror:@"INSERT INTO mb_sys (ID,VAR,VARVALUE,CHARVALUE) VALUES (1,'CURCLASS',100,'0')"];//当前识别类型,100默认身份证
        [self execsql_noerror:@"INSERT INTO mb_sys (ID,VAR,VARVALUE,CHARVALUE) VALUES (2,'CARDID',1,'0')"];//每次识别数据保存的本地唯一标示
        [self execsql:@"CREATE TABLE IF NOT EXISTS mb_card(ID INTEGER PRIMARY KEY, USERID INTEGER, USERNAME TEXT, CARDTYPE INTEGER, CARDID INTEGER,LINKID TEXT,CARDIMG BLOB, CARDPRI BLOB,CARDDETAIL BLOB)"];//识别的card存储
        [self execsql_noerror:@"CREATE INDEX IF NOT EXISTS mb_card_type ON mb_card(CARDTYPE)"];
        /*
         //升级语句
        [self execsql_noerror:@"alter table mb_order add column REMARK TEXT NULL default NULL"];//订单记录加入remark字段记录订单消息组合
        */
        
        self.CardID = [self GetSysVarInt:@"CARDID"];
        self.CurClass = [self GetSysVarInt:@"CURCLASS"];
    }
    else
    {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        database = nil;
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}
- (void)finalizeDatabase
{
    // Close the database.
    int n = 0;
    if (database != nil && (n=sqlite3_close(database)) != SQLITE_OK)
    {
        //NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
    database = nil;
}
- (sqlite3 *)GetDatabase
{
    return database;
}
-(BOOL)hasDataRow:(NSString*)sql
{
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        // We "step" through the results - once for each row.
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            sqlite3_finalize(statement);
            return TRUE;
        }
    }
    sqlite3_finalize(statement);
    return FALSE;
}
-(void) deleteTable:(NSString*)tableName
{
    NSString* sqldel = [NSString stringWithFormat:@"drop table %@",tableName ];
    char * err;
    if (sqlite3_exec(database, [sqldel UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        /*
        sqlite3_close(database);
        database = nil;
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
         */
    }
}
-(void) clearTable:(NSString*)tableName
{
    NSString* sqldel = [NSString stringWithFormat:@"delete from %@",tableName ];
    char * err;
    if (sqlite3_exec(database, [sqldel UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        /*
        sqlite3_close(database);
        database = nil;
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
         */
    }
}
-(BOOL) execsql:(NSString*)sql
{
    char * err = NULL;
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        /*
        sqlite3_close(database);
        database = nil;
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
         */
        return FALSE;
    }
    return TRUE;
}
-(void) execsql_noerror:(NSString*)sql
{
    char * err = NULL;
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
    }
}
//执行事务语句
-(BOOL)execTransactionSql:(NSMutableArray *)transactionSql
{
    //使用事务，提交插入sql语句
    @try{
        char *errorMsg;
        if (sqlite3_exec(database, "BEGIN", NULL, NULL, &errorMsg)==SQLITE_OK)
        {
            NSLog(@"begin transaction ok");
            sqlite3_free(errorMsg);
            sqlite3_stmt *statement;
            for (int i = 0; i<transactionSql.count; i++)
            {
                if (sqlite3_prepare_v2(database,[[transactionSql objectAtIndex:i] UTF8String], -1, &statement,NULL)==SQLITE_OK)
                {
                    if (sqlite3_step(statement)!=SQLITE_DONE)
                        sqlite3_finalize(statement);
                }
            }
            if (sqlite3_exec(database, "COMMIT", NULL, NULL, &errorMsg)==SQLITE_OK)
            {
                NSLog(@"commit transaction ok");
                sqlite3_free(errorMsg);
                return TRUE;
            }
        }
        else
        {
            sqlite3_free(errorMsg);
            return FALSE;
        }
    }
    @catch(NSException *e)
    {
        char *errorMsg;
        if (sqlite3_exec(database, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"rollback transaction ok");
        sqlite3_free(errorMsg);
        return FALSE;
    }
    return TRUE;
}
- (int)  GetSysVarInt:(NSString*)var
{
    NSString* sql = [NSString stringWithFormat:@"SELECT VARVALUE FROM mb_sys WHERE VAR='%@'",var];
    int ID = 0;
    sqlite3_stmt *statement;
    // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        // We "step" through the results - once for each row.
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            // The second parameter indicates the column index into the result set.
            ID = sqlite3_column_int(statement, 0);
        }
    }
    sqlite3_finalize(statement);
    return ID;
}
- (int)  SetSysVarInt:(NSString*)var WithIValue:(int)val
{
    NSString* sql = [NSString stringWithFormat:@"UPDATE mb_sys SET VARVALUE=%d WHERE VAR='%@'",val,var];
    [self execsql:sql];
    return 0;
}
-(NSInteger)getCardID
{
    [self SetSysVarInt:@"CARDID" WithIValue:++_CardID];
    NSLog(@"getCardId return %d",_CardID);
    return _CardID;
}
-(void)setCurClass:(NSInteger)_clas
{
    _CurClass = _clas;
    NSLog(@"setCurClass %d",_clas);
    [self SetSysVarInt:@"CURCLASS" WithIValue:_CurClass];
}
#pragma mark - static公共函数

+ (NSData *)UTF8WithGB2312Data:(NSData *)gb2312Data
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *str = [[NSString alloc] initWithData:gb2312Data encoding:enc];
    NSData *utf8Data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return utf8Data;
}

+(NSString*)FormatBCBDateTime:(NSString*)dt
{
    //格式化登录服务器下发的时间格式［bcb时间格式］
    NSRange tRange = [dt rangeOfString:@"T"];
    if (tRange.length > 0)
    {
        NSString* ss = @"";
        ss = [ss stringByAppendingString:[dt substringToIndex:4]];
        ss = [ss stringByAppendingString:@"-"];
        NSRange rg;
        rg.location = 4;
        rg.length = 2;
        ss = [ss stringByAppendingString:[dt substringWithRange:rg]];
        ss = [ss stringByAppendingString:@"-"];
        rg.location = 6;
        rg.length = 2;
        ss = [ss stringByAppendingString:[dt substringWithRange:rg]];
        ss = [ss stringByAppendingString:@" "];
        rg.location = 9;
        rg.length = 8;
        ss = [ss stringByAppendingString:[dt substringWithRange:rg]];
        return ss;
    }
    return nil;
}

+ (NSString*)GetNowDTString
{
    //获取当前时间字符串
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    return [formatter stringFromDate:[NSDate date]];
}
+ (NSString*)GetNowDTFileString
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    return [formatter stringFromDate:[NSDate date]];
}
+ (NSString*)FormatStringFromDT:(NSDate*)dt
{
    //格式化某时间成字符串
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    return [formatter stringFromDate:dt];
}
+ (NSString*)GetAfterNowDTString:(int)afterSecs
{
    NSDate* afterDT = [NSDate dateWithTimeInterval:afterSecs sinceDate:[NSDate date]];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    return [formatter stringFromDate:afterDT];
}
+ (NSString*)GetCoolDTStringFromDT:(NSDate*)date
{
    if (!date)
        return @"";
    time_t current_time = time(NULL);
    time_t this_time = [date timeIntervalSince1970];
    //time_t delta = current_time - this_time;
    //if (delta >=0 )
    {/*
      return @"刚才";
      }
      else if (delta <60)
      return [NSString stringWithFormat:@"%ld秒前", delta];
      else if (delta <3600)
      return [NSString stringWithFormat:@"%ld分钟前", delta /60];
      else {*/
        struct tm tm_now, tm_in;
        localtime_r(&current_time, &tm_now);
        localtime_r(&this_time, &tm_in);
        NSString *format = nil;
        
        if (tm_now.tm_year == tm_in.tm_year) {
            if (tm_now.tm_yday == tm_in.tm_yday)
                format = @"%-H:%M";
            else
                format = @"%-m月%-d日 %-H:%M";
        }
        else
            format = @"%Y年%-m月%-d日 %-H:%M";
        
        char buf[256] = {0};
        strftime(buf, sizeof(buf), [format UTF8String], &tm_in);
        return [NSString stringWithUTF8String:buf];
    }
}
+ (NSString*)GetCoolDTString:(NSString*)datetime
{
    if (!datetime){
        return @"";
    }
    if ([datetime isEqualToString:@""]){
        return @"";
    }
    time_t current_time = time(NULL);
    static NSDateFormatter *cooldateFormatter =nil;
    if (cooldateFormatter == nil){
        cooldateFormatter = [[NSDateFormatter alloc] init];
        [cooldateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        cooldateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
        [cooldateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    }
    NSDate *date = [cooldateFormatter dateFromString:datetime];
    if (!date)
        return @"";
    time_t this_time = [date timeIntervalSince1970];
    //time_t delta = current_time - this_time;
    //if (delta >=0 )
    {/*
        return @"刚才";
    }
    else if (delta <60)
        return [NSString stringWithFormat:@"%ld秒前", delta];
    else if (delta <3600)
        return [NSString stringWithFormat:@"%ld分钟前", delta /60];
    else {*/
        struct tm tm_now, tm_in;
        localtime_r(&current_time, &tm_now);
        localtime_r(&this_time, &tm_in);
        NSString *format = nil;
        
        if (tm_now.tm_year == tm_in.tm_year) {
            if (tm_now.tm_yday == tm_in.tm_yday)
                format = @"%-H:%M";
            else
                format = @"%-m月%-d日 %-H:%M";
        }
        else
            format = @"%Y年%-m月%-d日 %-H:%M";
        
        char buf[256] = {0};
        strftime(buf, sizeof(buf), [format UTF8String], &tm_in);  
        return [NSString stringWithUTF8String:buf];
    }
}
+ (NSString*)GetCoolDTString_OnlyHM:(NSString*)datetime
{
    if (!datetime){
        return @"";
    }
    if ([datetime isEqualToString:@""]){
        return @"";
    }
    time_t current_time = time(NULL);
    static NSDateFormatter *cooldateFormatter =nil;
    if (cooldateFormatter == nil){
        cooldateFormatter = [[NSDateFormatter alloc] init];
        [cooldateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        cooldateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
        [cooldateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    }
    NSDate *date = [cooldateFormatter dateFromString:datetime];
    if (!date)
        return @"";
    time_t this_time = [date timeIntervalSince1970];
    
    struct tm tm_now, tm_in;
    localtime_r(&current_time, &tm_now);
    localtime_r(&this_time, &tm_in);
    NSString *format = @"%-H:%M";
    
    char buf[256] = {0};
    strftime(buf, sizeof(buf), [format UTF8String], &tm_in);
    return [NSString stringWithUTF8String:buf];
}
+ (NSString*)GetCoolDTString_HisMessage:(NSString*)datetime
{
    if (!datetime){
        return @"";
    }
    if ([datetime isEqualToString:@""]){
        return @"";
    }
    time_t current_time = time(NULL);
    static NSDateFormatter *cooldateFormatter =nil;
    if (cooldateFormatter == nil){
        cooldateFormatter = [[NSDateFormatter alloc] init];
        [cooldateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        cooldateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
        [cooldateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    }
    NSDate *date = [cooldateFormatter dateFromString:datetime];
    if (!date)
        return @"";
    time_t this_time = [date timeIntervalSince1970];
    //time_t delta = current_time - this_time;
    //if (delta >=0 )
    {/*
      return @"刚才";
      }
      else if (delta <60)
      return [NSString stringWithFormat:@"%ld秒前", delta];
      else if (delta <3600)
      return [NSString stringWithFormat:@"%ld分钟前", delta /60];
      else {*/
        struct tm tm_now, tm_in;
        localtime_r(&current_time, &tm_now);
        localtime_r(&this_time, &tm_in);
        NSString *format = nil;
        if (tm_now.tm_year == tm_in.tm_year) {
            if (tm_now.tm_yday == tm_in.tm_yday)
                format = @"%-H:%M";
            else
                format = @"%-m月%-d日";
        }
        else
            format = @"%Y年%-m月%-d日";
        
        char buf[256] = {0};
        strftime(buf, sizeof(buf), [format UTF8String], &tm_in);
        return [NSString stringWithUTF8String:buf];
    }
}
+ (NSString*)GetCoolDTString_ForOrder:(NSString*)datetime
{
    if (!datetime){
        return @"";
    }
    if ([datetime isEqualToString:@""]){
        return @"";
    }
    time_t current_time = time(NULL);
    static NSDateFormatter *cooldateFormatter =nil;
    if (cooldateFormatter == nil){
        cooldateFormatter = [[NSDateFormatter alloc] init];
        [cooldateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        cooldateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
        [cooldateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    }
    NSDate *date = [cooldateFormatter dateFromString:datetime];
    if (!date)
        return @"";
    time_t this_time = [date timeIntervalSince1970];
    //time_t delta = current_time - this_time;
    //if (delta >=0 )
    {/*
      return @"刚才";
      }
      else if (delta <60)
      return [NSString stringWithFormat:@"%ld秒前", delta];
      else if (delta <3600)
      return [NSString stringWithFormat:@"%ld分钟前", delta /60];
      else {*/
        struct tm tm_now, tm_in;
        localtime_r(&current_time, &tm_now);
        localtime_r(&this_time, &tm_in);
        NSString *format = nil;
        
        if (tm_now.tm_year == tm_in.tm_year) {
            if (tm_now.tm_yday == tm_in.tm_yday)
                format = @"%-H:%M";
            else
                format = @"%-m/%-d %-H:%M";
        }
        else
            format = @"%Y/%-m/%-d %-H:%M";
        
        char buf[256] = {0};
        strftime(buf, sizeof(buf), [format UTF8String], &tm_in);
        return [NSString stringWithUTF8String:buf];
    }
}
+ (NSString*)GetCoolFee:(float)fen
{
    NSString* retstr = [NSString stringWithFormat:@"%.2f元",fen];
    return retstr;
}
+ (NSString*)GetIOSJson:(NSString*)json
{
    if (!json)
        return @"";
    NSMutableString * ss = [NSMutableString stringWithString:json];
    [ss replaceOccurrencesOfString:@":null" withString:@":\"\"" options:2 range:NSMakeRange(0, [ss length])];
    return ss;
}
+ (NSString*)CreateJsonStr:(NSString*)json
{
    NSMutableString* ss = [NSMutableString stringWithString:json];
    [ss replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:2 range:NSMakeRange(0, [ss length])];
    return ss;
    /*
    NSString* ss = @"";
    for (int index = 0; index < json.length; index++)
    {
        char c = [json characterAtIndex:index];
        switch(c){
            case'\"':
                ss = [ss stringByAppendingString:@"\\\""];
                break;
            case'/':
                ss = [ss stringByAppendingString:@"\\/"];
                break;
            case'\b':      //退格
                ss = [ss stringByAppendingString:@"\\b"];
                break;
            case'\f':      //走纸换页
                ss = [ss stringByAppendingString:@"\\f"];
                break;
            case'\n'://换行
                ss = [ss stringByAppendingString:@"\\n"];
                break;
            case'\r':      //回车
                ss = [ss stringByAppendingString:@"\\r"];
                break;
            case'\t':      //横向跳格
                ss = [ss stringByAppendingString:@"\\t"];
                break;
            default:
                ss = [ss stringByAppendingFormat:@"%c",c];
        }
    }
    return ss;
     */
}
+ (NSString*)GetDBString:(NSString*)txt
{
    if (!txt)
        return @"";
    
    NSArray* arr = [txt componentsSeparatedByString:@"'"];
    if (arr.count > 1){
        NSString* ss = @"";
        for (NSString* s in arr){
            ss = [ss stringByAppendingString:s];
            ss = [ss stringByAppendingString:@"''"];
        }
        ss = [ss substringToIndex:ss.length-2];
        return ss;
    }
    else{
        return txt;
    }
}
+(int) GetSecsFrom2DT:(NSString*)dt1 toDT:(NSString*)dt2
{
    //获取2个时间之间的差,返回秒
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    inputFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* inputDate1 = [inputFormatter dateFromString:dt1];
    NSDate* inputDate2 = [inputFormatter dateFromString:dt2];
    NSTimeInterval sp =[inputDate2 timeIntervalSince1970]-[inputDate1 timeIntervalSince1970];
    
    return (int)sp;
}
+(NSString*) GetSSFrom2DT:(NSString*)dt1 toDT:(NSString*)dt2
{
    //获取2个时间之间的差，返回格式串
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    inputFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* inputDate1 = [inputFormatter dateFromString:dt1];
    NSDate* inputDate2 = [inputFormatter dateFromString:dt2];
    NSTimeInterval sp =[inputDate2 timeIntervalSince1970]-[inputDate1 timeIntervalSince1970];
    
    return [BooksOp GetSSFromSecs:sp];
}
+ (NSString*) GetSSFromSecs:(int)sp
{
    //格式化以秒为单位的时间
    NSString *timeString=@"0";
    NSString *sen = [NSString stringWithFormat:@"%d", (int)sp%60];
    NSString *min = [NSString stringWithFormat:@"%d", (int)sp/60%60];
    NSString *house = [NSString stringWithFormat:@"%d", (int)sp/3600];
    
    if ([house isEqualToString:@"0"])
    {
        if ([min isEqualToString:@"0"])
        {
            timeString = [NSString stringWithFormat:@"%@秒",sen];
        }
        else
        {
            if (![sen isEqualToString:@"0"])
            {
                timeString = [NSString stringWithFormat:@"%@分%@秒",min,sen];
            }
            else
            {
                timeString = [NSString stringWithFormat:@"%@分钟",min];
            }
        }
    }
    else
    {
        if (![min isEqualToString:@"0"])
        {
            if (![sen isEqualToString:@"0"])
            {
                timeString = [NSString stringWithFormat:@"%@时%@分%@秒",house,min,sen];
            }
            else
            {
                timeString = [NSString stringWithFormat:@"%@时%@分钟",house,min];
            }
        }
        else
        {
            if (![sen isEqualToString:@"0"])
            {
                timeString = [NSString stringWithFormat:@"%@时%@秒",house,sen];
            }
            else
            {
                timeString = [NSString stringWithFormat:@"%@小时整",house];
            }
        }
    }
    return timeString;
}

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scale
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scale,image.size.height*scale));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scale, image.size.height *scale)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
+ (UIImage*)scaleImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGRect rc = CGRectMake(0, 0, size.width, size.height);
    [image drawInRect:rc];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
+ (UIColor*)getBookInfoColor:(NSString*)phoneInfo
{
    /*
    SiphonApplication *app = (SiphonApplication *)[SiphonApplication sharedApplication];
    if (app.trunkLine && ![app.trunkLine containsString:phoneInfo] && ![[BooksOp Instance] isIVPN:phoneInfo])
    {
        //非中继和分分机号，显示颜色
        return UIColorFromRGBA(0xf5a623, 1.0f);
    }
    return UIColorFromRGBA(0x7b7f83, 1.0f);
     */
    return UIColorFromRGBA(0x7b7f83, 1.0f);
}

+ (NSString*)GetHoumanPhone:(NSString*)Info
{
    if (!Info)
        return @"";
    if (Info.length != 11)
    {
        return Info;
    }
    NSString* meinfo = @"";
    NSRange rg;
    rg.length = 3;
    rg.location = 0;
    NSString* tmp = [Info substringWithRange:rg];
    meinfo = [NSString stringWithFormat:@"%@-",tmp];
    rg.length = 4;
    rg.location = 3;
    tmp = [Info substringWithRange:rg];
    meinfo = [NSString stringWithFormat:@"%@%@-",meinfo,tmp];
    rg.length = 4;
    rg.location = 7;
    tmp = [Info substringWithRange:rg];
    meinfo = [meinfo stringByAppendingString:tmp];
    return meinfo;
}

+ (void)ChangeLabelSelColor:(UILabel*)lblChange selTxt:(NSString*)selTxt SetColor:(UIColor*)selCol
{
    if (lblChange.text == nil)
        return;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:lblChange.text];
    NSRange rg = [[str string] rangeOfString:selTxt options:NSCaseInsensitiveSearch];
    while (rg.length > 0)
    {
        [str addAttribute:NSForegroundColorAttributeName value:selCol range:rg];
        int startlocation = (int)rg.location;
        int startlength = (int)rg.length;
        rg.location = rg.location+rg.length;
        rg.length = [str string].length - startlocation - startlength;
        if (rg.length > 0)
            rg = [[str string] rangeOfString:selTxt options:NSCaseInsensitiveSearch range:rg];
    }
    lblChange.attributedText = str;
}
+ (NSData *)ToJSONData:(NSDictionary*)theData{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}
//使用这个方法的返回，我们就可以得到想要的JSON串
//NSString *jsonString = [[NSString alloc] initWithData:jsonData
//                                             encoding:NSUTF8StringEncoding];
//二、将JSON串转化为NSDictionary或NSArray
//将NSString转化为NSData
//[jsonString dataUsingEncoding:NSASCIIStringEncoding];
// 将JSON串转化为字典或者数组
+ (id)ToArrayOrNSDictionary:(NSData *)jsonData{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
}
+(void)displayError:(NSString *)error withTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:error
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"确定", @"")
                                          otherButtonTitles:nil];
    [alert show];
}
#pragma mark - 界面显示

+ (void) removeTableCellContentViews:(UITableViewCell*)cell
{
    if (cell)
    {
        for (id val in cell.contentView.subviews)
        {
            UIView* delview = (UIView*)val;
            [delview removeFromSuperview];
        }
    }
}
+ (void)RoundBeautifulButton:(UIButton*)btn
{
    [btn.layer setCornerRadius:5.0];//设置矩形四个圆角半径
    [btn setTitleColor:UIColorFromRGBA(0xb2b2b2, 1.0f) forState:UIControlStateNormal];
    [btn.layer setMasksToBounds:YES];
    btn.layer.borderColor = [UIColorFromRGBA(0xb2b2b2, 1.0f) CGColor];
    btn.layer.borderWidth = 1.0f;
    if (btn.enabled){
        [btn setBackgroundColor:USERBTNBKCOLOR];
    }
    else{
        [btn setBackgroundColor:[UIColor grayColor]];
    }
}

+ (void)setExtraCellLineHidden:(UITableView *)tableView
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    tableView.backgroundColor = [UIColor clearColor];
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    tableView.separatorColor = [UIColor colorWithWhite:.9f alpha:1.0f];
}
+ (void)scrollTableViewToTop:(UITableView*)tableView Animated:(BOOL)animated
{
    if (tableView.numberOfSections > 0){
        NSInteger rows = [tableView numberOfRowsInSection:0];
        if(rows > 0)
        {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                             atScrollPosition:UITableViewScrollPositionTop
                                     animated:animated];
        }
        else
        {
            if ( tableView.numberOfSections > 1){
                rows = [tableView numberOfRowsInSection:1];
                if (rows > 0)
                {
                    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                     atScrollPosition:UITableViewScrollPositionTop
                                             animated:animated];
                }
            }
        }
    }
}
+ (void)scrollTableViewToBottom:(UITableView*)tableView Animated:(BOOL)animated
{
    if (tableView.numberOfSections > 0){
        NSInteger rows = [tableView numberOfRowsInSection:0];
        if(rows > 0) {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                             atScrollPosition:UITableViewScrollPositionBottom
                                     animated:animated];
        }
        else{
            if (tableView.numberOfSections > 1){
                rows = [tableView numberOfRowsInSection:1];
                if (rows > 0)
                {
                    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:1]
                                     atScrollPosition:UITableViewScrollPositionBottom
                                             animated:animated];
                }
            }
        }
    }
}


@end
