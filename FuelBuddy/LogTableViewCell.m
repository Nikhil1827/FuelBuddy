//
//  LogTableViewCell.m
//  FuelBuddy
//
//  Created by Surabhi on 24/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "LogTableViewCell.h"

@implementation LogTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


//-(void)layoutSubviews
//{
//    NSMutableArray *subviews = [self.subviews mutableCopy];
//    UIView *subV = subviews[0];
//    [subviews removeObjectAtIndex:0];
//    CGRect f = subV.frame;
//    f.origin.y =0;
//    f.size.height = 65; // Here you set height of Delete button
//    subV.frame = f;
//}
@end
