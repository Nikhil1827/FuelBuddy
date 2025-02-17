//
//  ExPReceiptCollectionViewCell.m
//  FuelBuddy
//
//  Created by Nikhil on 29/06/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "ExPReceiptCollectionViewCell.h"

@implementation ExPReceiptCollectionViewCell

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
