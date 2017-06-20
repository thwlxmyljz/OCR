//
//  UIViewController+SlideMenuControllerOC.m
//  SlideMenuControllerOC
//
//  Created by ChipSea on 16/2/29.
//  Copyright © 2016年 pluto-y. All rights reserved.
//

#import "UIViewController+SlideMenuControllerOC.h"
#import "SlideMenuController.h"

@implementation UIViewController (SlideMenuControllerOC)

-(void)setNavigationBarItem {
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"service1"]];
    [self addRightBarButtonWithImage:[UIImage imageNamed:@"group1"]];
    [self.slideMenuController removeLeftGestures];
    [self.slideMenuController removeRightGestures];
    [self.slideMenuController addLeftGestures];
    [self.slideMenuController addRightGestures];
}

-(void)removeNavigationBarItem {
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [self.slideMenuController removeLeftGestures];
    [self.slideMenuController removeRightGestures];
}
-(void)removeGestures
{
    [self.slideMenuController removeLeftGestures];
    [self.slideMenuController removeRightGestures];
}
-(void)addGestures
{
    [self.slideMenuController addLeftGestures];
    [self.slideMenuController addRightGestures];
}
@end
