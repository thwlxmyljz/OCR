//
//  ImagePreviewViewController.h
//  CloudOCR
//
//  Created by yiqiao on 2017/6/5.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePreviewViewController : UIViewController

@property (nonatomic, strong) UIImage* OcrImage;
@property (nonatomic, strong) NSData* OcrXml;
@property (nonatomic, strong) NSString* OcrFileName;
@property (nonatomic, strong) NSString* ClickKey;

@end
