//
//  BoardIViewController.m
//  Puzzle
//
//  Created by luntao.dlt on 14-9-16.
//  Copyright (c) 2014年 luntao.dlt. All rights reserved.
//

#import "BoardIViewController.h"

//格子个数
#define latticeNum 16;
#define latticeWidth 75;
@interface BoardIViewController ()

@end

@implementation BoardIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height+100)];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 65, self.view.frame.size.width, self.view.frame.size.height+240)];
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view addSubview:scrollView];
    scrollView.contentSize = view.frame.size;
    [scrollView addSubview:view];
    [self.view addSubview:scrollView];
    
    _currentBoardImage = [UIImage imageNamed:@"dd.png"];
    
    CGFloat scale = _currentBoardImage.size.width / self.view.frame.size.width;
    NSInteger imageHeight = _currentBoardImage.size.height;
    CGFloat newImageHeight = imageHeight / scale;
    _latticeView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, newImageHeight)];
    
    //分割方格
    [self drawLattices];
    [view addSubview:_latticeView];
    //监听图片变动，用户可以重新选择图片
    [RACObserve(self, currentBoardImage) subscribeNext:^(UIImage *image) {
        NSLog(@"currenImage");
        //重新绘制方格
        [self initImage:image];
    }];
    //打乱图片
    [self disorder];
    _shuffleButton = [[UIButton alloc]initWithFrame:CGRectMake(20, newImageHeight+10, self.view.frame.size.width-40, 40)];
    [_shuffleButton setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    [_shuffleButton setTitle:@"重新洗牌" forState:UIControlStateNormal];
    _shuffleButton.layer.borderColor = [UIColor redColor].CGColor;
    _shuffleButton.layer.borderWidth = 1.0;
    //使用RACtiveCocoa绑定到NSButton的指令
    _shuffleButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^(id _){
        [self disorder];
        return [RACSignal empty];
    }];
    
    _chooseImageButton = [[UIButton alloc]initWithFrame:CGRectMake(20, newImageHeight+60, self.view.frame.size.width-40, 40)];
    [_chooseImageButton setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    [_chooseImageButton setTitle:@"选择图片" forState:UIControlStateNormal];
    _chooseImageButton.layer.borderColor = [UIColor redColor].CGColor;
    _chooseImageButton.layer.borderWidth = 1.0;
//    [_chooseImageButton addTarget:self action:@selector(openPicChoose) forControlEvents:UIControlEventTouchUpInside];
    _chooseImageButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        [self openPicChoose];
        return [RACSignal empty];
    }];
    _timerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 40)];
    _timerLabel.text = @"用时: 00:55:53";
    _timerLabel.textAlignment = NSTextAlignmentCenter;
    _timerLabel.textColor = [UIColor whiteColor];
    
    _originView = [[UIImageView alloc]initWithImage:_currentBoardImage];
    [_originView setFrame:CGRectMake(0, newImageHeight + 110, self.view.frame.size.width, newImageHeight)];
    
    [view addSubview:_boardView];
//    [view addSubview:_timerLabel];

    [view addSubview:_shuffleButton];
    [view addSubview:_chooseImageButton];
    [view addSubview:_originView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//切割方块
-(void)drawLattices{
    _lattices = [[NSMutableDictionary alloc]init];
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            LatticeModel *latticeModel = [[LatticeModel alloc]init];
            latticeModel.point = CGPointMake(75*j+(j+8), 75*i+(i+8));
            latticeModel.sequenceId = [[NSString alloc]initWithFormat:@"%d",(i*4)+j];
            [_lattices setObject:latticeModel forKey:latticeModel.sequenceId];
        }
    }
}

//裁剪图片
-(void)cropImages:(UIImage *)image{
   _latticeImages = [[NSMutableDictionary alloc]init];
    image = [self scaleImage:image];
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(75 * j, 75*i, 75, 75));
            UIImage *imageNew = [UIImage imageWithCGImage:imageRef];
            LatticeImageView *imageView = [[LatticeImageView alloc]initWithImage:imageNew];
            imageView.frame = CGRectMake(0, 0, 75, 75);
            NSString *imageId = [[NSString alloc]initWithFormat:@"%d", (i*4)+j];
            //标记tag
            [imageView setTag:[imageId integerValue]];
            [_latticeImages setObject:imageView forKey:imageId];
            [imageView setValue:imageId forKey:@"currentPosition"];
            
            LatticeModel *latticeModel = _lattices[imageId];
            [imageView setTransform:CGAffineTransformMakeTranslation(latticeModel.point.x, latticeModel.point.y)];
            [self latticeImageEventBind:imageView];
            if (i == 3 && j== 3)return;
            [_latticeView addSubview:imageView];
            CGImageRelease(imageRef);
        }
            }
}
//图片缩放
-(UIImage *)scaleImage:(UIImage *)image{
    float frameWidth = self.view.frame.size.width;
    float width = CGImageGetWidth(image.CGImage);
    float height = CGImageGetHeight(image.CGImage);
    float scaleWidth = frameWidth;
    float scaleHeight = frameWidth/width * height;
    UIGraphicsBeginImageContext(CGSizeMake(scaleWidth, scaleHeight));
    [image drawInRect:CGRectMake(0, 0, scaleWidth, scaleHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    return newImage;
}
//打乱图片
-(void)disorder{
    for (NSString *eachKey in _lattices) {
        LatticeImageView *imageView = _latticeImages[eachKey];
        //生成一个随机数
        int random = arc4random()%16;
        NSString *randomStr = [[NSString alloc]initWithFormat:@"%d", random];
        
        NSLog(@"%@ --%@",eachKey, randomStr);
        LatticeModel *randomModel = _lattices[randomStr];
//        [imageView setTransform:CGAffineTransformMakeTranslation(randomModel.point.x, randomModel.point.y)];
        CABasicAnimation *anim0 = [CABasicAnimation animationWithKeyPath:@"transform"];
        anim0.duration = 1;
        anim0.removedOnCompletion=false;
        anim0.fillMode = @"forwards";
        anim0.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(randomModel.point.x
                                                                                   , randomModel.point.y, 0)];
        
        [imageView.layer addAnimation:anim0 forKey:@"animation"];
        
        [imageView setValue:randomStr forKey:@"currentPosition"];
        
        UIImageView *randomImageView = _latticeImages[randomStr];
        LatticeModel *currentLatticeModel = _lattices[eachKey];
        //动画的第一种写法，UIView
//        [UIView animateWithDuration:(0.5) animations:^{
//            [randomImageView setTransform:CGAffineTransformMakeTranslation(currentLatticeModel.point.x, currentLatticeModel.point.y)];
//        }];
        //动画的第二种写法CAKeyframeAnimation
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        anim.duration = 1;
//        anim.repeatCount = 1000;
//        anim.autoreverses = NO;
        anim.removedOnCompletion = false;
        anim.fillMode=@"forwards";
        CATransform3D trans = CATransform3DMakeTranslation(currentLatticeModel.point.x, currentLatticeModel.point.y, 0);
        anim.values = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:trans], nil];
        [randomImageView.layer addAnimation:anim forKey:@"nim"];
        //第三种写法CABasicAnimation
//        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
//        anim.duration = 1;
//        anim.removedOnCompletion=false;
//        anim.fillMode = @"forwards";
//        anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(currentLatticeModel.point.x
//                                                                                    , currentLatticeModel.point.y, 0)];
//        [randomImageView.layer addAnimation:anim forKey:@"transform1"];
        [randomImageView setValue:eachKey forKey:@"currentPosition"];
        _latticeImages[eachKey] = randomImageView;
        _latticeImages[randomStr] = imageView;
    }
}

//方块绑定
-(void)latticeImageEventBind:(UIImageView *)imageView{
//    imageView add
    imageView.userInteractionEnabled = true;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(latticeTouch:)];
    [imageView addGestureRecognizer:singleTap];
}
//方块点击
-(void)latticeTouch:(UITapGestureRecognizer *)tapGestureRecognizer{
    LatticeImageView *imageView = (LatticeImageView *)tapGestureRecognizer.view;
    NSString *currentPosition = [imageView currentPosition];
    //    NSLog(@"touch-%d,%@", imageView.tag, currentPosition);
    NSInteger currentPositionInt = [currentPosition integerValue];
    NSInteger moveTo = [self moveTo:currentPositionInt];
    if (moveTo != -1) {
        NSLog(@"move to %d", moveTo);
        [self exchange:currentPosition two:[[NSString alloc] initWithFormat:@"%d", moveTo]];
    }
    BOOL success =  [self checkResult];
    if (success) {
        [self showDialog];
    }
}

//两个图片块位置切换
-(void) exchange:(NSString *)one two:(NSString *)two{
    LatticeImageView *imageView1 = _latticeImages[one];
    LatticeImageView *imageView2 = _latticeImages[two];
    LatticeModel *model1 = _lattices[one];
    LatticeModel *model2 = _lattices[two];
    
    [imageView1 setTransform:CGAffineTransformMakeTranslation(model2.point.x, model2.point.y)];
    [imageView1 setValue:two forKey:@"currentPosition"];
    [imageView2 setTransform:CGAffineTransformMakeTranslation(model1.point.x, model1.point.y)];
    [imageView2 setValue:one forKey:@"currentPosition"];
    NSLog(@"From  %@  to  %@", one, two);
    _latticeImages[one] = imageView2;
    _latticeImages[two] = imageView1;
}

//判断图片块是否可移动
-(NSInteger) moveTo: (NSInteger) position{
    //计算可移动的四个方向
    NSInteger left = -1;
    NSInteger right = 1;
    NSInteger top = -4;
    NSInteger down = 4;
    //将要移动到的位置，如果不可移动，则返回-1
    NSInteger moveTo = -1;
    BOOL isRemovedAvailable = false;
    left += position;
    right += position;
    top += position;
    down += position;
    if (top > -1 ) {
        isRemovedAvailable = [self hasWhiteSpace:top];
        if (isRemovedAvailable) {
            moveTo = top;
            return  moveTo;
        }
    }
    if (down < 16) {
        isRemovedAvailable = [self hasWhiteSpace:down];
        if (isRemovedAvailable) {
            moveTo = down;
            return moveTo;
        }
    }
    if (position%4 == 0) {
        isRemovedAvailable = [self hasWhiteSpace:right];
        if (isRemovedAvailable) {
            moveTo = right;
            return moveTo;
        }
        return isRemovedAvailable;
    } else if (position%4 == 3) {
        isRemovedAvailable = [self hasWhiteSpace:left];
        if (isRemovedAvailable) {
            moveTo = left;
            return moveTo;
        }
    } else {
        isRemovedAvailable = [self hasWhiteSpace:right];
        if (isRemovedAvailable) {
            moveTo = right;
            return moveTo;
        }
        isRemovedAvailable = [self hasWhiteSpace:left];
        if (isRemovedAvailable) {
            moveTo = left;
            return moveTo;
        }

    }
    return moveTo;
}
//判断方块四周是否有空白位置
-(BOOL)hasWhiteSpace:(NSInteger) num{
    LatticeImageView *imageView;
    imageView = _latticeImages[[[NSString alloc]initWithFormat:@"%d", num]];
    NSInteger tag = imageView.tag;
    //15代表空白位
    if (tag == 15) {
        return YES;
    }
    return NO;
}
//判断是否拼图成功
-(BOOL)checkResult{
    BOOL success = YES;
    for (NSString *eachKey in _latticeImages) {
        LatticeImageView *imageView = _latticeImages[eachKey];
        NSInteger tag = imageView.tag;
        NSString *currentPosition = [imageView currentPosition];
//        NSLog(@"touch-%d,%@", tag, currentPosition);
        BOOL isEqual = (tag == [currentPosition integerValue]);
        success = success && isEqual;
        if (success) {
//            NSLog(@"touch-%d,%@", tag, currentPosition);
            NSLog(@"true");
        }
    }
    return success;
}
//弹出对话框
-(void)showDialog {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Congratulations" message:@"恭喜，挑战成功" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
    [alertView show];
}
//打开图片选择
- (void) openPicChoose {
    _imagePicker = [[UIImagePickerController alloc]init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    [self presentViewController:_imagePicker animated:YES completion:^{
        //
    }];
}

# pragma mark -imagePickerDelegate 选择图片代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        //
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSData *data;
        if(UIImagePNGRepresentation(image) == nil){
            data = UIImageJPEGRepresentation(image, 1.0);
        } else {
            data = UIImagePNGRepresentation(image);
        }
        self.currentBoardImage = image;
        [picker dismissViewControllerAnimated:YES completion:^{
        }];
    }
}
//初始化图片
-(void)initImage:(UIImage *)image{
    //格子面板清空
    [self removeChildViews:_latticeView];
    [self cropImages:image];
    _originView.image = image;

}
//清空view下的子view
-(void)removeChildViews:(UIView *)view{
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            [subView removeFromSuperview];
        }
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
   // picker
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
