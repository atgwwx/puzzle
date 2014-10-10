//
//  HomeDelegate.h
//  Puzzle
//
//  Created by luntao.dlt on 14-9-21.
//  Copyright (c) 2014年 luntao.dlt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HomeDelegate <NSObject>
@required
-(void) onComeback:(UIImage *) image;
@end
