//
//  BoardIViewController.h
//  Puzzle
//
//  Created by luntao.dlt on 14-9-16.
//  Copyright (c) 2014年 luntao.dlt. All rights reserved.
//

#import <UIKit/UIKit.h>
//引入ReactiveCocoa
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "LatticeModel.h"
#import "LatticeImageView.h"
@interface BoardIViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong)UILabel *timerLabel;
//拼板
@property (nonatomic ,strong)UIImageView *boardView;
@property (nonatomic, strong)NSMutableDictionary *lattices;
@property (nonatomic, strong)NSMutableDictionary *latticeImages;
//方案数据模型对象
@property (nonatomic, strong)LatticeModel *imageViewLatticeModel;
//格子拼板
@property (nonatomic ,strong)UIView *latticeView;
@property (nonatomic, strong)UIButton *shuffleButton;
@property (nonatomic, strong)UIButton *chooseImageButton;
//原图
@property (nonatomic, strong)UIImageView *originView;
//当前选中的图片
@property (nonatomic, strong)UIImage *currentBoardImage;
@property (nonatomic, strong)UIImagePickerController *imagePicker;

-(void)cropImages:(UIImage *)image;
-(void)drawLattices;
-(void)disorder;
-(void)latticeTouch:(id)sender;
-(void)initImage:(UIImage *)image;
@end
