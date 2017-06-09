//
//  ImagePreviewViewController.m
//  CloudOCR
//
//  Created by yiqiao on 2017/6/5.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "ImagePreviewViewController.h"
#import "WSOperator.h"

@interface ImagePreviewViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@end

@implementation ImagePreviewViewController

@synthesize img = _img;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imgView.image = self.img;
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews{
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
