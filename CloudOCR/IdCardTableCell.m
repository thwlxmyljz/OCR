//
//  IdCardTableCell.m
//  CloudOCR
//
//  Created by yiqiao on 2017/5/24.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "IdCardTableCell.h"
#import "UIColor+SlideMenuControllerOC.h"
#import "UIImageView+SlideMenuControllerOC.h"
#import "UIImage+SlideMenuController.h"
#import "CardKey.h"

@implementation IdCardTableCellData

@synthesize IdCardName;
@synthesize IdCardNo;
@synthesize IdCardSex;
@synthesize IdCardAddress;
@synthesize IdCardMz;

-(void)loadData:(NSDictionary*)dict
{
    self.IdCardName = [dict objectForKey:IDCARD_KEY_NAME];
    self.IdCardSex = [dict objectForKey:IDCARD_KEY_SEX];
    self.IdCardMz = [dict objectForKey:IDCARD_KEY_MZ];
    self.IdCardNo = [dict objectForKey:IDCARD_KEY_NO];
    self.IdCardAddress = [dict objectForKey:IDCARD_KEY_ADDRESS];
}
@end

@implementation IdCardTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lblName.font = [UIFont italicSystemFontOfSize:15];
    self.lblName.textColor = [UIColor colorFromHexString:@"#9E9E00"];
    self.lblName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.lblSex.font = [UIFont italicSystemFontOfSize:13];
    self.lblSex.textColor = [UIColor colorFromHexString:@"#888888"];
    self.lblSex.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.lblMz.font = [UIFont italicSystemFontOfSize:13];
    self.lblMz.textColor = [UIColor colorFromHexString:@"#888888"];
    self.lblMz.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.lblCardNo.font = [UIFont italicSystemFontOfSize:15];
    self.lblCardNo.textColor = [UIColor colorFromHexString:@"#9E9E00"];
    self.lblCardNo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.lblAddress.font = [UIFont italicSystemFontOfSize:14];
    self.lblAddress.textColor = [UIColor colorFromHexString:@"#888888"];
    self.lblAddress.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    self.lblAddress.contentInset = UIEdgeInsetsMake(-10, -4, 0, 0);
}

+(CGFloat)height {
    return 120;
}

-(void)setData:(id)data {
    [super setData:data];
    if ([data isKindOfClass:[IdCardTableCellData class]]) {
        self.imgView.image = ((IdCardTableCellData *)data).image;
        self.lblName.text = ((IdCardTableCellData *)data).IdCardName;
        self.lblSex.text = ((IdCardTableCellData *)data).IdCardSex;
        self.lblCardNo.text = ((IdCardTableCellData *)data).IdCardNo;
        self.lblAddress.text = ((IdCardTableCellData *)data).IdCardAddress;
        self.lblMz.text = ((IdCardTableCellData *)data).IdCardMz;
    }
}
@end

