//
//  XLMenuView.m
//  YicaiVIP_APP
//
//  Created by kevin on 27/8/2020.
//  Copyright © 2020 www.diyicaijing.com. All rights reserved.
//

#import "XLMenuView.h"
#define XLMENUITEM_TAG_OFFSET 6250
#define XLBADGEVIEW_TAG_OFFSET 1212
#define XLDEFAULT_VAULE(value, defaultValue) (value != XLUNDEFINED_VALUE ? value : defaultValue)

@interface XLMenuView () 
@property (nonatomic, weak) XLMenuItem *selItem;
@property (nonatomic, weak) UIButton *selItemView;
@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, readonly) NSInteger titlesCount;
//@property (nonatomic, assign) NSInteger currentSelectIndex;
@end

@implementation XLMenuView

@synthesize progressHeight = _progressHeight;
@synthesize progressViewCornerRadius = _progressViewCornerRadius;

#pragma mark - Setter

- (void)setLayoutMode:(XLMenuViewLayoutMode)layoutMode {
    _layoutMode = layoutMode;
    if (!self.superview) { return; }
    [self reload];
}

- (void)setFrame:(CGRect)frame {
    // Adapt iOS 11 if is a titleView
    if (@available(iOS 11.0, *)) {
        if (self.showOnNavigationBar) { frame.origin.x = 0; }
    }
    
    [super setFrame:frame];
    
    if (!self.scrollView) { return; }
    
    CGFloat leftMargin = self.contentMargin + self.leftView.frame.size.width;
    CGFloat rightMargin = self.contentMargin + self.rightView.frame.size.width;
    CGFloat contentWidth = self.scrollView.frame.size.width + leftMargin + rightMargin;
    CGFloat startX = self.leftView ? self.leftView.frame.origin.x : self.scrollView.frame.origin.x - self.contentMargin;
    
    // Make the contentView center, because system will change menuView's frame if it's a titleView.
    if (startX + contentWidth / 2 != self.bounds.size.width / 2) {
        
        CGFloat xOffset = (self.bounds.size.width - contentWidth) / 2;
        self.leftView.frame = ({
            CGRect frame = self.leftView.frame;
            frame.origin.x = xOffset;
            frame;
        });
        
        self.scrollView.frame = ({
            CGRect frame = self.scrollView.frame;
            frame.origin.x = self.leftView ? CGRectGetMaxX(self.leftView.frame) + self.contentMargin : xOffset;
            frame;
        });
        
        self.rightView.frame = ({
            CGRect frame = self.rightView.frame;
            frame.origin.x = CGRectGetMaxX(self.scrollView.frame) + self.contentMargin;
            frame;
        });
    }
}

- (void)setProgressViewCornerRadius:(CGFloat)progressViewCornerRadius {
    _progressViewCornerRadius = progressViewCornerRadius;
    if (self.progressView) {
        self.progressView.cornerRadius = _progressViewCornerRadius;
    }
}

- (void)setSpeedFactor:(CGFloat)speedFactor {
    _speedFactor = speedFactor;
    if (self.progressView) {
        self.progressView.speedFactor = _speedFactor;
    }
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[XLMenuItem class]]) {
            ((XLMenuItem *)obj).speedFactor = self->_speedFactor;
        }
    }];
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[XLMenuItem class]]) {
            ((XLMenuItem *)obj).radius = self->_radius;
        }
    }];
}

- (void)setProgressWidths:(NSArray *)progressWidths {
    _progressWidths = progressWidths;
    
    if (!self.progressView.superview) { return; }
    
    [self resetFramesFromIndex:0];
}

- (void)setLeftView:(UIView *)leftView {
    if (self.leftView) {
        [self.leftView removeFromSuperview];
        _leftView = nil;
    }
    if (leftView) {
        [self addSubview:leftView];
        _leftView = leftView;
    }
    [self resetFrames];
}

- (void)setRightView:(UIView *)rightView {
    if (self.rightView) {
        [self.rightView removeFromSuperview];
        _rightView = nil;
    }
    if (rightView) {
        [self addSubview:rightView];
        _rightView = rightView;
    }
    [self resetFrames];
}

- (void)setContentMargin:(CGFloat)contentMargin {
    _contentMargin = contentMargin;
    if (self.scrollView) {
        [self resetFrames];
    }
}

#pragma mark - Getter

- (CGFloat)progressHeight {
    switch (self.style) {
        case XLMenuViewStyleLine:
        case XLMenuViewStyleTriangle:
            return XLDEFAULT_VAULE(_progressHeight, 2);
        case XLMenuViewStyleFlood:
        case XLMenuViewStyleSegmented:
        case XLMenuViewStyleFloodHollow:
            return XLDEFAULT_VAULE(_progressHeight, ceil(self.frame.size.height * 0.8));
        default:
            return _progressHeight;
    }
}

- (CGFloat)progressViewCornerRadius {
    return XLDEFAULT_VAULE(_progressViewCornerRadius, self.progressHeight / 2.0);
}

- (UIColor *)lineColor {
    if (!_lineColor) {
        _lineColor = [self colorForState:XLMenuItemStateSelected atIndex:0];
    }
    return _lineColor;
}

- (NSMutableArray *)frames {
    if (_frames == nil) {
        _frames = [NSMutableArray array];
    }
    return _frames;
}

- (UIColor *)colorForState:(XLMenuItemState)state atIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(menuView:titleColorForState:atIndex:)]) {
        return [self.delegate menuView:self titleColorForState:state atIndex:index];
    }
    return [UIColor blackColor];
}

- (UIColor *)bgColorForState:(XLMenuItemState)state atIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(menuView:bgColorForState:atIndex:)]) {
        return [self.delegate menuView:self bgColorForState:state atIndex:index];
    }
    return [UIColor clearColor];
}

- (nullable UIImage *)bgImageForState:(XLMenuItemState)state atIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(menuView:bgImageForState:atIndex:)]) {
        return [self.delegate menuView:self bgImageForState:state atIndex:index];
    }
    return nil;
}


- (CGFloat)sizeForState:(XLMenuItemState)state atIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(menuView:titleSizeForState:atIndex:)]) {
        return [self.delegate menuView:self titleSizeForState:state atIndex:index];
    }
    return 15.0;
}

- (UIFont *)fontForState:(XLMenuItemState)state atIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(menuView:titleFontForState:atIndex:)]) {
        return [self.delegate menuView:self titleFontForState:state atIndex:index];
    }
    return [UIFont systemFontOfSize:15.0];
}

- (UIView *)badgeViewAtIndex:(NSInteger)index {
    if (![self.dataSource respondsToSelector:@selector(menuView:badgeViewAtIndex:)]) {
        return nil;
    }
    UIView *badgeView = [self.dataSource menuView:self badgeViewAtIndex:index];
    if (!badgeView) {
        return nil;
    }
    badgeView.tag = index + XLBADGEVIEW_TAG_OFFSET;
    
    return badgeView;
}

#pragma mark - Public Methods

- (XLMenuItem *)itemAtIndex:(NSInteger)index {
    return (XLMenuItem *)[self viewWithTag:(index + XLMENUITEM_TAG_OFFSET)];
}

- (void)setProgressViewIsNaughty:(BOOL)progressViewIsNaughty {
    _progressViewIsNaughty = progressViewIsNaughty;
    if (self.progressView) {
        self.progressView.naughty = progressViewIsNaughty;
    }
}

- (void)reload {
    [self.frames removeAllObjects];
    [self.progressView removeFromSuperview];
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self addItems];
    [self makeStyle];
    [self addBadgeViews];
}

- (void)slideMenuAtProgress:(CGFloat)progress {
    if (self.progressView) {
        self.progressView.progress = progress;
    }
    NSInteger tag = (NSInteger)progress + XLMENUITEM_TAG_OFFSET;
    CGFloat rate = progress - tag + XLMENUITEM_TAG_OFFSET;
    XLMenuItem *currentItem = (XLMenuItem *)[self viewWithTag:tag];
    XLMenuItem *nextItem = (XLMenuItem *)[self viewWithTag:tag+1];
    
    UIButton *currentItemView = [self viewWithTag:tag - 1000];
    if (rate == 0.0) {
        nextItem.rate = rate;
        [self.selItem setSelected:NO withAnimation:NO];
        self.selItem = currentItem;
        [self.selItem setSelected:YES withAnimation:NO];
        
        self.selItemView.selected = NO;
        self.selItemView = currentItemView;
        self.selItemView.selected = YES;
        
        [self refreshContenOffset];
        
        return;
    }
    currentItem.rate = 1-rate;
    nextItem.rate = rate;
}

- (void)selectItemAtIndex:(NSInteger)index {
    NSInteger tag = index + XLMENUITEM_TAG_OFFSET;
    NSInteger currentIndex = self.selItem.tag - XLMENUITEM_TAG_OFFSET;
    self.selectIndex = index;
    if (index == currentIndex || !self.selItem) { return; }
    XLMenuItem *item = (XLMenuItem *)[self viewWithTag:tag];
    UIButton *itemView = [self viewWithTag:tag - 1000];
    [self.selItem setSelected:NO withAnimation:NO];
    self.selItem = item;
    [self.selItem setSelected:YES withAnimation:NO];
    
    self.selItemView.selected = NO;
    self.selItemView = itemView;
    self.selItemView.selected = YES;
    
    [self.progressView setProgressWithOutAnimate:index];
    if ([self.delegate respondsToSelector:@selector(menuView:didSelectedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSelectedIndex:index currentIndex:currentIndex];
    }
    [self refreshContenOffset];
}

- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index andWidth:(BOOL)update {
    if (index >= self.titlesCount || index < 0) { return; }
    
    XLMenuItem *item = (XLMenuItem *)[self viewWithTag:(XLMENUITEM_TAG_OFFSET + index)];
    item.text = title;
    if (!update) { return; }
    [self resetFrames];
}

- (void)updateAttributeTitle:(NSAttributedString *)title atIndex:(NSInteger)index andWidth:(BOOL)update {
    if (index >= self.titlesCount || index < 0) { return; }
    
    XLMenuItem *item = (XLMenuItem *)[self viewWithTag:(XLMENUITEM_TAG_OFFSET + index)];
    item.attributedText = title;
    if (!update) { return; }
    [self resetFrames];
}

- (void)updateBadgeViewAtIndex:(NSInteger)index {
    UIView *oldBadgeView = [self.scrollView viewWithTag:XLBADGEVIEW_TAG_OFFSET + index];
    if (oldBadgeView) {
        [oldBadgeView removeFromSuperview];
    }
    
    [self addBadgeViewAtIndex:index];
    [self resetBadgeFrame:index];
}

// 让选中的item位于中间
- (void)refreshContenOffset {
    CGRect frame = self.selItem.frame;
    CGFloat itemX = frame.origin.x;
    CGFloat width = self.scrollView.frame.size.width;
    CGSize contentSize = self.scrollView.contentSize;
    if (itemX > width/2) {
        CGFloat targetX;
        if ((contentSize.width-itemX) <= width/2) {
            targetX = contentSize.width - width;
        } else {
            targetX = frame.origin.x - width/2 + frame.size.width/2;
        }
        // 应该有更好的解决方法
        if (targetX + width > contentSize.width) {
            targetX = contentSize.width - width;
        }
        [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
}

#pragma mark - Data source
- (NSInteger)titlesCount {
    return [self.dataSource numbersOfTitlesInMenuView:self];
}

#pragma mark - Private Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.progressViewCornerRadius = XLUNDEFINED_VALUE;
        self.progressHeight = XLUNDEFINED_VALUE;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (self.scrollView) { return; }
    
    [self addScrollView];
    [self addItems];
    [self makeStyle];
    [self addBadgeViews];
    [self resetSelectionIfNeeded];
}

- (void)resetSelectionIfNeeded {
    if (self.selectIndex == 0) { return; }
    [self selectItemAtIndex:self.selectIndex];
}

- (void)resetFrames {
    CGRect frame = self.bounds;
    if (self.rightView) {
        CGRect rightFrame = self.rightView.frame;
        rightFrame.origin.x = frame.size.width - rightFrame.size.width;
        self.rightView.frame = rightFrame;
        frame.size.width -= rightFrame.size.width;
    }
    
    if (self.leftView) {
        CGRect leftFrame = self.leftView.frame;
        leftFrame.origin.x = 0;
        self.leftView.frame = leftFrame;
        frame.origin.x += leftFrame.size.width;
        frame.size.width -= leftFrame.size.width;
    }
    
    frame.origin.x += self.contentMargin;
    frame.size.width -= self.contentMargin * 2;
    self.scrollView.frame = frame;
    [self resetFramesFromIndex:0];
}

- (void)resetFramesFromIndex:(NSInteger)index {
    [self.frames removeAllObjects];
    [self calculateItemFrames];
    for (NSInteger i = index; i < self.titlesCount; i++) {
        [self resetItemFrame:i];
        [self resetBadgeFrame:i];
    }
    if (!self.progressView.superview) { return; }
    
    self.progressView.frame = [self calculateProgressViewFrame];
    self.progressView.cornerRadius = self.progressViewCornerRadius;
    self.progressView.itemFrames = [self convertProgressWidthsToFrames];
    [self.progressView setNeedsDisplay];
}

- (CGRect)calculateProgressViewFrame {
    switch (self.style) {
        case XLMenuViewStyleDefault: {
            return CGRectZero;
        }
        case XLMenuViewStyleLine:
        case XLMenuViewStyleTriangle: {
            return CGRectMake(0, self.frame.size.height - self.progressHeight - self.progressViewBottomSpace, self.scrollView.contentSize.width, self.progressHeight);
        }
        case XLMenuViewStyleFloodHollow:
        case XLMenuViewStyleSegmented:
        case XLMenuViewStyleFlood: {
            return CGRectMake(0, (self.frame.size.height - self.progressHeight) / 2, self.scrollView.contentSize.width, self.progressHeight);
        }
    }
}

- (void)resetItemFrame:(NSInteger)index {
    XLMenuItem *item = (XLMenuItem *)[self viewWithTag:(XLMENUITEM_TAG_OFFSET + index)];
    CGRect frame = [self.frames[index] CGRectValue];
    item.frame = frame;
    
    UIView *itemView = [self viewWithTag:item.tag - 1000];
    itemView.frame = frame;
    
    if ([self.delegate respondsToSelector:@selector(menuView:didLayoutItemFrame:atIndex:)]) {
        [self.delegate menuView:self didLayoutItemFrame:item atIndex:index];
    }
}

- (void)resetBadgeFrame:(NSInteger)index {
    CGRect frame = [self.frames[index] CGRectValue];
    UIView *badgeView = [self.scrollView viewWithTag:(XLBADGEVIEW_TAG_OFFSET + index)];
    if (badgeView) {
        CGRect badgeFrame = [self badgeViewAtIndex:index].frame;
        badgeFrame.origin.x += frame.origin.x;
        badgeView.frame = badgeFrame;
    }
}

- (NSArray *)convertProgressWidthsToFrames {
    if (!self.frames.count) { NSAssert(NO, @"BUUUUUUUG...SHOULDN'T COME HERE!!"); }
    
    if (self.progressWidths.count < self.titlesCount) return self.frames;
    
    NSMutableArray *progressFrames = [NSMutableArray array];
    NSInteger count = (self.frames.count <= self.progressWidths.count) ? self.frames.count : self.progressWidths.count;
    for (int i = 0; i < count; i++) {
        CGRect itemFrame = [self.frames[i] CGRectValue];
        CGFloat progressWidth = [self.progressWidths[i] floatValue];
        CGFloat x = itemFrame.origin.x + (itemFrame.size.width - progressWidth) / 2;
        CGRect progressFrame = CGRectMake(x, itemFrame.origin.y, progressWidth, 0);
        [progressFrames addObject:[NSValue valueWithCGRect:progressFrame]];
    }
    return progressFrames.copy;
}

- (void)addBadgeViews {
    for (int i = 0; i < self.titlesCount; i++) {
        [self addBadgeViewAtIndex:i];
    }
}

- (void)addBadgeViewAtIndex:(NSInteger)index {
    UIView *badgeView = [self badgeViewAtIndex:index];
    if (badgeView) {
        [self.scrollView addSubview:badgeView];
    }
}

- (void)makeStyle {
    CGRect frame = [self calculateProgressViewFrame];
    if (CGRectEqualToRect(frame, CGRectZero)) {
        return;
    }
    [self addProgressViewWithFrame:frame
                        isTriangle:(self.style == XLMenuViewStyleTriangle)
                         hasBorder:(self.style == XLMenuViewStyleSegmented)
                            hollow:(self.style == XLMenuViewStyleFloodHollow)
                      cornerRadius:self.progressViewCornerRadius];
}

- (void)deselectedItemsIfNeeded {
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[XLMenuItem class]] || obj == self.selItem) { return; }
        [(XLMenuItem *)obj setSelected:NO withAnimation:NO];
        UIButton *view = [self viewWithTag:obj.tag - 1000];
        view.selected = NO;
    }];
}

- (void)addScrollView {
    CGFloat width = self.frame.size.width - self.contentMargin * 2;
    CGFloat height = self.frame.size.height;
    CGRect frame = CGRectMake(self.contentMargin, 0, width, height);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator   = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.scrollsToTop = NO;
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)addItems {
    [self calculateItemFrames];
        
    for (int i = 0; i < self.titlesCount; i++) {
        CGRect frame = [self.frames[i] CGRectValue];
        UIButton *itemView = [UIButton buttonWithType:(UIButtonTypeCustom)];
        itemView.frame = frame;
        XLMenuItem *item = [[XLMenuItem alloc] initWithFrame:frame];
        item.tag = (i + XLMENUITEM_TAG_OFFSET);
        
        itemView.tag =  item.tag - 1000;
        
        item.delegate = self;
        item.text = [self.dataSource menuView:self titleAtIndex:i];
        item.textAlignment = NSTextAlignmentCenter;
        item.userInteractionEnabled = YES;
        item.backgroundColor = [UIColor clearColor];
        item.verticalAlignment = self.verticalAlignment;
        item.normalSize      = [self sizeForState:XLMenuItemStateNormal atIndex:i];
        item.selectedSize    = [self sizeForState:XLMenuItemStateSelected atIndex:i];
        item.normalColor     = [self colorForState:XLMenuItemStateNormal atIndex:i];
        item.selectedColor   = [self colorForState:XLMenuItemStateSelected atIndex:i];
        item.normalBgColor   = [self bgColorForState:XLMenuItemStateNormal atIndex:i];
        item.selectedBgColor = [self bgColorForState:XLMenuItemStateSelected atIndex:i];
        item.radius          = self.radius;
        item.speedFactor     = self.speedFactor;
        item.normalFont      = [self fontForState:(XLMenuItemStateNormal) atIndex:i];
        item.selectedFont    = [self fontForState:(XLMenuItemStateSelected) atIndex:i];
        
    
        itemView.hidden = ![self bgImageForState:(XLMenuItemStateNormal) atIndex:i];
//        [itemView setImage:[self bgImageForState:(XLMenuItemStateNormal) atIndex:i] forState:(UIControlStateNormal)];
//        [itemView setImage:[self bgImageForState:(XLMenuItemStateSelected) atIndex:i] forState:(UIControlStateSelected)];

        [itemView setBackgroundImage:[self bgImageForState:(XLMenuItemStateNormal) atIndex:i] forState:(UIControlStateNormal)];
        [itemView setBackgroundImage:[self bgImageForState:(XLMenuItemStateSelected) atIndex:i] forState:(UIControlStateSelected)];
//        if (self.fontName) {
//            item.font = [UIFont fontWithName:self.fontName size:item.selectedSize];
//        } else {
//            item.font = [UIFont systemFontOfSize:item.selectedSize];
//        }
        if ([self.dataSource respondsToSelector:@selector(menuView:initialMenuItem:atIndex:)]) {
            item = [self.dataSource menuView:self initialMenuItem:item atIndex:i];
        }
        
        
        if (i == 0) {
            [item setSelected:YES withAnimation:NO];
            self.selItem = item;
            itemView.selected = YES;
            self.selItemView = itemView;
        } else {
            [item setSelected:NO withAnimation:NO];
            itemView.selected = NO;
        }
//        [itemView addSubview:item];
        [self.scrollView addSubview:itemView];
        [self.scrollView addSubview:item];
    }
}

// 计算所有item的frame值，主要是为了适配所有item的宽度之和小于屏幕宽的情况
// 这里与后面的 `-addItems` 做了重复的操作，并不是很合理
- (void)calculateItemFrames {
    CGFloat contentWidth = [self itemMarginAtIndex:0];
    for (int i = 0; i < self.titlesCount; i++) {
        CGFloat itemW = 60.0;
        if ([self.delegate respondsToSelector:@selector(menuView:widthForItemAtIndex:)]) {
            itemW = [self.delegate menuView:self widthForItemAtIndex:i];
        }
        // 高框取整，解决uilabel背景设置出现黑线问题
        CGRect frame = CGRectMake(contentWidth, 0, ceil(itemW), ceil(self.frame.size.height));
        // 记录frame
        [self.frames addObject:[NSValue valueWithCGRect:frame]];
        contentWidth += itemW + [self itemMarginAtIndex:i+1];
    }
    // 如果总宽度小于屏幕宽,重新计算frame,为item间添加间距
    if (contentWidth < self.scrollView.frame.size.width) {
        CGFloat distance = self.scrollView.frame.size.width - contentWidth;
        CGFloat (^shiftDis)(int);
        switch (self.layoutMode) {
            case XLMenuViewLayoutModeScatter: {
                CGFloat gap = distance / (self.titlesCount + 1);
                shiftDis = ^CGFloat(int index) { return gap * (index + 1); };
                break;
            }
            case XLMenuViewLayoutModeLeft: {
                shiftDis = ^CGFloat(int index) { return 0.0; };
                break;
            }
            case XLMenuViewLayoutModeRight: {
                shiftDis = ^CGFloat(int index) { return distance; };
                break;
            }
            case XLMenuViewLayoutModeCenter: {
                shiftDis = ^CGFloat(int index) { return distance / 2; };
                break;
            }
        }
        for (int i = 0; i < self.frames.count; i++) {
            CGRect frame = [self.frames[i] CGRectValue];
            frame.origin.x += shiftDis(i);
            self.frames[i] = [NSValue valueWithCGRect:frame];
        }
        contentWidth = self.scrollView.frame.size.width;
    }
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
}

- (CGFloat)itemMarginAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(menuView:itemMarginAtIndex:)]) {
        return [self.delegate menuView:self itemMarginAtIndex:index];
    }
    return 0.0;
}

// MARK:Progress View
- (void)addProgressViewWithFrame:(CGRect)frame isTriangle:(BOOL)isTriangle hasBorder:(BOOL)hasBorder hollow:(BOOL)isHollow cornerRadius:(CGFloat)cornerRadius {
    XLProgressView *pView = [[XLProgressView alloc] initWithFrame:frame];
    pView.itemFrames = [self convertProgressWidthsToFrames];
    pView.color = self.lineColor.CGColor;
    pView.isTriangle = isTriangle;
    pView.hasBorder = hasBorder;
    pView.hollow = isHollow;
    pView.cornerRadius = cornerRadius;
    pView.naughty = self.progressViewIsNaughty;
    pView.speedFactor = self.speedFactor;
    pView.backgroundColor = [UIColor clearColor];
    self.progressView = pView;
    [self.scrollView insertSubview:self.progressView atIndex:0];
}

#pragma mark - Menu item delegate
- (void)didPressedMenuItem:(XLMenuItem *)menuItem {
    
    if (_ignoreLastTwoTap) {
        UIView *lastV = [self.scrollView.subviews lastObject];
        NSInteger lastItemTag = lastV.tag;
        if (menuItem.tag == lastItemTag - 1 || menuItem.tag == lastItemTag) {
            // 仅处理一个自定义的响应，然后return
            if ([self.delegate respondsToSelector:@selector(menuViewIgnoreTapActionAtIndex:)]) {
                [self.delegate menuViewIgnoreTapActionAtIndex:menuItem.tag - XLMENUITEM_TAG_OFFSET];
            }
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(menuView:shouldSelesctedIndex:)]) {
        BOOL should = [self.delegate menuView:self shouldSelesctedIndex:menuItem.tag - XLMENUITEM_TAG_OFFSET];
        if (!should) {
            return;
        }
    }
    
    CGFloat progress = menuItem.tag - XLMENUITEM_TAG_OFFSET;
    [self.progressView moveToPostion:progress];
    
    NSInteger currentIndex = self.selItem.tag - XLMENUITEM_TAG_OFFSET;
    if ([self.delegate respondsToSelector:@selector(menuView:didSelectedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSelectedIndex:menuItem.tag - XLMENUITEM_TAG_OFFSET currentIndex:currentIndex];
    }
    
    // 根据设计师littlewhite要求，kevin取消动画
    [self.selItem setSelected:NO withAnimation:NO];
    [menuItem setSelected:YES withAnimation:NO];
    self.selItem = menuItem;
    
    self.selItemView.selected = NO;
    UIButton *view = [self viewWithTag:menuItem.tag - 1000];
    view.selected = YES;
    self.selItemView = view;
    
    
    NSTimeInterval delay = self.style == XLMenuViewStyleDefault ? 0 : 0.3f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 让选中的item位于中间
        [self refreshContenOffset];
    });
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            NSInteger selectedIndex = self.selItem.tag - XLMENUITEM_TAG_OFFSET;
            [self reload];
            [self setSelectIndex:selectedIndex];
            [self resetSelectionIfNeeded];
        }
    }
}
@end
