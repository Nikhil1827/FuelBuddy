//
//  TaxDeductionViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 19/11/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaxDeductionViewController : UIViewController <UITableViewDelegate , UITableViewDataSource, UITextFieldDelegate>
    
@property (nonatomic,retain)NSMutableArray *tripTypeArray;
@property (strong, nonatomic) IBOutlet UITableView *tripTypeTableView;

@end
