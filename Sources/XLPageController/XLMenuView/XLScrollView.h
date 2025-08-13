//
//  XLScrollView.h
//  YicaiVIP_APP
//
//  Created by kevin on 27/8/2020.
//  Copyright © 2020 www.diyicaijing.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XLScrollView : UIScrollView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *header;

@end

NS_ASSUME_NONNULL_END
