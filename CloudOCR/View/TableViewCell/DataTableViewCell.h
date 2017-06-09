//
//  DataTableViewCell.h
//  SlideMenuControllerOC
//
//  Created by ChipSea on 16/3/29.
//  Copyright © 2016年 pluto-y. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface DataTableViewCellData : NSObject

@property (retain, nonatomic) NSString *imageUrl;

@property (retain, nonatomic) UIImage* image;
@property (retain, nonatomic) NSString *text;
@property (retain, nonatomic) NSString *caption;
@property (retain, nonatomic) NSString *text2;
@property (retain, nonatomic) NSString *caption2;
@property (retain, nonatomic) NSString *text3;
@property (retain, nonatomic) NSString *caption3;

-(void)loadData:(NSDictionary*)dict;

@end


@interface DataTableViewCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *dataImage;
@property (weak, nonatomic) IBOutlet UILabel *dataText;
@property (weak, nonatomic) IBOutlet UILabel *dataText2;
@property (weak, nonatomic) IBOutlet UILabel *dataText3;

@end
