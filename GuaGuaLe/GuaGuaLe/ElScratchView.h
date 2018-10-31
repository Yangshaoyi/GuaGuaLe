//
//  ElScratchView.h
//  Elegant
//
//  Created by mac on 2018/10/27.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ScratchFinishBlock)(BOOL isFinish);

@interface ElScratchView : UIView

@property (nonatomic, strong) UILabel *scratchContentView;

@property (nonatomic, strong) UIImageView *scratchMaskView;

@property (nonatomic, strong) NSString *strokeLineCap;

@property (nonatomic, assign) CGFloat strokeLineWidth;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, strong) UIBezierPath *maskPath;

@property (nonatomic, copy) ScratchFinishBlock block;

@property (nonatomic, strong) UIButton *getButton;

@property (nonatomic, strong) NSString *scratchName;

@end
