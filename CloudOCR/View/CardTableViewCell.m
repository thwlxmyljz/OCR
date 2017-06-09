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
#import "constants.h"
#import "BooksOp.h"

@implementation UITextView_CardCell

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
    
    self.lblCaption.font = [UIFont italicSystemFontOfSize:14];
    self.lblCaption.textColor = [UIColor colorFromHexString:@"#689F38"];
    self.edtValue.font = [UIFont italicSystemFontOfSize:14];
    self.edtValue.textColor = [UIColor blackColor];
    //self.edtValue.backgroundColor = [UIColor greenColor];
}
+(CGFloat) height
{
    return 44.0;
}

+(CGFloat) heightForData:(id) data
{
    CGFloat ff = [CardTableViewCell height];
    if ([data isKindOfClass:[CardTableViewCellData class]]) {
        CardTableViewCellData* celldata = (CardTableViewCellData*)data;
        
        CGSize captionSize = [BooksOp sizeForString:celldata.key font:[UIFont italicSystemFontOfSize:14] constrainedToSize:CGSizeMake(96,MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        

        //NSLog(@"%@ height:%f",celldata.key,captionSize.height);
        if (ff < captionSize.height)
            ff = captionSize.height;
        
        CGSize valueSize = [BooksOp sizeForString:celldata.value font:[UIFont italicSystemFontOfSize:14] constrainedToSize:CGSizeMake(SCREEN_WIDTH-121-2,MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        
        //NSLog(@"%@ height:%f",celldata.value,valueSize.height);
        if (ff < valueSize.height)
            ff = valueSize.height+30;
    }
    NSLog(@"heightForData:%f",ff);
    return ff;
}

-(void)setData:(id)data {
    [super setData:data];
    if ([data isKindOfClass:[CardTableViewCellData class]]) {
        CardTableViewCellData* celldata = (CardTableViewCellData*)data;
        self.lblCaption.numberOfLines = 0;
        self.lblCaption.text = celldata.key;
        [self.lblCaption sizeToFit];
        
        self.edtValue.text = celldata.value;
        self.edtValue.key = celldata.key;
        /*
        NSLog(@"textview height:%f",self.edtValue.frame.size.height);
        if (self.edtValue.frame.size.height <= [CardTableViewCell height]+1){
            self.edtValue.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
            self.edtValue.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
        }
        else{
            self.edtValue.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }*/
    }
}
@end
