//
//  FullSyncViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 02/05/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullSyncViewController : UIViewController <UITableViewDelegate , UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UILabel *pendingLabel;
@property (strong, nonatomic) IBOutlet UILabel *willBeDeletedLabel;
@property (strong, nonatomic) IBOutlet UITableView *fullSyncTableView;
@property (nonatomic,retain) NSMutableArray *fullSyncArray;

@end
