//
//  SerReceiptCollectionViewCell.m
//  FuelBuddy
//
//  Created by Nikhil on 02/07/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "SerReceiptCollectionViewCell.h"

@implementation SerReceiptCollectionViewCell

- (UIImageView *)receiptImage
{
    if (!_receiptImage) {
        _receiptImage = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_receiptImage];
    }
    return _receiptImage;
}

// Here we remove all the custom stuff that we added to our subclassed cell
-(void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.receiptImage removeFromSuperview];
    self.receiptImage = nil;
}

@end
