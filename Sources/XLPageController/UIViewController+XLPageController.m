//
//  UIViewController+XLPageController.m
//  YicaiVIP_APP
//
//  Created by kevin on 27/8/2020.
//  Copyright © 2020 www.diyicaijing.com. All rights reserved.
//

#import "UIViewController+XLPageController.h"
#import "XLPageController.h"

@implementation UIViewController (XLPageController)
- (XLPageController *)xl_pageController {
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController) {
        if ([parentViewController isKindOfClass:[XLPageController class]]) {
            return (XLPageController *)parentViewController;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}
@end
