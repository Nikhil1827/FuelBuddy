//
//  LoggedInVC.h
//  FuelBuddy
//
//  Created by Swapnil on 12/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoggedInVC : UIViewController <UITableViewDelegate , UITableViewDataSource>

@property (nonatomic,retain)UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *lastSyncLabel;
@property (strong, nonatomic) IBOutlet UITableView *addDriverTableView;
@property (strong, nonatomic) IBOutlet UILabel *proLabel;
//ADD DRIVER SCENE friendsArray
@property (nonatomic,retain) NSMutableArray *friendsArray;
@property (nonatomic, strong) void (^onDismiss)(UIViewController *sender, NSString* message);

- (void)startActivitySpinner: (NSString *)labelText;

- (IBAction)addDriverButtonClicked:(id)sender;


@end
