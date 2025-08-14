//
//  XLScrollView.h
//  YicaiVIP_APP
//
//  Created by kevin on 27/8/2020.
//  Copyright © 2020 www.diyicaijing.com. All rights reserved.
//

#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif
NS_ASSUME_NONNULL_BEGIN

@interface XLScrollView : UIScrollView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *header;

@end

NS_ASSUME_NONNULL_END
