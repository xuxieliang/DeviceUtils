//
//  XLMenuItem.m
//  YicaiVIP_APP
//
//  Created by kevin on 27/8/2020.
//  Copyright © 2020 www.diyicaijing.com. All rights reserved.
//

#import "XLMenuItem.h"


@interface XLMenuItem () {
    CGFloat _selectedRed, _selectedGreen, _selectedBlue, _selectedAlpha;
    CGFloat _normalRed, _normalGreen, _normalBlue, _normalAlpha;
    CGFloat _selectedBgRed, _selectedBgGreen, _selectedBgBlue, _selectedBgAlpha;
    CGFloat _normalBgRed, _normalBgGreen, _normalBgBlue, _normalBgAlpha;
    int     _sign;
    CGFloat _gap;
    CGFloat _step;
    __weak CADisplayLink *_link;
}

//@property (nonatomic, strong) UIView *gradientView;

@end

@implementation XLMenuItem


#pragma mark - Public Methods
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.normalColor   = [UIColor blackColor];
        self.selectedColor = [UIColor blackColor];
        self.normalBgColor   = [UIColor clearColor];
        self.selectedBgColor = [UIColor clearColor];
        self.normalSize    = 15;
        self.selectedSize  = 18;
        self.radius = 0;
        self.numberOfLines = 0;
//        if (@available(iOS 12.0, *)) {
//            BOOL isDark = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
////            self.gradientView.hidden = !isDark;
//        } else {
//            // Fallback on earlier versions
//        }
//        self.gradientView.hidden = NO;
        
        [self setupGestureRecognizer];
    }
    return self;
}

- (CGFloat)speedFactor {
    if (_speedFactor <= 0) {
        _speedFactor = 15.0;
    }
    return _speedFactor;
}

- (void)setupGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchUpInside:)];
    [self addGestureRecognizer:tap];
}

- (void)setSelected:(BOOL)selected withAnimation:(BOOL)animation {
    _selected = selected;
    if (!animation) {
        self.rate = selected ? 1.0 : 0.0;
        return;
    }
    _sign = (selected == YES) ? 1 : -1;
    _gap  = (selected == YES) ? (1.0 - self.rate) : (self.rate - 0.0);
    _step = _gap / self.speedFactor;
    if (_link) {
        [_link invalidate];
    }
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(rateChange)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _link = link;
}

- (void)rateChange {
    if (_gap > 0.000001) {
        _gap -= _step;
        if (_gap < 0.0) {
            self.rate = (int)(self.rate + _sign * _step + 0.5);
            return;
        }
        self.rate += _sign * _step;
    } else {
        self.rate = (int)(self.rate + 0.5);
        [_link invalidate];
        _link = nil;
    }
}

// 设置rate,并刷新标题状态
- (void)setRate:(CGFloat)rate {
    if (rate < 0.0 || rate > 1.0) { return; }
    _rate = rate;
    CGFloat r = _normalRed + (_selectedRed - _normalRed) * rate;
    CGFloat g = _normalGreen + (_selectedGreen - _normalGreen) * rate;
    CGFloat b = _normalBlue + (_selectedBlue - _normalBlue) * rate;
    CGFloat a = _normalAlpha + (_selectedAlpha - _normalAlpha) * rate;
    self.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    
    CGFloat bgR = _normalBgRed + (_selectedBgRed - _normalBgRed) * rate;
    CGFloat bgG = _normalBgGreen + (_selectedBgGreen - _normalBgGreen) * rate;
    CGFloat bgB = _normalBgBlue + (_selectedBgBlue - _normalBgBlue) * rate;
    CGFloat bgA = _normalBgAlpha + (_selectedBgAlpha - _normalBgAlpha) * rate;
    self.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:bgA];
    
    CGFloat minScale = self.normalSize / self.selectedSize;
    CGFloat trueScale = minScale + (1 - minScale) * rate;
    self.transform = CGAffineTransformMakeScale(trueScale, trueScale);
    if (rate == 0) {
        /// 未选中状态
        self.font = self.normalFont;
    } else if (rate == 1) {
        /// 选中状态
        self.font = self.selectedFont;
    }
    
    // kevin为了让动画不那么直接生硬，在0.9的时候就变换了字体
    if (rate > 0.7) {
        self.font = self.selectedFont;
    } else {
        self.font = self.normalFont;
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    [selectedColor getRed:&_selectedRed green:&_selectedGreen blue:&_selectedBlue alpha:&_selectedAlpha];
}

- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    [normalColor getRed:&_normalRed green:&_normalGreen blue:&_normalBlue alpha:&_normalAlpha];
}

- (void)setSelectedBgColor:(UIColor *)selectedBgColor {
    _selectedBgColor = selectedBgColor;
    [selectedBgColor getRed:&_selectedBgRed green:&_selectedBgGreen blue:&_selectedBgBlue alpha:&_selectedBgAlpha];
}

- (void)setNormalBgColor:(UIColor *)normalBgColor {
    _normalBgColor = normalBgColor;
    [normalBgColor getRed:&_normalBgRed green:&_normalBgGreen blue:&_normalBgBlue alpha:&_normalBgAlpha];
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    if (_radius > 0) {
        self.layer.cornerRadius = _radius;
        [self.layer setMasksToBounds:YES];
    }
}

- (void)touchUpInside:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didPressedMenuItem:)]) {
        [self.delegate didPressedMenuItem:self];
    }
}

/// 控制底部对齐
- (void)drawTextInRect:(CGRect)rect {
    if (self.verticalAlignment == XLMenuItemVerticalAlignmentbottom) {
        CGFloat minScale = self.normalSize / self.selectedSize;
        CGFloat trueScale = minScale + (1 - minScale) * self.rate;
        CGRect actualRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
        CGFloat trueHeight = actualRect.size.height * trueScale;
        
        [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 0, trueHeight - actualRect.size.height, 0))];
    } else {
        [super drawTextInRect:rect];
    }
}
//
//- (UIView *)gradientView {
//    if (!_gradientView) {
//        _gradientView = [[UIView alloc] initWithFrame:self.bounds];
//        _gradientView.backgroundColor = [UIColor blackColor];
//        CAGradientLayer *gradLayer = [CAGradientLayer layer];
//        NSArray *colors = [NSArray arrayWithObjects:
//                           (id)kColorWithRGBA(0x8a8a8a, 1).CGColor,
//                           (id)kColorWithRGBA(0x525252, 1).CGColor,
//                           nil];
//        [gradLayer setColors:colors];
//
//        [gradLayer setStartPoint:CGPointMake(0.0f, 0.0f)];
//        [gradLayer setEndPoint:CGPointMake(1.0f, 1.0f)];
//        [gradLayer setFrame:self.bounds];
//        [_gradientView.layer setMask:gradLayer];
//        [self addSubview:_gradientView];
//    }
//    return _gradientView;
//}

@end
