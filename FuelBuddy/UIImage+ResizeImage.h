//
//  UIImage+ResizeImage.h
//  FuelBuddy
//
//  Created by surabhi on 14/04/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ResizeImage)
-(UIImage*)imageWithImage:(UIImage*)image
             scaledToSize:(CGSize)newSize;
@end
