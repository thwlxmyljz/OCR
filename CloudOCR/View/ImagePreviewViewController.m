//
//  ImagePreviewViewController.m
//  CloudOCR
//
//  Created by yiqiao on 2017/6/5.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "ImagePreviewViewController.h"
#import "WSOperator.h"
#import "OcrCard.h"

@interface ImagePreviewViewController ()

@property (strong, nonatomic) UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ImagePreviewViewController

@synthesize OcrImage = _OcrImage;
@synthesize OcrXml = _OcrXml;
@synthesize OcrFileName = _OcrFileName;
@synthesize ClickKey = _ClickKey;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imgView = [[UIImageView alloc] initWithImage:self.OcrImage];
    self.imgView.frame = CGRectMake(0, 0, self.imgView.frame.size.width, self.imgView.frame.size.height);
    [self.scrollView addSubview:self.imgView];
    NSLog(@"viewsize(%f,%f)",self.imgView.frame.size.width,self.imgView.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(self.imgView.frame.size.width, self.imgView.frame.size.height);
    
    [self positionRect];
}
-(void)positionRect
{
    if (!self.ClickKey)
        return;
    NSMutableDictionary* rectDict = [OcrCard getXmlKeyRect:self.OcrXml forDocFileName:self.OcrFileName];
    if (!rectDict)
        return;
    NSString* rectStr = [rectDict objectForKey:self.ClickKey];
    if (!rectStr)
        return;
    NSArray* posArr = [rectStr componentsSeparatedByString:@","];
    if (posArr.count != 4)
        return;
    NSString* posStr = posArr[0];
    posStr = [posStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int left = [posStr intValue];
    posStr = posArr[1];
    posStr = [posStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int top = [posStr intValue];
    posStr = posArr[2];
    posStr = [posStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int width = [posStr intValue];
    posStr = posArr[3];
    posStr = [posStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int height = [posStr intValue];
    CGRect rc = CGRectMake(left, top, width, height);
    
    UIGraphicsBeginImageContext(self.imgView.frame.size);
    [self.imgView.image drawInRect:self.imgView.frame];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(),1.5);
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(),YES);
    const CGFloat *components = CGColorGetComponents([UIColor redColor].CGColor);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), components[0], components[1], components[2],1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextAddRect(UIGraphicsGetCurrentContext(),rc);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.imgView.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.imgView setNeedsDisplay];
    
    CGRect vRect = CGRectMake(rc.origin.x-100, rc.origin.y-30, rc.size.width+50, rc.size.height+50);
    [self.scrollView scrollRectToVisible:vRect animated:TRUE];
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
