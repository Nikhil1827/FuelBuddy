//
//  logMainTableViewCell.h
//  FuelBuddy
//
//  Created by Nikhil on 28/09/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface logMainTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UILabel *qty;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *odo;
@property (strong, nonatomic) IBOutlet UILabel *dist;
@property (strong, nonatomic) IBOutlet UILabel *eff;
@end
