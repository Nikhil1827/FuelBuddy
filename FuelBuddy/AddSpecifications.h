//
//  AddSpecifications.h
//  FuelBuddy
//
//  Created by Swapnil on 28/07/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddSpecifications : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *specificationTable;
@property (nonatomic,retain) NSMutableArray *customSpecsArray, *tempArray;

@property (nonatomic,retain) NSString *nameString, *valueString, *custSpec;

- (void)viewDidAppear:(BOOL)animated;
- (void)viewDidLoad;

@end
