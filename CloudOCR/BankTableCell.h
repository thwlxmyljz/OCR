//
//  BankTableCell.h
//  HexOCR
//
//  Created by yiqiao on 2017/5/22.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "DataTableViewCell.h"

@interface BankTableCellData : DataTableViewCellData

@property (nonatomic, strong) NSString* BankNo;//卡号
@property (nonatomic, strong) NSString* BankName;//银行名称

@end

@interface BankTableCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *cardBankName;
@property (weak, nonatomic) IBOutlet UILabel *cardBankNo;

@end
