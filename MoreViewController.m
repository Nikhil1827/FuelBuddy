//
//  MoreViewController.m
//  FuelBuddy
//
//  Created by Surabhi on 16/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "MoreViewController.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import <MessageUI/MessageUI.h>
#import "AboutViewController.h"
#import "BackupViewController.h"
#import "GoProViewController.h"
#import "ReminderViewController.h"
#import "AutorotateNavigation.h"
#import "ViewVehicleViewController.h"
#import "EmailLogViewController.h"
#import "T_Fuelcons.h"
#import "Veh_Table.h"
#import "T_Trip.h"
#import "Services_Table.h"
#import "SignInCloudViewController.h"
#import "AutoTripLoggingViewController.h"
#import "SyncHelpRootVC.h"
#import "LoggedInVC.h"
#import "HelpTableViewController.h"
#import "ReportViewController.h"
#import "MapViewController.h"

@interface MoreViewController ()

@end

//Swapnil 15 Mar-17
// static GADMasterViewController *shared;
@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=NO;
    [self.tabBarController.tabBar setHidden:NO];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odovalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odofilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datevalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"notefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"recordfilter"];
    NSMutableArray *newTabs = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
    self.tabBarController.tabBarItem = [newTabs objectAtIndex:2];
    [self.tabBarController setViewControllers:newTabs];
    
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title=NSLocalizedString(@"more", @"More");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    
    
    
    
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    self.tableview.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.tableview.tableFooterView = [UIView new];
    self.tableview.separatorColor =[UIColor darkGrayColor];
    
    self.imagearray = [[NSMutableArray alloc]initWithObjects:
                       @"settings",
                       @"vehicles_yellow",
                       @"syncMenu",
                       @"auto_trip",
                       @"gp_trip_map",
                       @"More_email",
                       @"gd_backup",
                       @"gopro",
                       @"helpMenu",
                       @"about", nil];
    

}


-(void)viewWillAppear:(BOOL)animated{
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"])
    {
        //Swapnil 16 Mar-17
        //NIKHIL 8june2018 making sync free
        NSString *signIn = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
        NSString *sigInLabel;
        if(signIn != nil){
            
            sigInLabel = NSLocalizedString(@"sync_btn_after_login", @"My Cloud Account");
        } else {
            
            sigInLabel = NSLocalizedString(@"sync_btn", @"Sign In To Cloud");
        }
        
        self.titlearray = [[NSMutableArray alloc]initWithObjects:
                           NSLocalizedString(@"settings_tv", @"Settings"),
                           NSLocalizedString(@"veh_tv", @"Vehicles"),
                           sigInLabel,NSLocalizedString(@"auto_drive_detect_menu",@"Auto Trip Logging"),NSLocalizedString(@"maps", @"Maps"),
                           NSLocalizedString(@"report", @"Report"),
                           NSLocalizedString(@"exim_btn", @"Google Drive Backup"),
                           NSLocalizedString(@"go_pro_btn", @"Go Pro"),
                           NSLocalizedString(@"help", @"Help"),
                           NSLocalizedString(@"abt_btn", @"About"), nil];
    }
    else
    {
        
        NSString *signIn = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
        NSString *sigInLabel;
        if(signIn != nil){
            
            sigInLabel = NSLocalizedString(@"sync_btn_after_login", @"My Cloud Account");
        } else {
            
            sigInLabel = NSLocalizedString(@"sync_btn", @"Sign In To Cloud");
        }
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"]){
            
            self.titlearray = [[NSMutableArray alloc]initWithObjects:
                               NSLocalizedString(@"settings_tv", @"Settings"),
                               NSLocalizedString(@"veh_tv", @"Vehicles"),
                               sigInLabel,@"Auto Trip Logging",NSLocalizedString(@"maps", @"Maps"),
                               NSLocalizedString(@"report", @"Report"),
                               NSLocalizedString(@"exim_btn", @"Google Drive Backup"),
                               @"Gold Version Active",
                               NSLocalizedString(@"help", @"Help"),
                               NSLocalizedString(@"abt_btn", @"About"), nil];
            
        }else{
            
            self.titlearray = [[NSMutableArray alloc]initWithObjects:
                               NSLocalizedString(@"settings_tv", @"Settings"),
                               NSLocalizedString(@"veh_tv", @"Vehicles"),
                               sigInLabel,@"Auto Trip Logging",NSLocalizedString(@"maps", @"Maps"),
                               NSLocalizedString(@"report", @"Report"),
                               NSLocalizedString(@"exim_btn", @"Google Drive Backup"),
                               @"Platinum Version Active",
                               NSLocalizedString(@"help", @"Help"),
                               NSLocalizedString(@"abt_btn", @"About"), nil];
            
        }
        
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

    [self.tableview reloadData];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)viewDidDisappear:(BOOL)animated
{
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    
    [self.tabBarController.tabBar setHidden:NO];
    App.tabbutton.hidden=NO;
    App.result = [[UIScreen mainScreen] bounds].size;
    [App.blurview removeFromSuperview];
    [App.tabbutton setImage:[UIImage imageNamed:@"tab_add_new"] forState:UIControlStateNormal];
    [App.expense removeFromSuperview];
    [App.trip removeFromSuperview];
    [App.services removeFromSuperview];
    [App.fillup removeFromSuperview];
    [App.expenselab removeFromSuperview];
    [App.filluplab removeFromSuperview];
    [App.serviceslab removeFromSuperview];
    [App.tripLab removeFromSuperview];
    App.services.selected=NO;
    
}

#pragma mark - TABLEVIEW DATASOURCE METHODS

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titlearray.count;
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] ;
        
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor=[UIColor clearColor];
    cell.imageView.image = [UIImage imageNamed:[self.imagearray objectAtIndex:indexPath.row]];
    cell.textLabel.text = [self.titlearray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0)
    {
        SettingsViewController *settings = (SettingsViewController*) [self.storyboard instantiateViewControllerWithIdentifier:@"settings"];
        dispatch_async(dispatch_get_main_queue(), ^{
            settings.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:settings animated:YES completion:nil];
        });
        
    }
    
    if(indexPath.row == 1){
        ViewVehicleViewController *vehicle = (ViewVehicleViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"viewvehicle"];
        dispatch_async(dispatch_get_main_queue(), ^{
            vehicle.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vehicle animated:YES completion:nil];
        });
    }
    
    if(indexPath.row == 2){

//            if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"SyncHelpScreensShown"] isEqualToString:@"1"]){
//
//                SyncHelpRootVC *signIn = (SyncHelpRootVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"cloudHelpScreens"];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self presentViewController:signIn animated:YES completion:nil];
//                });
//
//            } else {

                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"cameFromOnBoardScreen"];

                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                
                //check sign in status. if yes show Logged in vc else sign in screen
                NSString *userEmail = [def objectForKey:@"UserEmail"];
                
                SignInCloudViewController *signIn = (SignInCloudViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"cloudSignIn"];
                
                LoggedInVC *loggedIn = (LoggedInVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"loggedInScreen"];
                
                if (userEmail != nil && userEmail.length > 0) {

                    loggedIn.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self.navigationController presentViewController:loggedIn animated:YES completion:nil];
                    
                } else {

                    signIn.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self.navigationController presentViewController:signIn animated:YES completion:nil];
                }
                
      //      }

    }

    if(indexPath.row == 3)
    {
        AutoTripLoggingViewController *autoTrip = (AutoTripLoggingViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"autoTrip"];
        dispatch_async(dispatch_get_main_queue(), ^{
            autoTrip.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:autoTrip animated:YES completion:nil];
        });
      
    }
    
    if(indexPath.row == 4)
    {
        MapViewController *mapVC = (MapViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"mapScreenView"];
        dispatch_async(dispatch_get_main_queue(), ^{
            mapVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:mapVC animated:YES completion:nil];
        });
    }
    
    //Swapnil 16 Mar-17
    if(indexPath.row == 5)
    {
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"] == false && [[NSUserDefaults standardUserDefaults] integerForKey:@"emailSentCount"] >= 5){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Trial Period Expired" message:@"To continue using the Email feature please Go Pro" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:NO completion:nil];
            }];
            UIAlertAction *goPro = [UIAlertAction actionWithTitle:NSLocalizedString(@"go_pro_btn", @"Go Pro")  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    gopro.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:gopro animated:YES completion:nil];
                });
            }];
            
            
            
            [alert addAction:ok];
            [alert addAction:goPro];
            
            [self presentViewController:alert animated:NO completion:nil];
        } else {

            //ENH_55 Nikhil 7sep2018 For Report
            ReportViewController *reportView = (ReportViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"reportViewContoller"];
            reportView.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:reportView animated:YES completion:nil];
            
        }
    }
    
    if(indexPath.row == 6)
    {
        BackupViewController *backup = (BackupViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"backup"];
        dispatch_async(dispatch_get_main_queue(), ^{
            backup.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:backup animated:YES completion:nil];
        });
    }

    
    
    if(indexPath.row == 7)
    {
        GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
        dispatch_async(dispatch_get_main_queue(), ^{
            gopro.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:gopro animated:YES completion:nil];
        });
    }

    if(indexPath.row == 8){
        
        HelpTableViewController *helpVC = (HelpTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"helpTable"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            helpVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:helpVC animated:YES completion:nil];
        });
    }
    
    if(indexPath.row == 9)
    {
        AboutViewController *about = (AboutViewController*) [self.storyboard instantiateViewControllerWithIdentifier:@"about"];
        dispatch_async(dispatch_get_main_queue(), ^{
            about.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:about animated:YES completion:nil];
        });
        
    }
    
}


-(void)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath
{
    NSString *filePathAndDirectory = [filePath stringByAppendingPathComponent:directoryName];
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error])
    {
        NSLog(@"Create directory error: %@", error);
    }
    
    else
    {
        
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
