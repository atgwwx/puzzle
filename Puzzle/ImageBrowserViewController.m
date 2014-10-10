//
//  ImageBrowserViewController.m
//  Puzzle
//
//  Created by luntao.dlt on 14-9-17.
//  Copyright (c) 2014年 luntao.dlt. All rights reserved.
//

#import "ImageBrowserViewController.h"

@interface ImageBrowserViewController ()

@end

@implementation ImageBrowserViewController

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
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+650)];
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [scrollView addSubview:view];
    scrollView.contentSize = view.frame.size;
    [self.view addSubview:scrollView];
    self.navigationItem.title = @"选择图片";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    NSArray * imageArray = @[@"pic1.png",@"pic2.png",@"pic3.png",@"pic4.png"];
    int count = 0;
    int width = 280;
    int margin = 10;
    for (NSString *eackKey in imageArray) {
        NSLog(eackKey);
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:eackKey]];
        imageView.frame = CGRectMake(20, count*(width+margin), width, width);
        count++;
        [view addSubview:imageView];
        [self bindEvent:imageView];
    }
    // Do any additional setup after loading the view.
}
-(void)bindEvent:(UIImageView *)imageView{
    imageView.userInteractionEnabled = true;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pictureSelect:)];
    [imageView addGestureRecognizer:singleTap];

}
//选中图片
-(void)pictureSelect:(UITapGestureRecognizer *)tapGestureRecognizer{
    NSLog(@"touch");
    UIImageView *imageView = (UIImageView *)tapGestureRecognizer.view;
    [_homeDelegate onComeback:imageView.image];
    [self.navigationController popViewControllerAnimated:true];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
