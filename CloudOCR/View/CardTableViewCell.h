//
//  CardTableViewCell.h
//  CloudOCR
//
//  Created by yiqiao on 2017/5/26.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "BaseTableViewCell.h"

@class ViewController;

@interface CardTableViewCellData : NSObject

@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) NSString* value;

@end

@interface UITextField_CardCell : UITextField

@property (nonatomic,strong) NSString* key;

@end

@interface CardTableViewCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblCaption;
@property (weak, nonatomic) IBOutlet UITextField_CardCell *edtValue;

@end
