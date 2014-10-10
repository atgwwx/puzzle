//
//  ViewController.m
//  Puzzle
//
//  Created by luntao.dlt on 14-9-15.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _boardViewController = [[BoardIViewController alloc]init];
    self.navigationItem.title = @"拼图";
    self.view.backgroundColor = [[UIColor alloc]initWithRed:153 green:153 blue:153 alpha:1];
    [self.view setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height+100)];
    [self.view addSubview:_boardViewController.view];
    
    UIBarButtonItem *rightbarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(picturePreview)];
    self.navigationItem.rightBarButtonItem = rightbarButtonItem;
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)picturePreview {
    _imageBrowserViewComtroller = [[ImageBrowserViewController alloc]init];
    [_imageBrowserViewComtroller setHomeDelegate:self];
    [self.navigationController pushViewController:_imageBrowserViewComtroller animated:YES];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) onComeback:(UIImage *) image{
    _boardViewController.currentBoardImage = image;
}

@end
