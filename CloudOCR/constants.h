/**
 *  Siphon SIP-VoIP for iPhone and iPod Touch
 *  Copyright (C) 2008-2010 Samuel <samuelv0304@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */


#ifndef __SIPHON_CONSTANTS_H__
#define __SIPHON_CONSTANTS_H__

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define GET_MIANFRAME(rc) if IS_IPHONE_4_OR_LESS rc = CGRectMake(0,0,320,480);\
                        else if IS_IPHONE_5 rc = CGRectMake(0,0,320,568);\
                        else if IS_IPHONE_6 rc = CGRectMake(0,0,375,667);\
                        else if IS_IPHONE_6P rc = CGRectMake(0,0,414,736);\
                        else rc = CGRectMake(0,0,320,480);

#define GET_MAIN_WEBFRAME(rc) GET_MIANFRAME(rc);\
                        rc = CGRectMake(rc.origin.x, rc.origin.y, rc.size.width, rc.size.height-49);

#define GET_WEBFRAME(rc) GET_MIANFRAME(rc);\
                        rc = CGRectMake(rc.origin.x, rc.origin.y+64, rc.size.width, rc.size.height-64);
//--------------------------------------------------------------------------

#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IMGBARBUTTON(IMAGE, SELECTOR) [[UIBarButtonItem alloc] initWithImage:IMAGE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR]
#define CUSTOMBARBUTTON(VIEW) [[UIBarButtonItem alloc] initWithCustomView:VIEW]

//建立导航条左边返回按钮，UIViewController需要实现OnBack:函数
#define NEWLEFTBUTTON(caption) UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];\
                            [homeButton setTitle:caption forState:UIControlStateNormal];\
                            homeButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];\
                            [homeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];\
                            [homeButton sizeToFit];\
                            CGRect realsize = homeButton.bounds;\
                            homeButton.frame = CGRectMake(0, 0, realsize.size.width+30+12, 44);\
                            [homeButton setImage:[UIImage imageNamed:@"bkspace"] forState:UIControlStateNormal];\
                            [homeButton addTarget:self action:@selector(OnBack:) forControlEvents:UIControlEventTouchUpInside];\
                            [homeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];\
                            UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:homeButton];\
                            if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7)\
                            {\
                                UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];\
                                negativeSpacer.width = -22;\
                                self.navigationItem.leftBarButtonItems = @[negativeSpacer, homeButtonItem];\
                            }\
                            else\
                            {\
                                self.navigationItem.leftBarButtonItem = homeButtonItem;\
                            }
//建立导航条左边返回+关闭按钮，UIViewController需要实现OnBack:函数，OnClose:函数
#define NEWLEFTBUTTON_CLOSE(caption) UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];\
                            [homeButton setTitle:caption forState:UIControlStateNormal];\
                            homeButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];\
                            [homeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];\
                            [homeButton sizeToFit];\
                            CGRect realsize = homeButton.bounds;\
                            homeButton.frame = CGRectMake(0, 0, realsize.size.width+30+12, 44);\
                            [homeButton setImage:[UIImage imageNamed:@"bkspace"] forState:UIControlStateNormal];\
                            [homeButton addTarget:self action:@selector(OnBack:) forControlEvents:UIControlEventTouchUpInside];\
                            [homeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];\
                                UIButton *cloButton = [UIButton buttonWithType:UIButtonTypeCustom];\
                                [cloButton setTitle:@"关闭" forState:UIControlStateNormal];\
                                cloButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];\
                                [cloButton sizeToFit];\
                                realsize = cloButton.bounds;\
                                cloButton.frame = CGRectMake(homeButton.frame.size.width, 0, 36, 44);\
                                [cloButton addTarget:self action:@selector(OnClose:) forControlEvents:UIControlEventTouchUpInside];\
                                [cloButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];\
                                UIView* xxleftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,homeButton.frame.size.width+cloButton.frame.size.width,44)];\
                                [xxleftView addSubview:homeButton];\
                                [xxleftView addSubview:cloButton];\
                            UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:xxleftView];\
                            if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7)\
                            {\
                                UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];\
                                negativeSpacer.width = -22;\
                                self.navigationItem.leftBarButtonItems = @[negativeSpacer, homeButtonItem];\
                            }\
                            else\
                            {\
                                self.navigationItem.leftBarButtonItem = homeButtonItem;\
                            }

//导航时设置状态条背景颜色
#define SETSTATUSBAR_NAV() UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 20)];\
                             statusBarView.backgroundColor = NAV_BKCOLOR;\
                            [self.navigationController.navigationBar addSubview:statusBarView];\
                            self.navigationController.navigationBar.translucent = NO;
//modal显示视图控制器时设置状态条背景颜色
#define SETSTATUSBAR_DLG() UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];\
                            statusBarView.backgroundColor = NAV_BKCOLOR;\
                            [self.view addSubview:statusBarView];

#define SETVIEWBKG() self.view.backgroundColor = [UIColor whiteColor];

#define SCREENH ([UIScreen mainScreen].bounds.size.height)
#define SCREENW ([UIScreen mainScreen].bounds.size.width)


#define RMNOTIFYVIEW {if (notificationView)[notificationView removeFromSuperview];notificationView = nil;}
//--------------------------------------------------------------------------

#define TABBAR_HEIGHT 49 //tabbar的高度
#define NAV_HEIGHT 44 //导航条高度
#define STATUS_BASE_HEIGHT 20 //状态栏初始高度，在有呼叫的时候变为40

#define VIEW_BEGTIN_TOP (NAV_HEIGHT+STATUS_BASE_HEIGHT)//非tableview组件位于界面(self.view)顶端时组件的起始位置

#define ANIMATION_TIME 0.25f //动画

//记录tablecell
#define HISTABLECELL_HEIGHT 56.0f   //行高度
#define HISTABLE_SPLIT_LEFT 9   //图片与左右边界间隔
#define HISTABLE_SPLIT_TOP  9    //图片上间隔
#define HISTABLE_SPLIT_TXTTOP 8  //主标题上间隔
#define HISTABLEPIC_HEIGHT  52   //照片高度
#define HISTABLEPIC_WIDTH   78   //照片宽度
#define HISTABLEPIC_HEIGHT_MAINTXT 20 //主标题高度
#define HISTABLEPIC_HEIGHT_SUBTXT  16 //副标题高度
#define TIPPIC_HEIGHT       20   //tip标注高度
#define TIPPIC_HEIGHT_BIG   22   //tip标注高度

#define SECTION_HEIGHT_FORSEARCH 46.0f
#define SECTION_HEIGHT 46.0f
#define SECTION_ATOZ   22.0f

#define HISTABLE_MAINFONT() [UIFont systemFontOfSize:17.0f]//主标题字体
#define HISTABLE_SUBFONT() [UIFont systemFontOfSize:14.0f]//副标题字体
#define HISTABLE_TIMEFONT() [UIFont systemFontOfSize:13.5f] //时间字体

#define SELTXTCOLOR [UIColor brownColor] //变颜色label的变色字的颜色

#define UIColorFromRGBA(rgbValue, alphaValue) \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
            green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
            blue:((float)(rgbValue & 0x0000FF))/255.0 \
            alpha:alphaValue]

#define WEB_SELTXT_COLOR UIColorFromRGBA(0xf5a623,1.0f)
#define WEB_MAINTXT_COLOR UIColorFromRGBA(0x000000,1.0f)
#define WEB_SUBTXT_COLOR UIColorFromRGBA(0x999999,1.0f)
#define WEB_VIEWBK_COLOR UIColorFromRGBA(0xf6f6f6,1.0f)
#define NAV_BKCOLOR UIColorFromRGBA(0xffffff,1.0f)
#define MTS_SELTXT_COLOR [UIColor blueColor]

#define USERBTNBKCOLOR UIColorFromRGBA(0xf6f6f6,1.0f) //自定义按钮的背景色
#define SECTIONBKCOLOR UIColorFromRGBA(0xf8f8f8,1.0f) //tableview的section的背景色

//--------------------------------------------------------------------------
//获取i的第c位,c从0开始
#define GETBIT(i,c) (i&(1<<c))
//设置i的第c位为1，c从0开始
#define SETBIT(i,c) (i|(1<<c))
//设置i的第c位为0，c从0开始
#define RESETBIT(i,c) (i&~(1<<c))
//--------------------------------------------------------------------------
#define KEYBOARDHEIGHT 216

#define NOTIFY_OCRFRESH @"NOTIFY_OCRFRESH"   //名片刷新
#define NOTIFY_TYPEFRESH @"NOTIFY_TYPEFRESH" //类型刷新
#define NOTIFY_USERCHANGE @"NOTIFY_USERCHANGE" //用户更改

#endif /* __SIPHON_CONSTANTS_H__ */
