//
//  ElScratchView.m
//  Elegant
//
//  Created by mac on 2018/10/27.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ElScratchView.h"

@interface ElScratchView ()

@property (nonatomic, assign) BOOL isFinish;//已经刮完

@end

@implementation ElScratchView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.strokeLineWidth = 20;
        self.strokeLineCap = kCALineCapRound;
        
//        self.getButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.getButton setTitle:@"立即领取" forState:UIControlStateNormal];
//        self.getButton.titleLabel.font = [UIFont systemFontOfSize:14];
//        [self.getButton setTitleColor:ElRGB(77, 27, 7) forState:UIControlStateNormal];
//        [self.getButton setBackgroundColor:ElRGB(255, 210, 59)];
//        [self.getButton addTarget:self action:@selector(clickedGet) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:self.getButton];
//        ViewRadius(self.getButton, 17);
        
        self.scratchMaskView = [[UIImageView alloc] init];
        self.scratchMaskView.backgroundColor = [UIColor lightGrayColor];
        self.scratchMaskView.image = [UIImage imageNamed:@"scraping_area"];
        [self addSubview:self.scratchMaskView];
        
        self.scratchContentView = [[UILabel alloc] init];
        self.scratchContentView.backgroundColor = [UIColor whiteColor];
        self.scratchContentView.textAlignment = NSTextAlignmentCenter;
        self.scratchContentView.font = [UIFont systemFontOfSize:35];
        self.scratchContentView.numberOfLines = 0;
        self.scratchContentView.textColor = ElRGB(255, 210, 59);
//        self.scratchContentView.text = @"恭喜你刮中500万";
        self.scratchContentView.numberOfLines = 0;
        [self addSubview:self.scratchContentView];
        
        self.maskLayer = [CAShapeLayer new];
        self.maskLayer.strokeColor = UIColor.redColor.CGColor;
        self.maskLayer.lineWidth = self.strokeLineWidth;
        self.maskLayer.lineCap = self.strokeLineCap;
        self.scratchContentView.layer.mask = self.maskLayer;
        
        self.maskPath = [UIBezierPath new];
    }
    return self;
}

- (void)setStrokeLineCap:(NSString *)strokeLineCap {
    _strokeLineCap = strokeLineCap;
}

- (void)setStrokeLineWidth:(CGFloat)strokeLineWidth {
    _strokeLineWidth = strokeLineWidth;
}

- (void)setScratchName:(NSString *)scratchName {
    _scratchName = scratchName;
    self.scratchContentView.text = scratchName;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scratchContentView.frame = self.bounds;
    self.scratchMaskView.frame = self.bounds;
//    self.getButton.frame = CGRectMake(50, self.bounds.size.height - 42, self.bounds.size.width - 100, 34);
}

//领取奖品
- (void)clickedGet {
    
}

- (void)showContentView {
    self.scratchContentView.layer.mask = nil;
}

- (void)resetState {
    self.isFinish = NO;
    [self.maskPath removeAllPoints];
    self.maskLayer.path = nil;
    self.scratchContentView.layer.mask = self.maskLayer;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.scratchContentView];
    [self.maskPath moveToPoint:point];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.isFinish) {
        return;
    }
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.scratchContentView];
    [self.maskPath addLineToPoint:point];
    [self.maskPath moveToPoint:point];
    self.maskLayer.path = self.maskPath.CGPath;
    [self updateScratchScopePercent];
}

- (void)updateScratchScopePercent {
    UIImage *image = [self getImageFromContentView];
    CGFloat percent = 1 - [self getAlphaPixelPercent:image];
    percent = MAX(0, MIN(1, percent));
    if (percent >= 0.2) {
        self.isFinish = YES;
        [self showContentView];
        if (self.block) {
            self.block(self.isFinish);
        }
    }
}

//获取透明像素占总像素的百分比
- (CGFloat)getAlphaPixelPercent:(UIImage *)img {
    //计算像素总个数
    NSInteger width = (NSInteger)img.size.width;
    NSInteger height = (NSInteger)img.size.height;
    NSInteger bitmapByteCount = width * height;
    
    int bitmapInfo = kCGImageAlphaOnly;
    //得到所有像素数据
    GLubyte*pixelData = (GLubyte*)malloc(bitmapByteCount);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(pixelData, width, height, 8, width, colorSpace, bitmapInfo);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, img.CGImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //计算透明像素个数
    NSInteger alphaPixelCount = 0;
    for (int i = 0; i < width; i ++) {
        for (int j = 0; j < height; j ++) {
            if (pixelData[j * width + i] == 0) {
                alphaPixelCount += 1;
            }
        }
    }
    free(pixelData);
    return floor(alphaPixelCount) / floor(bitmapByteCount);//Float(alphaPixelCount) / Float(bitmapByteCount);
}

- (UIImage *)getImageFromContentView {
    CGSize size = self.scratchContentView.bounds.size;
    // 默认是去创建一个透明的视图
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    // 获取上下文(画板)
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 把imageView的layer映射到上下文中
    [self.scratchContentView.layer renderInContext:context];
    // 获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束图片的画板, (意味着图片在上下文中消失)
    UIGraphicsEndImageContext();
    return image;
}

@end
