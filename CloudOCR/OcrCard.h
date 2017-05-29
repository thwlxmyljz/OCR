//
//  OcrCard.h
//  CloudOCR
//
//  Created by yiqiao on 2017/5/25.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "OcrType.h"

@class OcrCard;

@protocol DBProtocol <NSObject>

@required
-(BOOL)Insert;
-(BOOL)Update;
-(BOOL)Delete;

@end

@interface OcrCard : NSObject <DBProtocol>//OcrType <DBProtocol>

@property (nonatomic, assign) EMOcrClass OcrClass;//分类
@property (nonatomic, strong) UIImage*   CardImg;//类型图片
@property (nonatomic, assign) NSInteger  CardId; //卡片id
@property (nonatomic, strong) NSString*  CardLinkId;//卡片三方id
@property (nonatomic, strong) NSMutableDictionary* CardPri;//显示的主要信息
@property (nonatomic, strong) NSMutableDictionary* CardDetail;//识别的详细信息

+(NSMutableArray*)Load:(EMOcrClass)clas;
+(OcrCard*)LoadOne:(int)cardId;
+(NSMutableDictionary*)TransHeadedDict:(NSMutableArray*)lst ForKey:(NSString*)key ResultHeadKeys:(NSMutableArray*)keyLst;
+(NSString*)GetHeadKey:(NSString*)value;
+(void)SortHeadKeys:(NSMutableArray*)keyLst;
-(BOOL)isEqual:(id)object;

@end
