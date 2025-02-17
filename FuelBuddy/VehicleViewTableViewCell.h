//
//  VehicleViewTableViewCell.h
//  FuelBuddy
//
//  Created by Surabhi on 04/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VehicleViewTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UILabel *vehiclename;
@property (strong, nonatomic) IBOutlet UIButton *checkmark;

@end
