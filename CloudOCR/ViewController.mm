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

@interface ViewController()  <UINavigationControllerDelegate,UIImagePickerControllerDelegate,
                                UITableViewDataSource,UITableViewDelegate,HexOcrBankCardCallback,HexOcrIdCardCallback>
{
    //触发键盘的UITextField
    UITextField_CardCell* _keyInputField;
    //卡片信息字典
    NSMutableDictionary* _orgDict;
    //卡片按key序显示在tableview
    NSMutableArray* _showKeys;
    //保存编辑过的数据
    NSMutableDictionary* _modifyDict;
    //等待框
    GCDiscreetNotificationView *notificationView;
    
    CGPoint _tableContentOrigin;
}
@end


@implementation ViewController

@synthesize OcrAction = _OcrAction;
@synthesize OcrClass = _OcrClass;
@synthesize OcrImage = _OcrImage;
@synthesize OcrData = _OcrData;

@synthesize ModifyCard = _ModifyCard;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.frame = self.view.frame;

    UIBarButtonItem *navSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(OnSave)];
    //self.navigationItem.rightBarButtonItems = @[navSave];
    self.navigationItem.rightBarButtonItem = navSave;
    
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
    
    //修改已有识别记录
    if (self.ModifyCard){
        _modifyDict = [[NSMutableDictionary alloc] init];
        [self setup:self.tableView Image:self.ModifyCard.CardImg OcrDict:self.ModifyCard.CardDetail];
    }
    else{
        [self setup:self.tableView Image:self.OcrImage OcrDict:self.OcrData];
    }
}
-(void)setup:(UITableView *)tableView Image:(UIImage *)img OcrDict:(NSDictionary *)ocrDict
{
    tableView.delegate = self;
    tableView.dataSource = self;
    
    UIView* headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 100)];
    headView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 80)];
    imgView.image = img;
    [headView addSubview:imgView];
    imgView.center = CGPointMake(SCREENW/2, 100/2);
    
    tableView.tableHeaderView = headView;
    [tableView registerCellNib:[CardTableViewCell class]];
    
    _orgDict = [[NSMutableDictionary alloc] initWithDictionary:ocrDict];
    [self createKeys];
    
    [tableView reloadData];
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

- (void)viewTapped:(id)nouse
{
    [UIView TTIsKeyboardVisible];
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
/*
    if (!notificationView){
        notificationView = [[GCDiscreetNotificationView alloc] initWithText:@"保存..."
                                                               showActivity:TRUE
                                                         inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                     inView:self.tableView.tableHeaderView];
    }
 
    [notificationView showAnimated];
 */
    [self performSelector:@selector(realSave) withObject:nil afterDelay:0.1f];
}
-(void)realSave
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.ModifyCard){
            //新建
            OcrCard* card = [[OcrCard alloc] init];
            card.OcrClass = self.OcrClass;
            card.CardId = [BooksOp Instance].CardID;
            card.CardLinkId = @"";
            card.CardPri = _orgDict;
            card.CardDetail = _orgDict;
            card.CardImg = self.OcrImage;
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
                self.ModifyCard.CardPri = _orgDict;
                if ([self.ModifyCard Update]){
                    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NOTIFY_OCRFRESH object:nil
                                                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                [NSNumber numberWithInt:self.ModifyCard.CardId], @"cardid",[NSNumber numberWithInt:2/*刷新卡片*/], @"op",
                                                                                                nil]];
                    [self OnBack:nil];
                }
                else{
                    RMNOTIFYVIEW
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
                             CGFloat curCellTopY = _keyInputField.tag;//当前点击的cell的topY
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _keyInputField = (UITextField_CardCell*)textField;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    _keyInputField = nil;
    UITextField_CardCell* field = (UITextField_CardCell*)textField;
    [_modifyDict setValue:textField.text forKey:field.key];
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
            break;
        default:
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
    return self.tableView.tableHeaderView.frame.size.height+(indexPath.section+1)*[ViewController SectionHeight]+(indexPath.row)*[CardTableViewCell height];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  [CardTableViewCell height];
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
    CardTableViewCellData *data = [CardTableViewCellData new];
    data.key = [_showKeys objectAtIndex:indexPath.row];
    data.value = [_orgDict objectForKey:data.key];
    
    [cell setData:data];
    cell.edtValue.delegate = self;
    cell.edtValue.tag = [self getCellTopY:indexPath];//设置topY
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
}

@end
