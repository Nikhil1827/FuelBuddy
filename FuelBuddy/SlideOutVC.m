//
//  SlideOutVC.m
//  FuelBuddy
//
//  Created by Swapnil on 13/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "SlideOutVC.h"
#import "ResyncVC.h"
#import "AppDelegate.h"
#import "CloudHelpTableVC.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import "MoreViewController.h"
#import "SlideOutTableViewCell.h"
#import "FullSyncViewController.h"

@interface SlideOutVC ()
{
    NSArray *tableViewContents;
}
@end

@implementation SlideOutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"slideOutOn"];
    self.slideOutTable.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.slideOutTable.scrollEnabled = NO;
    self.slideOutTable.delegate = self;
    self.slideOutTable.dataSource = self;
    
    self.slideOutTable.separatorColor = [self colorFromHexString:@"#2c2c2c"];
    
    //nikhil 12june2018 added extra cell for fullSync
    tableViewContents = [[NSArray alloc] initWithObjects:NSLocalizedString(@"resync", @"Resync"),NSLocalizedString(@"full_sync_title", @"Full Sync"),NSLocalizedString(@"help", @"Help"),@"Deregister",nil];
    
    
    self.dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(dismissOnTap)];
    
    self.dismissTap.delegate = self;
    [self.view addGestureRecognizer:self.dismissTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissThisView)
                                                 name:@"dismissSlideOut"
                                               object:nil];
}

- (void)dismissThisView{
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)viewDidAppear:(BOOL)animated{
//
//    //self.dismissTap.enabled = YES;
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    if([[def valueForKey:@"cameFromFullSync"]  isEqual: @1]){
//     [def setValue:@0 forKey:@"cameFromFullSync"];
//     [self.presentingViewController dismissViewControllerAnimated:NO completion:NULL];
//    }
//}

-(void)viewWillDisappear:(BOOL)animated{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([[def objectForKey:@"slideOutOn"] isEqualToString:@"yes"]){
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissAfterDeregister"
                                                        object:nil];
    }
    
}

- (void)dismissOnTap{
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)startActivitySpinner: (NSString *)labelText {
    // [[self driveService] setAuthorizer:auth];
    
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    if(app.result.width == 320)
    {
        self.loadingView = [[UIView alloc]initWithFrame:CGRectMake(120, 200, 100, 100)];
    }
    else
    {
        self.loadingView = [[UIView alloc]initWithFrame:CGRectMake(150, 200, 100, 100)];
    }
    self.loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    self.loadingView.layer.cornerRadius = 5;

    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(_loadingView.frame.size.width / 2.0, 35);
    
    [activityView startAnimating];
    
    //    if(flagStatus == false){
    //        [activityView stopAnimating];
    //    }
    activityView.tag = 100;
    [self.loadingView addSubview:activityView];
    
    
    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(3, 48, 100, 50)];
    lblLoading.text = labelText;
    lblLoading.numberOfLines = 2;
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:13];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    
    [self.loadingView addSubview:lblLoading];
    [self.view addSubview:self.loadingView];
    
    
}


-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


- (void)callDeleteProfileScript{
    
   // [commonMethods startActivitySpinner:@"Deregistering..."];

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    //NSMutableDictionary *syncDictionary = [[NSMutableDictionary alloc] init];
    
    NSError *err;
    [dictionary setValue:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    
    commonMethods *common = [[commonMethods alloc] init];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"localTimeStamp"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"timeStamp"
                                                        object:nil];
    [common saveToCloud:postData urlString:kDeleteProfileScript success:^(NSDictionary *responseDict) {
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"localTimeStamp"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"timeStamp"
                                                            object:nil];
        if([[responseDict objectForKey:@"success"] intValue] == 1){
            
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"UserEmail"];
            
            //NIKHIL BUG_147
            dispatch_async(dispatch_get_main_queue(), ^{
               [self alertForDeregister:@"Successfully deregistered" message:@""];
                
            });
            
            //NSLog(@"Successfully deregistered from sync");
        } else {
            //NSLog(@"Error while deregistering");
        }
    } failure:^(NSError *error) {
        
       // NSLog(@"Error while deregistering");
    }];
}


- (void)alertForDeregister: (NSString *)title message: (NSString *)message{
    //NIKHIL BUG_147
    [self.loadingView removeFromSuperview];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"slideOutOn"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissAfterDeregister"
                                                            object:nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissSlideOut"
//                                                            object:nil];
        [self dismissViewControllerAnimated:NO completion:^{
            
            [self viewWillDisappear:NO];
        }];
    }];
    
    //    UIAlertAction *canel = [UIAlertAction actionWithTitle:NSLocalizedString(@"no", @"No") style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:ok];
    //[alert addAction:canel];
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark Table View datasource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return tableViewContents.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //self.dismissTap.enabled = NO;
    SlideOutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        
        cell = [[SlideOutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor=[UIColor clearColor];
    cell.slideLabel.textColor = [UIColor whiteColor];
   
    
    cell.slideLabel.text = [tableViewContents objectAtIndex:indexPath.row];
    
    
    if(indexPath.row == 1){
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if([def boolForKey:@"redRequest"]){
            
            cell.redDotImage.image = [UIImage imageNamed:@"redDot"];
            
        }else{
            
            cell.redDotImage.image = [UIImage imageNamed:@""];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(indexPath.row == 0){
        
        [[NSUserDefaults standardUserDefaults] setObject:@"userClicked" forKey:@"resyncPopup"];
        
        ResyncVC *resync = (ResyncVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"resyncScreen"];
        resync.fromViewController = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"downloadFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"downloadStarted"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"settingsFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"vehicleFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"logFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"upload"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"uploadFinish"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textForSpinner:)
                                                     name:@"failError"
                                                   object:nil];
        
        resync.onDismiss = ^(UIViewController *sender, NSString* message)
        {
            
            self.dismissTap.enabled = NO;
            
        };
        
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:resync animated:YES completion:nil];
            
            [self.slideOutTable setHidden:YES];
        });

    }
    
    if(indexPath.row == 1){
        
        FullSyncViewController *fullSyncView = (FullSyncViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"fullSyncRequest"];
        dispatch_async(dispatch_get_main_queue(), ^{
          [self presentViewController:fullSyncView animated:YES completion:nil];
           [self.slideOutTable setHidden:YES];
        });
    }
    
    if(indexPath.row == 2){
        
        CloudHelpTableVC *cloudHelp = (CloudHelpTableVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"cloudHelpTableVC"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cloudHelp.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:cloudHelp animated:YES completion:nil];
            [self.slideOutTable setHidden:YES];
        });
    }
    
    if(indexPath.row == 3){
        
        [self.slideOutTable setHidden:YES];
        [self deregisterPopup];
    }
}


- (void)deregisterPopup{
    
    NSString *title = NSLocalizedString(@"sync_deregister_title", @"Deregister from sync");
    NSString *message = NSLocalizedString(@"deregistermsg", @"Do you want to deregister from Sync? You will need to Sign in again to send and receive data from server");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"yes", @"Yes")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                        //NIKHIL BUG_147 script sent to background thread
                                        [self startActivitySpinner:@"Deregistering..."];
                                        UIApplication *app = [UIApplication sharedApplication];
                                        __block UIBackgroundTaskIdentifier bgTask;
                                        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
                                            
                                             [app endBackgroundTask:bgTask];
                                             bgTask = UIBackgroundTaskInvalid;
                                        }];
                                                         
                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                    [self callDeleteProfileScript];

                                                });
                                                        //      [self callDeleteProfileScript];
                                }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}


- (void)textForSpinner: (NSNotification *)notification{
    
    //NIKHIL BUG_147
    AppDelegate *app = [[AppDelegate alloc]init];
    UIView *topView = app.topView;
    [[topView viewWithTag:101] removeFromSuperview];

//    if([[notification name] isEqualToString:@"downloadStarted"]){
//
//        [self startActivitySpinner:@"Downloading"];
//    }

    if([[notification name] isEqualToString:@"downloadFinish"]){
        
        [self.loadingView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"downloadStarted" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"downloadFinish" object:nil];
        [self startActivitySpinner:@"Downloading Settings"];
    }

    if([[notification name] isEqualToString:@"settingsFinish"]){
        
        [self.loadingView removeFromSuperview];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"settingsFinish" object:nil];
        [self startActivitySpinner:@"Downloading Vehicles"];
        
    }
    
    if([[notification name] isEqualToString:@"vehicleFinish"]){
        
        [self.loadingView removeFromSuperview];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"vehicleFinish" object:nil];
        [self startActivitySpinner:@"Downloading Log"];
        
    }
    
    if([[notification name] isEqualToString:@"logFinish"]){
        
        [self.loadingView removeFromSuperview];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"logFinish" object:nil];
        
        NSDate *date = [[NSDate alloc] init];
        //NSLog(@"localTS : %@", date);
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"localTimeStamp"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"timeStamp"
                                                            object:nil];
        [self showAlert:@"Data downloaded successfully" message:@""];
        //[self startActivitySpinner:@"Downloading Log"];
        
        
    }
    
    if([[notification name] isEqualToString:@"upload"]){
        
        self.dismissTap.enabled = NO;
        [self startActivitySpinner:@"Uploading.."];
        
    }
    
    if([[notification name] isEqualToString:@"uploadFinish"]){
        
        [self.loadingView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"upload" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"uploadFinish" object:nil];
        [self showAlert:@"Phone data backed up to cloud" message:@""];
        
    }
    
    if([[notification name] isEqualToString:@"failError"]){
        
        [self.loadingView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"upload" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"failError" object:nil];
        //NIKHIL BUG_149
        NSString *message =  [notification.userInfo objectForKey:@"message"];
        [self showAlert:NSLocalizedString(@"failed",@"Failed") message:message];
        
    }
}


- (void)showAlert: (NSString *)title message:(NSString *)message{
    
    self.dismissTap.enabled = YES;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:nil];
    
    //    UIAlertAction *canel = [UIAlertAction actionWithTitle:NSLocalizedString(@"no", @"No") style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:ok];
    //[alert addAction:canel];
    [self presentViewController:alert animated:YES completion:nil];
    
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    //NSLog(@"touch view : %@", touch.view);
    //NSLog(@"")
    
    if([touch.view.superview isKindOfClass:[UITableViewCell class]] || [touch.view.superview isKindOfClass:[UIAlertAction class]]){
        
        return NO;
    }
    
    return YES;
}

@end
