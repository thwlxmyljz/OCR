//
//  ViewController.m
//  HexMOcrSample
//
//  Created by Hex on 15/5/27.
//  Copyright (c) 2015年 Hex. All rights reserved.
//

#import "ViewController.h"
#import "constants.h"
#import "OcrCard.h"
#import "BooksOp.h"
#import "UIView+AnimationOptionsForCurve.h"
#import "CardKey.h"
#import "CardTableViewCell.h"
#import "UITableView+SlideMenuControllerOC.h"
#import "UIView+Toast.h"
#import "NotificationView.h"
#import "NSNotificationAdditions.h"
#import "UIViewController+SlideMenuControllerOC.h"
#import "ImagePreviewViewController.h"
#import "WSOperator.h"

@interface ViewController()  <UINavigationControllerDelegate,UIImagePickerControllerDelegate,
                                UITableViewDataSource,UITableViewDelegate>
{
    //触发键盘的UITextView
    UITextView_CardCell* _keyInputField;
    //卡片信息字典
    NSMutableDictionary* _orgDict;
    //卡片按key序显示在tableview
    NSMutableArray* _showKeys;
    //保存编辑过的数据
    NSMutableDictionary* _modifyDict;
    //新识别的本地信息
    int _CardId;//本地id
    NSString* _SvrId;//服务器识别id
    NSString* _SvrFileName;//本地文件名
    //等待框
    GCDiscreetNotificationView *notificationView;
    //图片显示
    UIView* _headView;
}
@end


@implementation ViewController

@synthesize OcrAction = _OcrAction;
@synthesize OcrClass = _OcrClass;
@synthesize OcrImage = _OcrImage;
@synthesize OcrData = _OcrData;
@synthesize OcrXml = _OcrXml;
@synthesize ModifyCard = _ModifyCard;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.frame = self.view.frame;
    self.navigationItem.title = @"识别结果";
    
    [BooksOp setExtraCellLineHidden:self.tableView];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view setUserInteractionEnabled:TRUE];
    [self.view addGestureRecognizer:tapGr];
    
    UISwipeGestureRecognizer * recognizer3 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapped:)];
    [recognizer3 setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.tableView addGestureRecognizer:recognizer3];
    
    
    UISwipeGestureRecognizer * recognizer4 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapped:)];
    [recognizer4 setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.tableView addGestureRecognizer:recognizer4];
    
    _modifyDict = [[NSMutableDictionary alloc] init];
    //修改已有识别记录
    if (self.ModifyCard){
        self.OcrImage = self.ModifyCard.CardImg;
        self.OcrData = self.ModifyCard.CardDetail;
        self.OcrXml = self.ModifyCard.SvrDetail;
        _SvrId = self.ModifyCard.CardSvrId;
        _SvrFileName = [self.ModifyCard GetFileName];
    }
    [self setup];
}
-(void)showData
{
    RMNOTIFYVIEW
    if (self.OcrData.count == 0){
        [self.view makeToast:@"没有识别到数据" duration:2.0f  position:@"center"];
        return;
    }
    UIBarButtonItem *navSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(OnSave)];
    self.navigationItem.rightBarButtonItem = navSave;
    
    UIImageView* imgView = [_headView viewWithTag:1000];
    if (imgView){
        imgView.image = self.OcrImage;
        [imgView setNeedsDisplay];
    }
    _orgDict = [[NSMutableDictionary alloc] initWithDictionary:self.OcrData];
    [self createKeys];
    [self.tableView reloadData];
}
-(void)setup
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 100)];
    _headView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 80)];
    imgView.image = self.OcrImage;
    imgView.tag = 1000;
    [_headView addSubview:imgView];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHeadViewTapped:)];
    [imgView addGestureRecognizer:recognizer];
    imgView.userInteractionEnabled = TRUE;
    imgView.center = CGPointMake(SCREENW/2, 100/2);
    
    self.tableView.tableHeaderView = _headView;
    [self.tableView registerCellNib:[CardTableViewCell class]];
    
    if (self.OcrData){
        //已识别数据
        [self showData];
    }
    else{
        //未识别图片，上传到服务器识别
        if (!notificationView){
            notificationView = [[GCDiscreetNotificationView alloc] initWithText:@"正在识别..."
                                                                   showActivity:TRUE
                                                             inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                         inView:self.tableView];
        }
        [notificationView showAnimated];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //生产文件名和本地识别id
            [self creatSvrOcrUpInfo];
            //上传识别
            _SvrId = [WSOperator uploadOCR:@"GENERAL_FORM" OcrImg:self.OcrImage SvrType:@"addFile" SvrFileName:_SvrFileName];
            NSLog(@"%@",_SvrId);
            if ([_SvrId isEqualToString:@""]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    RMNOTIFYVIEW
                    [BooksOp displayError:@"无法连接服务器" withTitle:@""];
                });
            }
            else{
                //上传图片成功，下载识别结果
                for (int i = 0; i < 4; i++){
                    [NSThread sleepForTimeInterval:5.0f];
                    self.OcrData = [WSOperator downloadOCR_XML:_SvrId FileName:_SvrFileName];
                    if (self.OcrData){
                        self.OcrXml = [self.OcrData objectForKey:@"xmldata"];
                        [self.OcrData removeObjectForKey:@"xmldata"];
                        //下载识别处理过后的图片
                        NSData* svrImg = [WSOperator downloadOCR_Img:_SvrId SvrFileName:_SvrFileName];
                        if (svrImg){
                            self.OcrImage = [UIImage imageWithData:svrImg];
                        }
                        break;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showData];
                });
            }
        });
    }
}
-(void)creatSvrOcrUpInfo
{
    _CardId = [BooksOp Instance].CardID;
    _SvrFileName = [OcrCard GetFileName:_CardId];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillLayoutSubviews
{
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerKeyboardNotify];
    [self removeGestures];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer
{
    [UIView TTIsKeyboardVisible];
}
-(void)handleHeadViewTapped:(UITapGestureRecognizer*)tapGr
{
    [self showPictureWithClickKey:nil];
}
-(void)showPictureWithClickKey:(NSString*)clickKey
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ImagePreviewViewController *v = (ImagePreviewViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
    v.OcrImage = self.OcrImage;
    v.OcrXml = self.OcrXml;
    v.OcrFileName = _SvrFileName;
    v.ClickKey = clickKey;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController pushViewController:v animated:TRUE];
}
-(void)OnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:FALSE];
}

-(void)OnSave
{
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
    //先失去焦点，让输入控件都得到输入值
    [UIView TTIsKeyboardVisible];

    if (!notificationView){
        notificationView = [[GCDiscreetNotificationView alloc] initWithText:@"保存..."
                                                               showActivity:TRUE
                                                         inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                     inView:self.tableView];
    }
 
    [notificationView showAnimated];
    [BooksOp scrollTableViewToTop:self.tableView Animated:FALSE];
 
    [self performSelector:@selector(realSave) withObject:nil afterDelay:0.1f];
}
-(void)realSave
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.ModifyCard){
            //新建
            for (NSString* key in [_modifyDict allKeys]){
                [_orgDict setObject:[_modifyDict objectForKey:key] forKey:key];
            }
            OcrCard* card = [[OcrCard alloc] init];
            card.OcrClass = self.OcrClass;
            card.CardId = _CardId;
            card.CardSvrId = _SvrId?_SvrId:@"";
            card.CardDetail = _orgDict;
            card.ModifyDetail = _modifyDict;
            card.CardImg = self.OcrImage;
            card.CardSvrImg = self.OcrImage;
            card.SvrDetail = self.OcrXml;
            if ([card Insert]){
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NOTIFY_OCRFRESH object:nil
                                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                            [NSNumber numberWithInt:card.CardId], @"cardid",
                                                                                            [NSNumber numberWithInt:1]/*新卡片*/, @"op",
                                                                                            nil]];
                [self OnBack:nil];
            }
            else{
                RMNOTIFYVIEW
                self.navigationItem.rightBarButtonItem.enabled = TRUE;
                [BooksOp displayError:@"保存失败" withTitle:@""];
            }
        }
        else{
            //修改
            if ([_modifyDict allKeys].count == 0){
                [self OnBack:nil];
            }
            else{
                for (NSString* key in [_modifyDict allKeys]){
                    [_orgDict setObject:[_modifyDict objectForKey:key] forKey:key];
                }
                self.ModifyCard.CardDetail = _orgDict;
                self.ModifyCard.ModifyDetail = _modifyDict;
                if ([self.ModifyCard Update_noImg]){
                    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NOTIFY_OCRFRESH object:nil
                                                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                [NSNumber numberWithInt:self.ModifyCard.CardId], @"cardid",[NSNumber numberWithInt:2/*刷新卡片*/], @"op",
                                                                                                nil]];
                    [self OnBack:nil];
                }
                else{
                    RMNOTIFYVIEW
                    self.navigationItem.rightBarButtonItem.enabled = TRUE;
                    [BooksOp displayError:@"保存失败" withTitle:@""];
                }
            }
        }
    });
}
#pragma mark - keyboard event
-(void)registerKeyboardNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification
{
    CGFloat rowHeight = [CardTableViewCell height];
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    int i = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationCurve curve =(UIViewAnimationCurve) i;
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:[UIView animationOptionsForCurve:curve]
                     animations:^{
                         if (keyboardRect.origin.y >= SCREEN_HEIGHT){
                             //隐藏键盘
                         }
                         else{
                             //显示键盘
                             CGFloat keyboardHeight = keyboardRect.size.height;
                             CGFloat curCellTopY = _keyInputField.topY;//当前点击的cell的topY
                             CGFloat curCellBottomY = curCellTopY+rowHeight;
                             CGFloat screeHeight = SCREEN_HEIGHT-STATUS_BASE_HEIGHT-NAV_HEIGHT;
                             if (curCellBottomY + keyboardHeight > screeHeight-rowHeight){
                                 CGFloat canSeeHeight = screeHeight-keyboardHeight;
                                 CGFloat offsetHeight = curCellBottomY-canSeeHeight;
                                 [self.tableView setContentOffset:CGPointMake(0, offsetHeight) animated:TRUE];
                             }
                             else{
                                 [BooksOp scrollTableViewToTop:self.tableView Animated:TRUE];
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

#pragma mark - textfield delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _keyInputField = (UITextView_CardCell*)textView;
    return TRUE;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _keyInputField = (UITextView_CardCell*)textView;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == _keyInputField)
        _keyInputField = nil;
    UITextView_CardCell* field = (UITextView_CardCell*)textView;
    [_modifyDict setValue:textView.text forKey:field.key];
}

#pragma mark - Table view data source
-(void)createKeys
{
    //按类型进行显示key的排序
    _showKeys = [[NSMutableArray alloc] init];
    EMOcrClass cls = self.ModifyCard?self.ModifyCard.OcrClass:self.OcrClass;
    switch (cls) {
        case Class_Personal_IdCard:
            [_showKeys addObject:IDCARD_KEY_NAME];
            [_showKeys addObject:IDCARD_KEY_SEX];
            [_showKeys addObject:IDCARD_KEY_MZ];
            [_showKeys addObject:IDCARD_KEY_NO];
            [_showKeys addObject:IDCARD_KEY_BIRTHDAY];
            [_showKeys addObject:IDCARD_KEY_ADDRESS];
            break;
        case Class_Personal_BankCard:
            [_showKeys addObject:BANDCARD_KEY_BANKCODE_CH];
            [_showKeys addObject:BANKCARD_KEY_BANKNAME_CH];
            [_showKeys addObject:BANKCARD_KEY_CARDNAME_CH];
            [_showKeys addObject:BANKCARD_KEY_CARDNO_CH];
            [_showKeys addObject:BANKCARD_KEY_CARDTYPE_CH];
            break;
        default:
            for (NSString* key in [self.OcrData allKeys]){
                [_showKeys addObject:key];
                NSLog(@"add showkey:%@",key);
            }
            break;
    }
}
+(CGFloat) SectionHeight
{
    return 22.0f;
}
//获取到某个indexPath的cell的起始y坐标
-(CGFloat)getCellTopY:(NSIndexPath *)indexPath
{
    CGFloat ff = self.tableView.tableHeaderView.frame.size.height+(indexPath.section+1)*[ViewController SectionHeight];
    for (int i = 0; i < indexPath.row; i++){
        CardTableViewCellData *data = [CardTableViewCellData new];
        data.key = [_showKeys objectAtIndex:i];
        data.value = [_orgDict objectForKey:data.key];
        ff +=  [CardTableViewCell heightForData:data];
    }
    return ff;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CardTableViewCellData *data = [CardTableViewCellData new];
    data.key = [_showKeys objectAtIndex:indexPath.row];
    data.value = [_orgDict objectForKey:data.key];
    return  [CardTableViewCell heightForData:data];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [ViewController SectionHeight];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _showKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CardTableViewCell *cell = (CardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CardTableViewCell identifier]];
    cell.edtValue.topY = [self getCellTopY:indexPath];//设置topY
    cell.edtValue.delegate = self;
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(captionTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [cell.lblCaption setUserInteractionEnabled:TRUE];
    [cell.lblCaption addGestureRecognizer:tapGr];
    
    CardTableViewCellData *data = [CardTableViewCellData new];
    data.key = [_showKeys objectAtIndex:indexPath.row];
    data.value = [_orgDict objectForKey:data.key];
    [cell setData:data];
    
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * view = [[UILabel alloc] init];
    view.backgroundColor = SECTIONBKCOLOR;
    view.font = [UIFont systemFontOfSize:14.0f];
    view.frame = CGRectMake(0, 0, tableView.frame.size.width, 22.0f);
    view.textColor = UIColorFromRGBA(0x666666, 1.0f);
    view.textAlignment = NSTextAlignmentLeft;
    return view;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}
- (void)captionTapped:(UITapGestureRecognizer *)recognizer
{
    [UIView TTIsKeyboardVisible];
    UILabel *lblCaption=(UILabel*)recognizer.view;
    [self showPictureWithClickKey:lblCaption.text];
}
@end
