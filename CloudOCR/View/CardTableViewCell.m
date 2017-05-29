//
//  CardTableViewCell.m
//  CloudOCR
//
//  Created by yiqiao on 2017/5/26.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "CardTableViewCell.h"
#import "UIColor+SlideMenuControllerOC.h"
#import "ViewController.h"

@implementation UITextField_CardCell

@end

@implementation CardTableViewCellData

@end

@implementation CardTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lblCaption.font = [UIFont italicSystemFontOfSize:15];
    self.lblCaption.textColor = [UIColor colorFromHexString:@"#689F38"];
    self.edtValue.font = [UIFont italicSystemFontOfSize:13.5];
    self.edtValue.textColor = [UIColor blackColor];
}
+(CGFloat) height
{
    return 42.0;
}
-(void)setData:(id)data {
    [super setData:data];
    if ([data isKindOfClass:[CardTableViewCellData class]]) {
        CardTableViewCellData* celldata = (CardTableViewCellData*)data;
        self.lblCaption.text = celldata.key;
        self.edtValue.text = celldata.value;
        self.edtValue.key = celldata.key;
    }
}
@end
