//
//  CloudHelpTableVC.h
//  FuelBuddy
//
//  Created by Swapnil on 12/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloudHelpTableVC : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *cloudHelpTable;

@property int selection;

@end
