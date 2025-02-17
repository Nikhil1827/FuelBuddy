//
//  HelpTableViewController.h
//  FuelBuddy
//
//  Created by Swapnil on 15/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface HelpTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *helpTable;
@property (nonatomic,assign)CGSize result;
@end
