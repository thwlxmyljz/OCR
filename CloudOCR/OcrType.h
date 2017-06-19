//
//  SelType.h
//  HexOCR
//
//  Created by yiqiao on 2017/5/22.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef int EMOcrClass;
#define Class_Normal 0
#define Class_Personal_IdCard 100
#define Class_Personal_BankCard 101
@interface OcrType : NSObject

@property (nonatomic, assign) EMOcrClass OcrClass;//分类
@property (nonatomic, strong) NSString*  TypeName;//类型名称

-(id)initWith:(EMOcrClass)ocrClass Name:(NSString*)typeName;
-(BOOL)equalWith:(NSString*)name;
//
+(NSMutableDictionary*)Ocrs;
+(EMOcrClass)GetClass:(NSString*)typeName;
+(OcrType*)GetOcrType:(int)ocrClass;
+(void)insertType:(OcrType*)type;

+(void)syncSvrTypes;

@end

