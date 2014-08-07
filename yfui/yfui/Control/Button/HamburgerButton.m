//
//  HamburgerButton.m
//  yfui
//
//  Created by yf6190 on 8/7/14.
//  Copyright (c) 2014 yfstudio. All rights reserved.
//

#import "HamburgerButton.h"

@implementation CALayer(ocb_animation)
- (void)ocb_applyAnimation:(CABasicAnimation *)animation
{
    CABasicAnimation *animation1 = [animation copy];
    if (![animation1.fromValue intValue]) {
        animation1.fromValue = [[self presentationLayer] valueForKeyPath:animation1.keyPath];
    }
    [self addAnimation:animation1 forKey:animation1.keyPath];
    [self setValue:animation1.toValue forKeyPath:animation1.keyPath];
}
@end

@interface HamburgerButton() {
    CGFloat _hamburgerStrokeStart;
    CGFloat _hamburgerStrokeEnd;
    CGFloat _menuStrokeStart;
    CGFloat _menuStrokeEnd;
}

@property (nonatomic, strong) CAShapeLayer *top;
@property (nonatomic, strong) CAShapeLayer *middle;
@property (nonatomic, strong) CAShapeLayer *bottom;

@end

@implementation HamburgerButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];

    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    _menuStrokeStart = 0.325;
    _menuStrokeEnd = 0.9;
    _hamburgerStrokeStart = 0.028;
    _hamburgerStrokeEnd = 0.111;
    _showMenu = NO;
    self.top = [self shapeLayerWithPath:[self shortStroke]];
    self.bottom = [self shapeLayerWithPath:[self shortStroke]];
    self.middle = [self shapeLayerWithPath:[self outline]];
    [self.layer addSublayer:self.top];
    [self.layer addSublayer:self.bottom];
    [self.layer addSublayer:self.middle];
    
    self.top.anchorPoint = CGPointMake(28.0 / 30.0, 0.5);
    self.top.position = CGPointMake(40, 18);
    
    self.middle.position = CGPointMake(27, 27);
    self.middle.strokeStart = _hamburgerStrokeStart;
    self.middle.strokeEnd = _hamburgerStrokeEnd;
    
    self.bottom.anchorPoint = CGPointMake(28.0 / 30.0, 0.5);
    self.bottom.position = CGPointMake(40, 36);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/
- (void)drawRect:(CGRect)rect
{
    // Drawing code
//    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(delayDispose) userInfo:nil repeats:YES];
}

- (void)delayDispose
{
    self.showMenu = !self.showMenu;
}

- (CAShapeLayer *)shapeLayerWithPath:(CGPathRef)path
{
    CGRect bound = CGPathGetBoundingBox(CGPathCreateCopyByStrokingPath(path, nil, 4, kCGLineCapRound, kCGLineJoinMiter, 4));
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.bounds = bound;
    layer.fillColor = nil;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.lineWidth = 4;
    layer.miterLimit = 4;
    layer.lineCap = kCALineCapRound;
    layer.masksToBounds = true;
    layer.path = path;
//    layer.actions = @{@"strokeStart":[NSNull null], @"strokeEnd":[NSNull null], @"transform":[NSNull null]};
    return layer;
}

- (CGPathRef)shortStroke
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 2.f, 2.f);
    CGPathAddLineToPoint(path, nil, 28.f, 2.f);
    return path;
}

- (CGPathRef)outline
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 10, 27);
    CGPathAddCurveToPoint(path, nil, 12.00, 27.00, 28.02, 27.00, 40, 27);
    CGPathAddCurveToPoint(path, nil, 55.92, 27.00, 50.47,  2.00, 27,  2);
    CGPathAddCurveToPoint(path, nil, 13.16,  2.00,  2.00, 13.16,  2, 27);
    CGPathAddCurveToPoint(path, nil,  2.00, 40.84, 13.16, 52.00, 27, 52);
    CGPathAddCurveToPoint(path, nil, 40.84, 52.00, 52.00, 40.84, 52, 27);
    CGPathAddCurveToPoint(path, nil, 52.00, 13.16, 42.39,  2.00, 27,  2);
    CGPathAddCurveToPoint(path, nil, 13.16,  2.00,  2.00, 13.16,  2, 27);
    return path;
}

- (void)setShowMenu:(BOOL)showMenu
{
    if (showMenu != _showMenu) {
        _showMenu = showMenu;
        [self doAnimation];
    }
}

- (void)doAnimation
{
    CABasicAnimation *strokeStart = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    CABasicAnimation *strokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];

    if (self.showMenu) {
        strokeStart.toValue = @(_menuStrokeStart);
        strokeStart.duration = 0.5;
        strokeStart.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25f :-0.4f :0.5f :1.f];

        strokeEnd.toValue = @(_menuStrokeEnd);
        strokeEnd.duration = 0.6;
        strokeEnd.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25f :-0.4f :0.5f :1.f];
    } else {
        strokeStart.toValue = @(_hamburgerStrokeStart);
        strokeStart.duration = 0.5;
        strokeStart.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25f :0 :0.5f :1.2f];
        strokeStart.beginTime = CACurrentMediaTime() + 0.1;
        strokeStart.fillMode = kCAFillModeBackwards;

        strokeEnd.toValue = @(_hamburgerStrokeEnd);
        strokeEnd.duration = 0.6;
        strokeEnd.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25f :0.3f :0.5f :0.9f];
    }
    [self.middle ocb_applyAnimation:strokeStart];
    [self.middle ocb_applyAnimation:strokeEnd];

    CABasicAnimation *topTransform = [CABasicAnimation animationWithKeyPath:@"transform"];
    topTransform.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.5f :-0.8f :0.5f :1.85f];
    topTransform.duration = 0.4;
    topTransform.fillMode = kCAFillModeBackwards;
    CABasicAnimation *bottomTransform = [topTransform copy];
    if (self.showMenu) {
        CATransform3D transform3D = CATransform3DMakeTranslation(-4, 0, 0);
        topTransform.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(transform3D, -0.7853975, 0, 0, 1)];
        topTransform.beginTime = CACurrentMediaTime() + 0.25;
        bottomTransform.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(transform3D, 0.7853975, 0, 0, 1)];
        bottomTransform.beginTime = CACurrentMediaTime() + 0.25;
    } else {
        topTransform.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        topTransform.beginTime = CACurrentMediaTime() + 0.05;
        bottomTransform.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        bottomTransform.beginTime = CACurrentMediaTime() + 0.05;
    }
    [self.top ocb_applyAnimation:topTransform];
    [self.bottom ocb_applyAnimation:bottomTransform];
}

@end
