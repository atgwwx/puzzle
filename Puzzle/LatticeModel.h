//
//  LatticeModel.h
//  Puzzle
//
//  Created by luntao.dlt on 14-9-20.
//  Copyright (c) 2014年 luntao.dlt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LatticeModel : NSObject
@property (nonatomic, strong)UIImageView *latticeImageView;
@property CGPoint point; //位置信息
@property NSString *sequenceId; //序列Id
@end
