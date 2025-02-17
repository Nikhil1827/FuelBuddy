//
//  UITextField+TextPadding.m
//  FuelBuddy
//
//  Created by Swapnil on 23/02/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "UITextField+TextPadding.h"

@implementation UITextField (TextPadding)

-(CGRect)editingRectForBounds:(CGRect)bounds{
    
    return CGRectInset(bounds, 4.8, 3);
}


@end
