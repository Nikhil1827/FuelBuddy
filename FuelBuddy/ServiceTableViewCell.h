//
//  ServiceTableViewCell.h
//  FuelBuddy
//
//  Created by Surabhi on 16/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *namelab;
@property (strong, nonatomic) IBOutlet UIButton *checkmark;
@property (strong, nonatomic) IBOutlet UILabel *lastservice;

@end
