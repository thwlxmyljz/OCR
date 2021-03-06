//
//  OcrTableViewController.m
//  CloudOCR
//
//  Created by yiqiao on 2017/5/24.
//  Copyright © 2017年 yiqiaoyiqiaoyiqiao. All rights reserved.
//

#import "OcrTableViewController.h"
#import "UIViewController+SlideMenuControllerOC.h"
#import "ViewController.h"
#import "OcrType.h"
#import "BankTableViewShower.h"
#import "IdCardTableViewShower.h"
#import "BooksOp.h"
#import "UIColor+SlideMenuControllerOC.h"
#import "constants.h"
#import "CardKey.h"
#import "UIView+Toast.h"
#import "RightViewController.h"
#import "WSOperator.h"
#import "NotificationView.h"
#import "NSNotificationAdditions.h"

@interface OcrTableViewController () <UITableViewDataSource,UITableViewDelegate,
                SlideMenuControllerDelegate,LeftMenuProtocol,UINavigationControllerDelegate,UIImagePickerControllerDelegate,HexOcrBankCardCallback,HexOcrIdCardCallback>

@property (weak, nonatomic) IBOutlet UIView *panel;
@property (weak, nonatomic) IBOutlet UIButton *btnTrash;

@property (weak, nonatomic) IBOutlet UIButton *btnTakePhotos;
@property (weak, nonatomic) IBOutlet UIButton *btnLocalPhotos;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextView *txtResult;

@property (strong, nonatomic) NSMutableDictionary* dicResult;//识别结果字典
@property (strong, nonatomic) NSString* imageFile;//选择手机图片文件
@property (strong, nonatomic) UIImageView *tipView;//遮盖图


@property (strong, nonatomic) TableViewShower* CurShower;

@property (strong, nonatomic) NSMutableDictionary* Showers;

@end

HexMOcr* mOcr = nil;

@implementation OcrTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.imageView.hidden = TRUE;
    self.txtResult.hidden = TRUE;
    [BooksOp setExtraCellLineHidden:self.tableView];
    
    //加载页面处理器
    self.Showers = [[NSMutableDictionary alloc] init];

    TableViewShower* vv = nil;
    
    //身份证
    vv = [[IdCardTableViewShower alloc] init];
    vv.Owner = self;
    [self.Showers setValue:vv forKey:Class_Personal_IdCard];
    
    //银行卡
    vv = [[BankTableViewShower alloc] init];
    vv.Owner = self;
    [self.Showers setValue:vv forKey:Class_Personal_BankCard];
    
    //公共显示
    vv = [[TableViewShower alloc] init];
    vv.Owner = self;
    [self.Showers setValue:vv forKey:Class_Normal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processOcrFresh:)
                                                 name:NOTIFY_OCRFRESH
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processUserChange:)
                                                 name:NOTIFY_USERCHANGE
                                               object:nil];
    
    //设置初始显示页面
    BOOL b = FALSE;
    for (NSString* key in [OcrType Ocrs]){
        for (OcrType* type in [[OcrType Ocrs] objectForKey:key]){
            if ([type.TypeName isEqualToString:[BooksOp Instance].CurClass]){
                [self changeViewController:type];
                b =  TRUE;
                break;
            }
        }
        if (b)
            break;
    }
    
    [self performSelectorInBackground:@selector(syncOcr) withObject:nil];
}
-(void)syncOcr
{
    //先同步类型
    [OcrType syncSvrTypes];
    
    //再同步识别数据
    [OcrCard syncSvrCards];
}
- (void)processOcrFresh:(NSNotification *)notification
{
    if ([_CurShower.OcrClass isEqualToString: [[ notification userInfo ] objectForKey: @"ocrclass"]]){
        //当前分类新数据
        int cardId = [[[ notification userInfo ] objectForKey: @"cardid"] intValue];
        OcrCard* newCard = [OcrCard LoadOne:cardId];
        if (!newCard){
            NSLog(@"not load new card");
            return;
        }
        int op = [[[ notification userInfo ] objectForKey: @"op"] intValue];
        if (op == 1){
            [_CurShower InsertOcrCard:newCard];
            [self freshTitle];
            return;
        }
        if (op == 2){
            [_CurShower UpdateOcrCard:newCard];
            return;
        }
    }
    else{
        //数据非当前显示分类并设置切换分类，则切换到新分类显示
        if ([[ notification userInfo ] objectForKey: @"change"] != nil){
            OcrType* ocrType = [OcrType GetOcrType:[[ notification userInfo ] objectForKey: @"ocrclass"]];
            if (ocrType){
                [self changeViewController:ocrType ];
            }
        }
    }
}
-(void)freshTitle
{
    OcrType* curShowType = [OcrType GetOcrType:_CurShower.OcrClass];
    if (curShowType){
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (%d)",curShowType.TypeName,[OcrCard Count:_CurShower.OcrClass]];
    }
}
-(void)processUserChange:(NSNotification*)notification
{
    [self.CurShower UnloadData];
    
    [self performSelectorInBackground:@selector(syncOcr) withObject:nil];
}
- (IBAction)trashOcr:(id)sender {
    [self.tableView setEditing:!self.tableView.editing];
}
- (IBAction)localPhoto:(id)sender {
    [self localPhoto];
}
- (IBAction)takePhoto:(id)sender {
    if ([self.CurShower.OcrClass isEqualToString: Class_Personal_IdCard]){
        [self scanIdCard];
    }
    else if ([self.CurShower.OcrClass isEqualToString: Class_Personal_BankCard]){
        [mOcr showBankCardOcrView:self];
    }
    else{
        //其他类型本地无法识别，拍照后调用服务器接口进行识别
        [self takePhoto];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarItem];
    [self removeGestures];
}
-(void)viewWillLayoutSubviews
{
}

#pragma mark - SlideMenuControllerDelegate
-(void)leftWillOpen {
    NSLog(@"SlideMenuControllerDelegate: leftWillOpen");
}

-(void)leftDidOpen {
    NSLog(@"SlideMenuControllerDelegate: leftDidOpen");
}

-(void)leftWillClose {
    NSLog(@"SlideMenuControllerDelegate: leftWillClose");
}

-(void)leftDidClose {
    NSLog(@"SlideMenuControllerDelegate: leftDidClose");
    [self removeGestures];
}

-(void)rightWillOpen {
    NSLog(@"SlideMenuControllerDelegate: rightWillOpen");
}

-(void)rightDidOpen {
    NSLog(@"SlideMenuControllerDelegate: rightDidOpen");
}

-(void)rightWillClose {
    NSLog(@"SlideMenuControllerDelegate: rightWillClose");
}

-(void)rightDidClose {
    NSLog(@"SlideMenuControllerDelegate: rightDidClose");
    [self removeGestures];
    [UIView TTIsKeyboardVisible];
}
#pragma mark - LeftMenuProtocol
-(void)changeViewController:(OcrType *)selType
{
    NSLog(@"change type:%@",selType.TypeName);

    if ([[BooksOp Instance].CurClass isEqualToString: selType.TypeName] && self.CurShower){
        //相同类型并已显示
        return;
    }
    
    TableViewShower* shower = [self.Showers objectForKey:selType.TypeName];
    if (!shower){
        shower = [self.Showers objectForKey:Class_Normal];
    }
    
    [BooksOp Instance].CurClass = selType.TypeName;
    if (self.CurShower){
        [self.CurShower UnloadData];
    }

    self.CurShower = shower;
    [self setupCurShower:selType.TypeName];
}
-(void)setupCurShower:(NSString*)clas
{
    if ([self.CurShower isMemberOfClass:[TableViewShower class]])
    {
        [self.CurShower BaseSetUp:self.tableView WithClass:clas];
        NSLog(@"normal class shower");
    }
    else
    {
        [self.CurShower Setup:self.tableView];
        NSLog(@"inherit class shower");
    }
    [self freshTitle];
}

-(void) OnSelectOcrCard:(OcrCard*)card
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *v = (ViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"ViewController"];
    v.OcrAction = EMOcrAction_Photo;
    v.OcrClass = [BooksOp Instance].CurClass;
    v.ModifyCard = card;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
    [self.navigationController pushViewController:v animated:TRUE];
}
/*
 #pragma mark - Table view data source
 -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 return 0.0;
 }
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 return 0;
 }
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 return 0;
 }
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 return nil;
 }
 */
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - OCR
//初始化OCR引擎
+(void) initOcrEngine
{
    if (nil == mOcr){
        //更新lic文件到Document目录
        NSFileManager*fileManager =[NSFileManager defaultManager];
        NSError* error;
        NSArray* paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString* documentsDirectory =[paths objectAtIndex:0];
        
        NSString* licFile =[documentsDirectory stringByAppendingPathComponent:@"wtproject.lsc"];
        if([fileManager fileExistsAtPath:licFile]== YES){
            [fileManager removeItemAtPath:licFile error:&error];
        }
        if([fileManager fileExistsAtPath:licFile]== NO){
            NSString*resourcePath =[[NSBundle mainBundle] pathForResource:@"wtproject" ofType:@"lsc"];
            [fileManager copyItemAtPath:resourcePath toPath:licFile error:&error];
        }
        
        mOcr = [HexMOcr alloc];
        [mOcr loadEngine:Engine_IdCard];
    }
}
+(void) unitOcrEngine
{
    if (mOcr){
        [mOcr unloadAllEngine];
    }
    mOcr = nil;
}
- (void) scanIdCard
{
    /*
    static int n = 0;
    n++;
    FormType formType= (n%2==1) ? FormType::IdCard2_Front : FormType::IdCard2_Back;
    */
    FormType formType = FormType::IdCard2_Front;
    if (nil == self.tipView){
        //设置提示图片
        self.tipView=[[UIImageView alloc] init];
        self.tipView.frame = CGRectMake(0, 0, 240, 160);
        self.tipView.transform = CGAffineTransformMakeRotation(M_PI/2);
        self.tipView.center = self.view.center;
        [mOcr setIdCardScanTipView:self.tipView];
    }
    
    if (formType == FormType::IdCard2_Front){
        self.tipView.image = [UIImage imageNamed:@"tips_idcard_front"];
    }else{
        self.tipView.image = [UIImage imageNamed:@"tips_idcard_back"];
    }
    
    [mOcr showIdCardOcrView: formType Callback:self];
}
- (bool)idCardOcrEnd: (NSDictionary *)ocrResult fullCardPath:(NSString *) fullCardPath{
    //判断识别是否正确
    if ([ocrResult count]==7){
        NSString* name=[ocrResult valueForKey:@"姓名"];
        if (nil == name || [name length]==0){
            //不正确则返回false,重新识别
            return false;
        }
    }
    
    UIImage* cardImage=[UIImage imageWithContentsOfFile:fullCardPath];
    self.imageView.image = cardImage;
    
    [self showResult:ocrResult];
    return true;
}

//拍照和识别成功后返回结果图片和银行卡信息，银行卡信息保存在字典中, resultImage:卡号图像  fullImage:整张银行卡图像
- (void)bankCardOcrEnd:(int)result resultImage:(UIImage *)image resultDictionary:(NSDictionary *)ocrResult fullCardImage:(UIImage *) fullImage{
    self.imageView.image = fullImage;
    
    NSMutableDictionary* newDict = [[NSMutableDictionary alloc] init];
    for (NSString* key in ocrResult){
        if ([key isEqualToString:BANDCARD_KEY_BANKCODE]){
            [newDict setValue: [ocrResult valueForKey:key]  forKey:BANDCARD_KEY_BANKCODE_CH];
        }
        else if ([key isEqualToString:BANKCARD_KEY_BANKNAME]){
            [newDict setValue: [ocrResult valueForKey:key]  forKey:BANKCARD_KEY_BANKNAME_CH];
        }
        else if ([key isEqualToString:BANKCARD_KEY_CARDNAME]){
            [newDict setValue: [ocrResult valueForKey:key]  forKey:BANKCARD_KEY_CARDNAME_CH];
        }
        else if ([key isEqualToString:BANKCARD_KEY_CARDNO]){
            [newDict setValue: [ocrResult valueForKey:key]  forKey:BANKCARD_KEY_CARDNO_CH];
        }
        else if ([key isEqualToString:BANKCARD_KEY_CARDTYPE]){
            [newDict setValue: [ocrResult valueForKey:key]  forKey:BANKCARD_KEY_CARDTYPE_CH];
        }
    }
    [self showResult:newDict];
}

//从相册选择
-(void)localPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //资源类型为图片库
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil ];
    
}

//拍照
-(void)takePhoto{
    //资源类型为照相机
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //判断是否有相机
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        //资源类型为照相机
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil ];
        
    }else {
        NSLog(@"该设备无摄像头");
    }
}

#pragma Delegate method UIImagePickerControllerDelegate
//图像选取器的委托方法，选完图片后回调该方法
- (void) imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage* tempImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIGraphicsBeginImageContext(tempImage.size);
    [tempImage drawInRect:CGRectMake(0, 0, tempImage.size.width, tempImage.size.height)];
    UIImage *image = [UIImage imageWithCGImage:[UIGraphicsGetImageFromCurrentImageContext() CGImage]];
    UIGraphicsEndImageContext();
    //关闭相册界面
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (image != nil) {
        if ([self.CurShower.OcrClass isEqualToString: Class_Personal_IdCard]){
            //目前本地ocr接口图片识别只支持身份证识别
            [self performSelectorInBackground:@selector(setImage:) withObject:image];
        }
        else
         {
            //其他类型图片上传服务器识别
            self.imageView.image = image;
            [self showResult:nil];
        }
        
    }
    
}

-(void)setImage:(UIImage*) image{
    
    //获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    //保存图片的路径
    NSString* filePath = [documentPath stringByAppendingPathComponent:@"image.jpg"];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL existsFile = [manager fileExistsAtPath:filePath];
    if(existsFile) {
        //NSLog(@"success=%d",success);
        [manager removeItemAtPath:filePath error:nil];
    }
    
    //取得原图的高宽比例（适应所有的屏幕宽高比例）
    float scaleHW = image.size.height / image.size.width;
    int h = 960;
    if (image.size.width < image.size.height){
        //竖屏时，调整目标高度
        h = (int) (960*scaleHW);
    }
    //根据高宽比例计算出目标宽度
    int w = (int) (h / scaleHW);
    NSLog(@"压缩图片大小");
    //压缩图片到目标大小
    UIImage *reSizeImage = [self scaleToSize:image size:CGSizeMake(w, h)];
    //存储图片
    [UIImageJPEGRepresentation(reSizeImage, 1.0f) writeToFile:filePath atomically:YES];
    //存系统照片库，调用这句
    UIImageWriteToSavedPhotosAlbum(reSizeImage, nil, nil, nil);
    self.imageFile=filePath;
    self.imageView.image = reSizeImage;

    [self performSelectorOnMainThread:@selector(recogImage) withObject:nil waitUntilDone:YES];

}
-(void) recogImage{
    NSMutableDictionary* ocrResult = [NSMutableDictionary dictionaryWithCapacity:8];
    self.imageView.image = [UIImage imageWithContentsOfFile:self.imageFile];
    NSLog(@"开始识别");
    int nRet=[mOcr readFromFile:self.imageFile FormType:IdCard2_Front Result:ocrResult];
    if (nRet <= 0){
        [self.view makeToast:@"识别失败"];
    }else{
        [self showResult:ocrResult];
    }
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}


-(void) showResult:(NSDictionary*) ocrResult
{
    if (ocrResult)
        self.dicResult = [ocrResult copy];//本地已识别
    else
        self.dicResult = nil;//待服务器识别

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *v = (ViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"ViewController"];
    v.OcrAction = EMOcrAction_Photo;
    v.OcrClass = [BooksOp Instance].CurClass;
    v.OcrImage = self.imageView.image;
    v.OcrData = self.dicResult;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController pushViewController:v animated:TRUE];
}

@end