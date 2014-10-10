//
//  ViewController.h
//  Puzzle
//
//  Created by luntao.dlt on 14-9-15.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardIViewController.h"
#import "ImageBrowserViewController.h"
#import "HomeDelegate.h"

@interface ViewController : UIViewController<HomeDelegate>

@property (nonatomic, strong) BoardIViewController *boardViewController;
@property (nonatomic,strong) ImageBrowserViewController *imageBrowserViewComtroller;

@end
