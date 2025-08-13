//
//  XLMenuView.h
//  YicaiVIP_APP
//
//  Created by kevin on 27/8/2020.
//  Copyright © 2020 www.diyicaijing.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLMenuItem.h"
#import "XLProgressView.h"
#define XLUNDEFINED_VALUE -1
NS_ASSUME_NONNULL_BEGIN


@class XLMenuView;

typedef NS_ENUM(NSUInteger, XLMenuViewStyle) {
    XLMenuViewStyleDefault,      // 默认
    XLMenuViewStyleLine,         // 带下划线 (若要选中字体大小不变，设置选中和非选中大小一样即可)
    XLMenuViewStyleTriangle,     // 三角形 (progressHeight 为三角形的高, progressWidths 为底边长)
    XLMenuViewStyleFlood,        // 涌入效果 (填充)
    XLMenuViewStyleFloodHollow,  // 涌入效果 (空心的)
    XLMenuViewStyleSegmented,    // 涌入带边框,即网易新闻选项卡
};

// 原先基础上添加了几个方便布局的枚举，更多布局格式可以通过设置 `itemsMargins` 属性来自定义
// 以下布局均只在 item 个数较少的情况下生效，即无法滚动 MenuView 时.
typedef NS_ENUM(NSUInteger, XLMenuViewLayoutMode) {
    XLMenuViewLayoutModeScatter, // 默认的布局模式, item 会均匀分布在屏幕上，呈分散状
    XLMenuViewLayoutModeLeft,    // Item 紧靠屏幕左侧
    XLMenuViewLayoutModeRight,   // Item 紧靠屏幕右侧
    XLMenuViewLayoutModeCenter,  // Item 紧挨且居中分布
};

@protocol XLMenuViewDelegate <NSObject>
@optional
- (BOOL)menuView:(XLMenuView *)menu shouldSelesctedIndex:(NSInteger)index;
- (void)menuView:(XLMenuView *)menu didSelectedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex;
- (CGFloat)menuView:(XLMenuView *)menu widthForItemAtIndex:(NSInteger)index;
- (CGFloat)menuView:(XLMenuView *)menu itemMarginAtIndex:(NSInteger)index;
- (CGFloat)menuView:(XLMenuView *)menu titleSizeForState:(XLMenuItemState)state atIndex:(NSInteger)index;
- (UIFont *)menuView:(XLMenuView *)menu titleFontForState:(XLMenuItemState)state atIndex:(NSInteger)index;
- (UIColor *)menuView:(XLMenuView *)menu titleColorForState:(XLMenuItemState)state atIndex:(NSInteger)index;
- (UIColor *)menuView:(XLMenuView *)menu bgColorForState:(XLMenuItemState)state atIndex:(NSInteger)index;
- (nullable UIImage *)menuView:(XLMenuView *)menu bgImageForState:(XLMenuItemState)state atIndex:(NSInteger)index;
- (void)menuView:(XLMenuView *)menu didLayoutItemFrame:(XLMenuItem *)menuItem atIndex:(NSInteger)index;

// 点击忽略的index事件响应
- (void)menuViewIgnoreTapActionAtIndex:(NSInteger)index;

@end

@protocol XLMenuViewDataSource <NSObject>

@required
- (NSInteger)numbersOfTitlesInMenuView:(XLMenuView *)menu;
- (NSString *)menuView:(XLMenuView *)menu titleAtIndex:(NSInteger)index;

@optional
/**
 *  角标 (例如消息提醒的小红点) 的数据源方法，在 WMPageController 中实现这个方法来为 menuView 提供一个 badgeView
    需要在返回的时候同时设置角标的 frame 属性，该 frame 为相对于 menuItem 的位置
 *
 *  @param index 角标的序号
 *
 *  @return 返回一个设置好 frame 的角标视图
 */
- (UIView *)menuView:(XLMenuView *)menu badgeViewAtIndex:(NSInteger)index;

/**
 *  用于定制 XLMenuItem，可以对传出的 initialMenuItem 进行修改定制，也可以返回自己创建的子类，需要注意的是，此时的 item 的 frame 是不确定的，所以请勿根据此时的 frame 做计算！
    如需根据 frame 修改，请使用代理
 *
 *  @param menu            当前的 menuView，frame 也是不确定的
 *  @param initialMenuItem 初始化完成的 menuItem
 *  @param index           Item 所属的位置;
 *
 *  @return 定制完成的 MenuItem
 */
- (XLMenuItem *)menuView:(XLMenuView *)menu initialMenuItem:(XLMenuItem *)initialMenuItem atIndex:(NSInteger)index;

@end

@interface XLMenuView : UIView<XLMenuItemDelegate>
@property (nonatomic, strong) NSArray *progressWidths;
@property (nonatomic, weak) XLProgressView *progressView;
@property (nonatomic, assign) CGFloat progressHeight;
@property (nonatomic, assign) XLMenuViewStyle style;
@property (nonatomic, assign) XLMenuViewLayoutMode layoutMode;
@property (nonatomic, assign) CGFloat contentMargin;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat progressViewBottomSpace;
@property (nonatomic, weak) id<XLMenuViewDelegate> delegate;
@property (nonatomic, weak) id<XLMenuViewDataSource> dataSource;
@property (nonatomic, weak) UIView *leftView;
@property (nonatomic, weak) UIView *rightView;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, weak) UIScrollView *scrollView;
/** 进度条的速度因数，默认为 15，越小越快， 大于 0 */
@property (nonatomic, assign) CGFloat speedFactor;
// 圆角
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat progressViewCornerRadius;
@property (nonatomic, assign) BOOL progressViewIsNaughty;
@property (nonatomic, assign) BOOL showOnNavigationBar;
@property (nonatomic, assign) XLMenuItemVerticalAlignment verticalAlignment;
/** 是否忽略最后两个下标的点击 */
@property (nonatomic, assign) BOOL ignoreLastTwoTap;

- (void)slideMenuAtProgress:(CGFloat)progress;
- (void)selectItemAtIndex:(NSInteger)index;
- (void)resetFrames;
- (void)reload;
- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index andWidth:(BOOL)update;
- (void)updateAttributeTitle:(NSAttributedString *)title atIndex:(NSInteger)index andWidth:(BOOL)update;
- (XLMenuItem *)itemAtIndex:(NSInteger)index;
/// 立即刷新 menuView 的 contentOffset，使 title 居中
- (void)refreshContenOffset;
- (void)deselectedItemsIfNeeded;
/**
 *  更新角标视图，如要移除，在 -menuView:badgeViewAtIndex: 中返回 nil 即可
 */
- (void)updateBadgeViewAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
