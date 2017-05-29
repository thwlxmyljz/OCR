//
//  HexMOcr.h
//  HexMOcr
//
//  Created by Hex on 15/5/27.
//  Copyright (c) 2015年 Hex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum _EngineType{
    //证件识别引擎
    Engine_IdCard = 0,

    //银行卡识别引擎
    Engine_BankCard
}EngineType;

typedef enum _FormType{
    //二代证正/反面
    IdCard2 = 0,

    //二代证正面
    IdCard2_Front = 2 ,
    //二代证背面
    IdCard2_Back = 3 ,

}FormType;

@protocol HexOcrBankCardCallback <NSObject>

@required
  //拍照和识别成功后返回结果图片和银行卡信息，银行卡信息保存在字典中, resultImage:卡号图像  fullImage:整张银行卡图像
- (void)bankCardOcrEnd:(int)result resultImage:(UIImage *)image resultDictionary:(NSDictionary *)ocrResult fullCardImage:(UIImage *) fullImage;

@end

@protocol HexOcrIdCardCallback <NSObject>

@required
//拍照和识别成功后返回结果图片和身份证信息， 字段信息保存在字典中,   fullImage:整张身份证图像
- (bool)idCardOcrEnd: (NSDictionary *)ocrResult fullCardPath:(NSString *) fullCardPath;

@end


@interface HexMOcr : NSObject
 

//指定表单类型识别影像文件，识别结果保存在字典对象中（返回值>0成功，否则失败）
-(int) readFromFile:(NSString *)imageFileName FormType:(FormType) formType Result:(NSMutableDictionary *) ocrResult;

-(void) showBankCardOcrView:(UIViewController<HexOcrBankCardCallback> *)viewController;

-(void) showBankCardOcrView:(UIViewController*) viewController Callback:(id<HexOcrBankCardCallback>)successBack;

- (void)setIdCardScanTipView:  (UIView*) view;

-(void) showIdCardOcrView: (FormType) formType Callback:(UIViewController<HexOcrIdCardCallback> *)viewController;

-(void) showIdCardOcrView: (FormType) formType ViewController:(UIViewController*)viewController  Callback:(id<HexOcrIdCardCallback>)successBack;

//手动加载指定的识别引擎（返回值＝0成功，否则失败）
-(int) loadEngine:(EngineType)engineType;

//释放指定的识别引擎
-(void) unloadEngine:(EngineType)engineType;

//释放所有已加载的识别引擎
-(void) unloadAllEngine;
@end
