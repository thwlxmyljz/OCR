//
//  CardKey.h
//  CloudOCR
//
//  Created by yiqiao on 2017/5/26.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

/*
 2017-05-25 17:13:54.199 CloudOCR[813:258588] 姓名:唐宏文
 2017-05-25 17:13:54.199 CloudOCR[813:258588] 出生:1981-11-22
 2017-05-25 17:13:54.199 CloudOCR[813:258588] 住址:湖南省永州市零陵区凼底乡冷山村1组
 2017-05-25 17:13:54.199 CloudOCR[813:258588] 性别:男
 2017-05-25 17:13:54.199 CloudOCR[813:258588] 民族:汉
 2017-05-25 17:13:54.200 CloudOCR[813:258588] 公民身份号码:432901198111228897
 */
#define IDCARD_KEY_NAME @"姓名"
#define IDCARD_KEY_BIRTHDAY @"出生"
#define IDCARD_KEY_ADDRESS @"住址"
#define IDCARD_KEY_SEX @"性别"
#define IDCARD_KEY_MZ @"民族"
#define IDCARD_KEY_NO @"公民身份号码"
/*
{
    bankCode = 01040000;
    bankName = "\U4e2d\U56fd\U94f6\U884c";
    cardName = "\U533b\U4fdd\U8054\U540d\U501f\U8bb0IC\U5361";
    cardNumber = "6217 5820 0000 9152 653";
    cardType = "\U501f\U8bb0\U5361";
}
 */
#define BANDCARD_KEY_BANKCODE   @"bankCode"
#define BANDCARD_KEY_BANKCODE_CH   @"银行代码"
#define BANKCARD_KEY_BANKNAME   @"bankName"
#define BANKCARD_KEY_BANKNAME_CH   @"银行名称"
#define BANKCARD_KEY_CARDNAME   @"cardName"
#define BANKCARD_KEY_CARDNAME_CH   @"卡名称"
#define BANKCARD_KEY_CARDNO     @"cardNumber"
#define BANKCARD_KEY_CARDNO_CH     @"卡号"
#define BANKCARD_KEY_CARDTYPE   @"cardType"
#define BANKCARD_KEY_CARDTYPE_CH   @"卡类型"

