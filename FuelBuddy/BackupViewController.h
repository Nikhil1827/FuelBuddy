//
//  BackupViewController.h
//  FuelBuddy
//
//  Created by surabhi on 17/02/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "GTLDrive.h"
#import <GTMOAuth2ViewControllerTouch.h>
#import "GADMasterViewController.h"
#import "Reachability.h"
#import "GTLRDrive.h"
#import <GoogleSignIn/GoogleSignIn.h>



@interface BackupViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,GADBannerViewDelegate,GIDSignInDelegate , GIDSignInDelegate>
{
    BOOL receiptbackuprestore;
    UIView *alertbgview;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,retain) NSMutableArray *dataarray;
@property (nonatomic, strong) GTLRDriveService *service;
//@property GTLDriveFile *driveFile;
@property (retain) NSMutableArray *driveFiles;
@property (nonatomic,retain)UIView *loadingView;
@property (nonatomic,retain) NSString *fuelid,*vehid,*serviceid,*tripid;
@property (nonatomic,retain)NSString *flagstatus;
@end
