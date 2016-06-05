//
//  MRFoldImageView.m
//  MRFoldImageExample
//
//  Created by SinObjectC on 16/6/5.
//  Copyright © 2016年 SinObjectC. All rights reserved.
//

#import "MRFoldImageView.h"


@interface MRFoldImageView ()

/** 上半图 */
@property(nonatomic, weak)UIImageView *topImageView;

/** 下半图 */
@property(nonatomic, weak)UIImageView *bottomImageView;

/** 手势拖动视图 */
@property(nonatomic, weak)UIView *dragView;

/** 渐变图层 */
@property(nonatomic, weak)CAGradientLayer *gradientLayer;

@end


@implementation MRFoldImageView

/**
 *	@brief	代码初始化
 */
- (instancetype)initWithFrame:(CGRect)frame

{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // 初始化设置
        [self setUp];
    }
    return self;
}

/**
 *	@brief	xib初始化
 */
- (void)awakeFromNib {

    // 初始化设置
    [self setUp];
}


/**
 *	@brief	初始化设置
 */
- (void)setUp {
    
    NSLog(@"%s", __func__);
    
    self.userInteractionEnabled = YES;
    
    // 添加图片
    [self addImageView];
    
    // 添加拖动视图
    [self addDragView];
    
    // 添加渐变图层
    [self addGradientLayer];
    
    self.image = nil;
}


/**
 *	@brief	添加上下图片
 */
- (void)addImageView {
    
    // 当前宽高
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    // 创建上下图片控件
    UIImageView *top = [[UIImageView alloc] init];
    top.frame = CGRectMake(0, height * 0.25, width, height * 0.5);
    self.topImageView = top;
    
    UIImageView *bottom = [[UIImageView alloc] init];
    bottom.frame = CGRectMake(0, height * 0.25, width, height * 0.5);
    self.bottomImageView = bottom;
    
    // 给上下图片设置显示区域和锚点
    self.topImageView.layer.contentsRect = CGRectMake(0, 0, 1, 0.5);
    self.topImageView.layer.anchorPoint = CGPointMake(0.5, 1);
    
    self.bottomImageView.layer.contentsRect = CGRectMake(0, 0.5, 1, 0.5);
    self.bottomImageView.layer.anchorPoint = CGPointMake(0.5, 0);
    
    // 设置上下图片
    self.topImageView.image = self.image;
    
    self.bottomImageView.image = self.image;
    
    [self addSubview:self.topImageView];
    [self addSubview:self.bottomImageView];
}


/**
 *	@brief	添加拖动视图
 */
- (void)addDragView {
    
    UIView *dragView = [[UIView alloc] init];
    
    dragView.frame = self.bounds;
    
    // 设置为透明色
    dragView.backgroundColor = [UIColor clearColor];
    
    self.dragView = dragView;
    
    [self addSubview:dragView];
    
    // 添加拖动手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    
    [self.dragView addGestureRecognizer:panGesture];
}


/**
 *	@brief	添加渐变图层
 */
- (void)addGradientLayer {
    
    CAGradientLayer *gradientL = [CAGradientLayer layer];
    
    // 注意渐变图层需要设置尺寸
    gradientL.frame = self.bottomImageView.bounds;
    
    gradientL.opacity = 0;  // 不透明度为0, 透明
    
    // 设置渐变颜色
    gradientL.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor ];
    
    // 设置渐变起点(默认为(0.5, 0))
    gradientL.startPoint = CGPointMake(0.5, 0);
    
    self.gradientLayer = gradientL;
    
    // 将渐变图层添加到bottomImageView
    [self.bottomImageView.layer addSublayer:gradientL];
    
}


/**
 *	@brief	拖动手势事件
 */
- (void)pan:(UIPanGestureRecognizer *)pan {
    
    // 拖动视图高度
    CGFloat drawHeight = self.dragView.frame.size.height;

    // 获取拖动偏移量
    CGPoint transP = [pan translationInView:self.dragView];
    
    // 计算旋转角度, 往下为逆时针
    CGFloat angle = -transP.y / drawHeight * M_PI;
    
    // 创建形变
    CATransform3D transform = CATransform3DIdentity;
    
    // 设置形变参数
    
    // 增加立体感, 近大远小, d: 距离图层的距离
    transform.m34 = -1 / 500.0;
    
    // 绕着x轴方向旋转
    transform = CATransform3DRotate(transform, angle, 1, 0, 0);
    
    self.topImageView.layer.transform = transform;
    
    // 设置阴影效果
    self.gradientLayer.opacity = transP.y * 1 / drawHeight;
    
    // 反弹
    if(pan.state == UIGestureRecognizerStateEnded) {
        
        // 弹簧效果动画, usingSpringWithDamping系数越小, 弹性越大
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
           
            // 还原形变
            self.topImageView.layer.transform = CATransform3DIdentity;
            
        } completion:nil];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
