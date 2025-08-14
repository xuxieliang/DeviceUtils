//
//  XLMenuItem.h
//  YicaiVIP_APP
//
//  Created by kevin on 27/8/2020.
//  Copyright © 2020 www.diyicaijing.com. All rights reserved.
//

#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif
NS_ASSUME_NONNULL_BEGIN

@class XLMenuItem;

typedef NS_ENUM(NSUInteger, XLMenuItemState) {
    XLMenuItemStateSelected,
    XLMenuItemStateNormal,
};

typedef NS_ENUM(NSUInteger, XLMenuItemVerticalAlignment) {
    XLMenuItemVerticalAlignmentNormal,
    XLMenuItemVerticalAlignmentbottom = 1,
};

@protocol XLMenuItemDelegate <NSObject>
@optional

- (void)didPressedMenuItem:(XLMenuItem *)menuItem;

@end

@interface XLMenuItem : UILabel

@property (nonatomic, assign) CGFloat rate;             ///> 设置 rate, 并刷新标题状态 (0~1)
@property (nonatomic, assign) CGFloat normalSize;       ///> Normal状态的字体大小，默认大小为15
@property (nonatomic, assign) CGFloat selectedSize;     ///> Selected状态的字体大小，默认大小为18
@property (nonatomic, strong) UIFont *normalFont;       ///> Normal状态的字体大小，默认大小为15
@property (nonatomic, strong) UIFont *selectedFont;     ///> Selected状态的字体大小，默认大小为18
@property (nonatomic, strong) UIColor *normalColor;     ///> Normal状态的字体颜色，默认为黑色 (可动画)
@property (nonatomic, strong) UIColor *selectedColor;   ///> Selected状态的字体颜色，默认为红色 (可动画)
@property (nonatomic, strong) UIColor *normalBgColor;   ///> Normal状态的背景颜色，默认为白色 (可动画)
@property (nonatomic, strong) UIColor *selectedBgColor; ///> Selected状态的背景字体颜色，默认为白色 (可动画)
@property (nonatomic, assign) CGFloat speedFactor;      ///> 进度条的速度因数，默认 15，越小越快, 必须大于0
@property (nonatomic, assign) CGFloat radius;           ///> 圆角
@property (nonatomic, nullable, weak) id<XLMenuItemDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL selected;
@property (nonatomic, assign) XLMenuItemVerticalAlignment verticalAlignment;

- (void)setSelected:(BOOL)selected withAnimation:(BOOL)animation;

@end

NS_ASSUME_NONNULL_END
