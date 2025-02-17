//
//  LogTableViewCell.h
//  FuelBuddy
//
//  Created by Surabhi on 24/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UILabel *odo;
@property (strong, nonatomic) IBOutlet UILabel *qty;
@property (strong, nonatomic) IBOutlet UILabel *dist;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *eff;

@end
