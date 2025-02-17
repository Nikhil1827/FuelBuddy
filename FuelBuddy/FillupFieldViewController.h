//
//  FillupFieldViewController.h
//  FuelBuddy
//
//  Created by Swapnil on 20/03/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FillupFieldViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSInteger rowSelected;


@property (nonatomic,retain) NSMutableArray *fillUparray, *checkedarray, *tripCheck0, *tripCheck1, *tripCheck2, *tripCheck3;
@property (nonatomic,retain) NSMutableArray *tripSection0, *tripSection1, *tripSection2, *tripSection3;
@property (nonatomic,retain) NSMutableDictionary *indexDict;

@property (nonatomic,retain) NSArray *tripFinalArray;

@end
