//
//  BankTableCell.m
//  HexOCR
//
//  Created by yiqiao on 2017/5/22.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "BankTableCell.h"
#import "UIColor+SlideMenuControllerOC.h"
#import "UIImageView+SlideMenuControllerOC.h"
#import "UIImage+SlideMenuController.h"

@implementation BankTableCellData

@synthesize BankNo;
@synthesize BankName;

@end

@implementation BankTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.cardBankName.font = [UIFont italicSystemFontOfSize:16];
    self.cardBankName.textColor = [UIColor colorFromHexString:@"#9E9E9E"];
    self.cardBankNo.font = [UIFont italicSystemFontOfSize:16];
    self.cardBankNo.textColor = [UIColor colorFromHexString:@"#9E9E00"];
}

+(CGFloat)height {
    return 60;
}

-(void)setData:(id)data {
    if ([data isKindOfClass:[BankTableCellData class]]) {
        self.imgView.image = ((BankTableCellData *)data).image;
        self.cardBankName.text = ((BankTableCellData *)data).BankName;
        self.cardBankNo.text = ((BankTableCellData *)data).BankNo;
    }
}
@end
