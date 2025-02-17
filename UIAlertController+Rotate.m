//
//  UIAlertController+Rotate.m
//  FuelBuddy
//
//  Created by surabhi on 04/04/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "UIAlertController+Rotate.h"

@implementation UIAlertController (Rotate)

- (BOOL)shouldAutorotate {
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
