//
//  DataTableViewCell.m
//  SlideMenuControllerOC
//
//  Created by ChipSea on 16/3/29.
//  Copyright © 2016年 pluto-y. All rights reserved.
//

#import "DataTableViewCell.h"
#import "UIColor+SlideMenuControllerOC.h"
#import "UIImageView+SlideMenuControllerOC.h"
#import "UIImage+SlideMenuController.h"

@implementation DataTableViewCellData
-(void)loadData:(NSDictionary*)dict
{
    //保存前3项数据显示
    for (NSString* key in [dict allKeys]){
        if (!self.text){
            self.text = [dict objectForKey:key];
            self.caption = [NSString stringWithString:key];
        }
        else if (!self.text2){
            self.text2 = [dict objectForKey:key];
            self.caption2= [NSString stringWithString:key];
        }
        else if (!self.text3){
            self.text3 = [dict objectForKey:key];
            self.caption3 = [NSString stringWithString:key];
        }
        else
            break;
    }
}
@end

@implementation DataTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dataText.font = [UIFont italicSystemFontOfSize:14];
    self.dataText.textColor = [UIColor colorFromHexString:@"#9E9E00"];
    self.dataText2.font = [UIFont italicSystemFontOfSize:14];
    self.dataText2.textColor = [UIColor colorFromHexString:@"#888888"];
    self.dataText3.font = [UIFont italicSystemFontOfSize:14];
    self.dataText3.textColor = [UIColor colorFromHexString:@"#888888"];
}

+(CGFloat)height {
    return 90;
}

-(void)setData:(id)data {
    if ([data isKindOfClass:[DataTableViewCellData class]]) {
        DataTableViewCellData* celldata = (DataTableViewCellData*)data;
        if (celldata.image)
            self.dataImage.image = celldata.image;
        else
            [self.dataImage setRandomDownloadImage:80 height:80];
        if (((DataTableViewCellData *)data).text)
            self.dataText.text = [NSString stringWithFormat:@"%@: %@",((DataTableViewCellData *)data).caption,((DataTableViewCellData *)data).text];
        if (((DataTableViewCellData *)data).text2)
            self.dataText2.text = [NSString stringWithFormat:@"%@: %@",((DataTableViewCellData *)data).caption2,((DataTableViewCellData *)    data).text2];
        if (((DataTableViewCellData *)data).text3)
            self.dataText3.text = [NSString stringWithFormat:@"%@: %@",((DataTableViewCellData *)data).caption3,((DataTableViewCellData *)data).text3];
    }
}

@end
