//
//  IdCardTableCell.h
//  CloudOCR
//
//  Created by yiqiao on 2017/5/24.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "DataTableViewCell.h"

@interface IdCardTableCellData : DataTableViewCellData

@property (nonatomic, strong) NSString* IdCardName;
@property (nonatomic, strong) NSString* IdCardSex;
@property (nonatomic, strong) NSString* IdCardMz;
@property (nonatomic, strong) NSString* IdCardNo;
@property (nonatomic, strong) NSString* IdCardAddress;

-(void)loadData:(NSDictionary*)ocrdata;

@end

@interface IdCardTableCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblSex;
@property (weak, nonatomic) IBOutlet UILabel *lblCardNo;
@property (weak, nonatomic) IBOutlet UITextView *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblMz;

@end
