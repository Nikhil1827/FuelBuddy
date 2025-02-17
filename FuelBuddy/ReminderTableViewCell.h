//
//  ReminderTableViewCell.h
//  FuelBuddy
//
//  Created by surabhi on 30/04/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReminderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *LastDate;
@property (weak, nonatomic) IBOutlet UILabel *DueOdo;
@property (weak, nonatomic) IBOutlet UIProgressView *progressbar;

@end
