//
//  UIViewController+XLPageController.h
//  YicaiVIP_APP
//
//  Created by kevin on 27/8/2020.
//  Copyright © 2020 www.diyicaijing.com. All rights reserved.
//



#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class XLPageController;
@interface UIViewController (XLPageController)

/**
 获取控制器所在的WMPageController
 */
@property (nonatomic, nullable, strong, readonly) XLPageController *xl_pageController;

@end

NS_ASSUME_NONNULL_END
