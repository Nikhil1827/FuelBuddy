//
//  GoProViewController.m
//  FuelBuddy
//
//  Created by surabhi on 09/03/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "GoProViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import <Crashlytics/Crashlytics.h>
#import "FaqViewController.h"
#import "SubscriptionTermsViewController.h"

#define kProductID @"premiumupgrade"
//ENH_58
#define kSubscriptionID @"subscriptionupgrade"
#define kMonthlySubscriptionID @"subscription_monthly"

@interface GoProViewController ()

@property BOOL oneTime;
@property BOOL yearly;
@property BOOL monthly;
@property BOOL receiptSent;
@end

@implementation GoProViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.tableview.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.tableview.separatorColor = [UIColor clearColor];
    self.tableview.userInteractionEnabled = YES;
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    //NSString *go_pro_btn = @"Go Pro";
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"])
    {

        self.navigationItem.title=NSLocalizedString(@"go_pro_btn", @"Go Pro");
        self.subView.hidden = YES;
    }
    else
    {
        self.navigationItem.title=@"Pro Version Active";
    }
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    
    //ENH_58 added segment control
    [self.segmentControl addTarget:self action:@selector(selectedsegment) forControlEvents:UIControlEventValueChanged];
    
    NSDictionary *segAttrs = @{NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium],NSForegroundColorAttributeName:[UIColor whiteColor]   };
          
    [self.segmentControl setTitleTextAttributes:segAttrs forState: UIControlStateNormal];

    NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor whiteColor]
                            };
    NSDictionary *subAttrs = @{
                               NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[self colorFromHexString:@"#FFCA1D"]
                               };
    
    NSAttributedString *string1 = [[NSAttributedString alloc]initWithString:@"The"attributes:attrs];
    
    NSAttributedString *string2 = [[NSAttributedString alloc]initWithString:@" Pro Version" attributes:subAttrs];
    NSMutableAttributedString *stringval = [[NSMutableAttributedString alloc]init];
  
    NSAttributedString *string3 = [[NSAttributedString alloc]initWithString:@" lets you..." attributes:attrs];
    [stringval appendAttributedString:string1];
    [stringval appendAttributedString:string2];
    [stringval appendAttributedString:string3];

    NSLog(@"App entered in viewDidLoad and setting callMethod to NO and adding addTransactionObserver");
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    self.callmethod = @"No";
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];
    [self selectedsegment];
    _receiptSent = NO;

}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"App entered in viewDidAppear");
    //[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
   // if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"])
   // {
       
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {

        NSLog(@"Internet connection not available.");
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@""
                                              message:NSLocalizedString(@"err_internet", @"Internet connection not available. Please try again later.")
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        self.goprogold.userInteractionEnabled = YES;
   
    } else {

        NSLog(@"Internet connection is available.");
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hideHUD"]){
           
            if(!_hud)
                [self createAndShowHud];
            
            
        }else{
            [self hideHud];
        }
        
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hideHUD"];
        NSLog(@"Checking if setCallMethod is YES?");
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"setCallMethod"]){

            NSLog(@"setCallMethod is YES!");
            [self createAndShowHud];
            //_oneTime= NO;
            if(_oneTime){

                NSLog(@"setCallMethod is YES for oneTime");
            }else if(_yearly){

                NSLog(@"setCallMethod is YES for yearly");
            }else if (_monthly){

                NSLog(@"setCallMethod is YES for monthly");
            }

            NSLog(@"So setting callMEthod to YES");
            self.callmethod = @"Yes";
            NSLog(@"calling fetchAvailableProducts from viewDidAppear to PURCHASE");
            [self fetchAvailableProducts];
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];
        }else{
            NSLog(@"setCallMethod is No!");
            self.callmethod = @"No";
            
        }
        
    }
  //  }
    //ENH_58 added segment control
    [self.tableview reloadData];
    
}

//ENH_58 Nikhil 25july2018 added segment control for subscription
-(void)selectedsegment {
    
    [self createAndShowHud];
    
    if(self.segmentControl.selectedSegmentIndex == 0){
        //New_8 changesDone
        self.dataarray = [[NSMutableArray alloc]initWithObjects:NSLocalizedString(@"instantSync", @"Instant sync of your receipts and vehicle images to the cloud"),
                          NSLocalizedString(@"websitePro", @"Access your data on the web at www.simplyauto.app"),NSLocalizedString(@"pro_add_more_vehicles",@"Add up to 7 vehicles"),NSLocalizedString(@"threeDrivers",@"Add upto 3 drivers to sync data with"),
                          NSLocalizedString(@"pro_gps_trip", @"GPS tracking for manual trips"),
                          NSLocalizedString(@"attachReceipts",@"Attach multiple receipts for fill-ups, services and expenses"),
                          NSLocalizedString(@"pro_backup_receipts", @"Backup and restore receipt images to Google Drive"),
                          NSLocalizedString(@"pro_add_custom", @"Add new service and expense tasks") ,
                          NSLocalizedString(@"emailLogs",@"Email your receipts and logs directly from the app"),NSLocalizedString(@"changeVol",@"Change volume unit for individual fill-ups"),NSLocalizedString(@"pro_priority_support_gold", @"Priority support. Response within 48 working hours."),
                          NSLocalizedString(@"pro_ad_free", @"Get rid of ads"), nil];
        
        self.imagearray =[[NSMutableArray alloc]initWithObjects:
                          @"backupC",
                          @"gp_website",
                          @"vehicles_yellow",
                          @"gp_add_drivers",
                          @"gps_yellow",
                          @"gp_receipts",
                          @"gp_receipt",
                          @"plus_yellow",
                          @"email_yellow",
                          @"gp_change_individual_unit",
                          @"gp_support",
                          @"ads_yellow", nil];

        NSLog(@"App entered in selectedSegment and setting oneTime to YES");
        _oneTime = YES;
        self.segmentControl.tintColor = [self colorFromHexString:@"#FFCA1D"];
        NSDictionary *segAttrs = @{NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium],NSForegroundColorAttributeName:[UIColor blackColor]   };
        [self.segmentControl setTitleTextAttributes:segAttrs forState: UIControlStateSelected];
        
        
        
        self.goprogold.backgroundColor = [self colorFromHexString:@"#FFCA1D"];
        self.goprogold.userInteractionEnabled = YES;
        self.subView.hidden = YES;
    }
    else {
        //New_8 changesDone
        self.dataarray = [[NSMutableArray alloc]initWithObjects:NSLocalizedString(@"instantSync", @"Instant sync of your receipts and vehicle images to the cloud"),
                          NSLocalizedString(@"websitePro", @"Access your data on the web at www.simplyauto.app"),NSLocalizedString(@"unlimitedVeh",@"Add unlimited vehicles"),NSLocalizedString(@"kahitari", @"Unlimited automatic trip logging"),NSLocalizedString(@"unlimitedDrivers",@"Sync data with unlmited drivers"),
                          NSLocalizedString(@"pro_automated_reports",@"Generate automated weekly and monthly reports"),
                          NSLocalizedString(@"pro_gps_trip", @"GPS tracking for manual trips"),@"Auto detect filling station names",
                          NSLocalizedString(@"attachReceipts",@"Attach multiple receipts for fill-ups, services and expenses"),
                          NSLocalizedString(@"pro_backup_receipts", @"Backup and restore receipt images to Google Drive"),
                          NSLocalizedString(@"pro_add_custom", @"Add new service and expense tasks") ,
                           NSLocalizedString(@"emailLogs",@"Email your receipts and logs directly from the app"),NSLocalizedString(@"changeVol",@"Change volume unit for individual fill-ups"),NSLocalizedString(@"pro_priority_support_platinum", @"Priority support. Response within 24 working hours."),
                          NSLocalizedString(@"pro_ad_free", @"Get rid of ads"), nil];
        
        self.imagearray =[[NSMutableArray alloc]initWithObjects:
                          @"backupC",
                          @"gp_website",
                          @"vehicles_yellow",
                          @"auto_tripPlatinum",
                          @"gp_add_drivers",
                          @"gp_auto_report1",
                          @"gps_yellow",
                          @"gp_filling_stn",
                          @"gp_receipts",
                          @"gp_receipt",
                          @"plus_yellow",
                          @"email_yellow",
                          @"gp_change_individual_unit",
                          @"gp_support",
                          @"ads_yellow", nil];

        NSLog(@"App entered in selectedSegment and setting oneTime to NO and yearly to YES");
        _oneTime = NO;
        _yearly = YES;

        if([[NSUserDefaults standardUserDefaults]boolForKey:@"isSubscribed"]){

            self.subView.hidden = YES;

        }else{
            self.subView.hidden = NO;
        }

        //self.subView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
        self.segmentControl.tintColor = [self colorFromHexString:@"#FFCA1D"];
        self.goproyearly.backgroundColor = [self colorFromHexString:@"#FFCA1D"];
        self.gopromonthly.backgroundColor = [self colorFromHexString:@"#FFCA1D"];
        self.goprogold.userInteractionEnabled = NO;
    }
    NSLog(@"Calling fetchAvailableProducts");
    [self fetchAvailableProducts];
    [self.tableview reloadData];
}

- (void)dealloc {

    NSLog(@"dealloc is called setting commented the removeObserver code for test");
//    productsRequest.delegate = nil;
//    [productsRequest cancel];
//    productsRequest = nil;
//    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate {
    return NO;
}
-(void)backbuttonclick
{
    NSLog(@"back button is clicked");
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataarray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] ;
        
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    cell.textLabel.text=[self.dataarray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.imageView.frame = CGRectMake(0, 0, 15, 15);
    cell.imageView.image = [UIImage imageNamed:[self.imagearray objectAtIndex:indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


-(void)fetchAvailableProducts{
    
    //ENH_58 Nikhil 25july2018 added subscription
    NSLog(@"App entered in fetchAvailableProducts");
    NSSet *productIdentifiers = [NSSet
                                 setWithObjects:kProductID,kSubscriptionID,kMonthlySubscriptionID,nil];
    productsRequest = [[SKProductsRequest alloc]
                       initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
} 

- (BOOL)canMakePurchases
{

    return [SKPaymentQueue canMakePayments];
}
- (void)purchaseProduct:(SKProduct*)product{

    if ([self canMakePurchases]) {
        NSLog(@"User is allowed to make payments for product :- %@",product);
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        NSLog(@"Came in purchase product so adding addTransactionObserver");
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
       
    }
    else{

        [self showAlert:@"Purchases are disabled in your device" message:@"" ];
    }
}

//simplyauto@gmail.com / S1mplyAut0
-(void)paymentQueue:(SKPaymentQueue *)queue
updatedTransactions:(NSArray *)transactions {

    NSLog(@"transactions :- %@",transactions);
    for (SKPaymentTransaction *transaction in transactions) {

        NSLog(@"transactionState :- %ld",(long)transaction.transactionState);
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                 NSLog(@"Purchasing");
                 NSLog(@"transaction.payment.productIdentifier :- %@",transaction.payment.productIdentifier);
                 NSLog(@"kProductID :- %@", kProductID);
                 NSLog(@"kSubscriptionID :- %@", kSubscriptionID);
                 NSLog(@"kSubscriptionID :- %@", kMonthlySubscriptionID);
                 break;
            case SKPaymentTransactionStatePurchased:

                 NSLog(@"Came in purchased state");
                 NSLog(@"transaction.payment.productIdentifier :- %@",transaction.payment.productIdentifier);
                 NSLog(@"kProductID :- %@", kProductID);
                 NSLog(@"kSubscriptionID :- %@", kSubscriptionID);
                 NSLog(@"kSubscriptionID :- %@", kMonthlySubscriptionID);

                 if ([transaction.payment.productIdentifier
                     isEqualToString:kProductID]) {
                    NSLog(@"Purchased Gold setting callMethod to No and setCallMEthod to No");

                    self.callmethod = @"No";
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];

                    NSLog(@"Setting isAdDisabled to true");
                    [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isAdDisabled"];

                    NSData *newReceipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
                     NSLog(@"Gold newReceipt:- %@",newReceipt);

                    NSLog(@"Calling callUploadSubscriptionReceipt in background from Gold");
                     [self performSelectorInBackground:@selector(callUploadSubscriptionReceipt:) withObject:newReceipt];

                    NSLog(@"finishTransaction:- %@",transaction);
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    [queue finishTransaction:transaction];

                    UIAlertController *alertController = [UIAlertController
                                                          alertControllerWithTitle:@""
                                                          message:NSLocalizedString(@"pur_thanks", @"Thanks a lot for your Purchase! You may need to re-open the app for the Purchase to take Effect.")
                                                          preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                                                        self.goprogold.userInteractionEnabled = false;

                                                    });


                                               }];

                     //new_7 june2018 Calling script for pro_status
                     NSLog(@"before callGoProScript");
                     [self callGoProScript:@1];

                     //Swapnil Fabric events
                     NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                     NSString *appInstallDate = [def objectForKey:@"installDate"];
                     [Answers logCustomEventWithName:@"Purchase Event Gold"
                                    customAttributes:@{@"App install date": appInstallDate}];
                     NSLog(@"after callGoProScript @1");
                     [self hideHud];
                    
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                
                 }else if ([transaction.payment.productIdentifier
                            isEqualToString:kSubscriptionID]) {
                     NSLog(@"Purchased Platinum yearly and setting callMethod to no and setCallMethod to No");
                     self.callmethod = @"No";
                     [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];
                     NSLog(@"Setting isAdDisabled and isSubscribed to true");
                     [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isAdDisabled"];
                     [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isSubscribed"];

                     NSData *newReceipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];

                     //NSLog(@"receipt received: - %@",newReceipt);
                     NSDate *currentDate = [NSDate date];
                     NSLog(@"currentDate :- %@",currentDate);

                     [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:@"platinumPurchaseDate"];
                     //ENH_58 Nikhil 25july2018 added subscription send receipt to server
                     NSLog(@"Calling callUploadSubscriptionReceipt in background from yearly");
                     [self performSelectorInBackground:@selector(callUploadSubscriptionReceipt:) withObject:newReceipt];
                     
                     [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                     [queue finishTransaction:transaction];
                     
                     UIAlertController *alertController = [UIAlertController
                                                           alertControllerWithTitle:@""
                                                           message:NSLocalizedString(@"pur_thanks", @"Thanks a lot for your Purchase! You may need to re-open the app for the Purchase to take Effect.")
                                                           preferredStyle:UIAlertControllerStyleAlert];
                     
                     UIAlertAction *okAction = [UIAlertAction
                                                actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action)
                                                {

                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                                                       self.goprogold.userInteractionEnabled = false;
                                                       [self.goproyearly setTitle:@"Purchased" forState:UIControlStateNormal];
                                                       self.subView.hidden = YES;
                                                       self.goproyearly.userInteractionEnabled = false;
                                                    });


                                                }];

                     NSLog(@"before callGoProScript yearly");
                     //new_7 june2018 Calling script for pro_status
                     [self callGoProScript:@2];
                     NSLog(@"after callGoProScript yearly @2");
                     [self hideHud];

                     NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                     NSString *appInstallDate = [def objectForKey:@"installDate"];
                     [Answers logCustomEventWithName:@"Purchase Event Platinum yearly"
                                    customAttributes:@{@"App install date": appInstallDate}];

                     
                     [alertController addAction:okAction];
                     [self presentViewController:alertController animated:YES completion:nil];

                 }else if ([transaction.payment.productIdentifier
                            isEqualToString:kMonthlySubscriptionID]) {
                     NSLog(@"Purchased Platinum Monthly  and setting callMethod to no and setCallMethod to No");
                     self.callmethod = @"No";
                     NSLog(@"Setting isAdDisabled and isSubscribed to true");
                     [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];
                     [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isAdDisabled"];
                     //TODO how to deal with below stuff
                     [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isSubscribed"];
                     [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isSubscribedMonthly"];

                     NSData *newReceipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];

                    // NSLog(@"receipt received: - %@",newReceipt);
                     NSDate *currentDate = [NSDate date];
                     NSLog(@"currentDate :- %@",currentDate);

                     [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:@"platinumPurchaseDate"];
                     //ENH_58 Nikhil 25july2018 added subscription send receipt to server
                     NSLog(@"Calling callUploadSubscriptionReceipt in background from monmthly");
                     [self performSelectorInBackground:@selector(callUploadSubscriptionReceipt:) withObject:newReceipt];

                     [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                     [queue finishTransaction:transaction];

                     UIAlertController *alertController = [UIAlertController
                                                           alertControllerWithTitle:@""
                                                           message:NSLocalizedString(@"pur_thanks", @"Thanks a lot for your Purchase! You may need to re-open the app for the Purchase to take Effect.")
                                                           preferredStyle:UIAlertControllerStyleAlert];

                     UIAlertAction *okAction = [UIAlertAction
                                                actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action)
                                                {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                                                       self.goprogold.userInteractionEnabled = false;
                                                       [self.gopromonthly setTitle:@"Purchased Monthly" forState:UIControlStateNormal];
                                                       self.subView.hidden = YES;
                                                       self.gopromonthly.userInteractionEnabled = false;
                                                    });


                                                }];

                     NSLog(@"before callGoProScript monthly");
                     //new_7 june2018 Calling script for pro_status
                     [self callGoProScript:@2];
                     NSLog(@"after callGoProScript monthly @2");
                     [self hideHud];

                     NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                     NSString *appInstallDate = [def objectForKey:@"installDate"];
                     [Answers logCustomEventWithName:@"Purchase Event Platinum Monthly"
                                    customAttributes:@{@"App install date monthly": appInstallDate}];

                     [alertController addAction:okAction];
                     [self presentViewController:alertController animated:YES completion:nil];

                 }
                
                break;
            case SKPaymentTransactionStateRestored:

                NSLog(@"Came in Restored state");
                NSLog(@"transaction.payment.productIdentifier :- %@",transaction.payment.productIdentifier);
                NSLog(@"kProductID :- %@", kProductID);
                NSLog(@"kSubscriptionID :- %@", kSubscriptionID);
                NSLog(@"kSubscriptionID :- %@", kMonthlySubscriptionID);
                if ([transaction.payment.productIdentifier
                     isEqualToString:kProductID]) {

                    //Added code from Nupur ma'am
                    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
                    NSLog(@"received restored from kProductID part transactions: %lu", (unsigned long)queue.transactions.count);

                    for (SKPaymentTransaction *transaction in queue.transactions)
                    {
                        NSString *productID = transaction.payment.productIdentifier;
                        [purchasedItemIDs addObject:productID];
                    }

                    NSLog(@"productID's are :- %@",purchasedItemIDs);


                    NSLog(@"Restored Gold and setting callMethod to No and setting isAdDisabled to true");
                    self.callmethod = @"No";
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];
                    [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isAdDisabled"];
                    
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    [queue finishTransaction:transaction];
                    
                    UIAlertController *alertController = [UIAlertController
                                                          alertControllerWithTitle:@""
                                                          message:NSLocalizedString(@"pur_thanks", @"Thanks a lot for your Purchase! You may need to re-open the app for the Purchase to take Effect.")
                                                          preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                                                       self.goprogold.userInteractionEnabled = false;
                                                       [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                                                       self.goprogold.userInteractionEnabled = false;
                                                    });

                                               }];

                    NSLog(@"before callGoProScript");
                    //new_7 10june2018 Calling script for pro_status
                    [self callGoProScript:@1];
                    NSLog(@"after callGoProScript @1");
                    [self hideHud];

                    //NIKHIL ENH_49 getting transactionIdentifier
                    NSString *tranIdentifier = [[SKPaymentQueue defaultQueue].transactions lastObject].transactionIdentifier;
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    NSString *appInstallDate = [def objectForKey:@"installDate"];
                    [Answers logCustomEventWithName:@"Restore Successfull"
                                   customAttributes:@{@"App install date": appInstallDate,@"Transaction ID": tranIdentifier}];
                    
                    [alertController addAction:okAction];
                    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"]){
                        [self presentViewController:alertController animated:YES completion:nil];
                    }

                    
                }else if ([transaction.payment.productIdentifier
                           isEqualToString:kSubscriptionID]) {

                    //Added code from Nupur ma'am
                    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
                    NSLog(@"received restored from kSubscriptionID part transactions: %lu", (unsigned long)queue.transactions.count);

                    for (SKPaymentTransaction *transaction in queue.transactions)
                    {
                        NSString *productID = transaction.payment.productIdentifier;
                        [purchasedItemIDs addObject:productID];
                    }

                    NSLog(@"productID's are :- %@",purchasedItemIDs);

                    
                    NSLog(@"Restored Platinum yearly and setting callMethod to No and setting isAdDisabled and isSubscribed to true");
                    self.callmethod = @"No";
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];
                    //ENH_58 Nikhil 25july2018 added subscription
                    [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isAdDisabled"];
                    [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isSubscribed"];
                    
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    [queue finishTransaction:transaction];
                    
                    UIAlertController *alertController = [UIAlertController
                                                          alertControllerWithTitle:@""
                                                          message:NSLocalizedString(@"pur_thanks", @"Thanks a lot for your Purchase! You may need to re-open the app for the Purchase to take Effect.")
                                                          preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                                                       self.goprogold.userInteractionEnabled = false;
                                                       [self.goproyearly setTitle:@"Purchased" forState:UIControlStateNormal];
                                                       self.subView.hidden = YES;
                                                       self.goproyearly.userInteractionEnabled = false;
                                                    });

                                               }];
                    
                    NSLog(@"before callGoProScript yearly");
                    //new_7 10june2018 Calling script for pro_status
                    [self callGoProScript:@2];
                    NSLog(@"after callGoProScript  yearly @2");
                    [self hideHud];

                    //NIKHIL ENH_49 getting transactionIdentifier
                    NSString *tranIdentifier = [[SKPaymentQueue defaultQueue].transactions lastObject].transactionIdentifier;
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    NSString *appInstallDate = [def objectForKey:@"installDate"];
                    [Answers logCustomEventWithName:@"Restore Successfull yearly"
                                   customAttributes:@{@"App install date": appInstallDate,@"Transaction ID": tranIdentifier}];

                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                }else if ([transaction.payment.productIdentifier
                           isEqualToString:kMonthlySubscriptionID]) {

                    //Added code from Nupur ma'am
                    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
                    NSLog(@"received restored from kMonthlySubscriptionID part transactions: %lu", (unsigned long)queue.transactions.count);

                    for (SKPaymentTransaction *transaction in queue.transactions)
                    {
                        NSString *productID = transaction.payment.productIdentifier;
                        [purchasedItemIDs addObject:productID];
                    }

                    NSLog(@"productID's are :- %@",purchasedItemIDs);


                    NSLog(@"Restored Platinum Monthly and setting callMethod to No and setting isAdDisabled and isSubscribed to true");
                    self.callmethod = @"No";
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];
                    //ENH_58 Nikhil 25july2018 added subscription
                    [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isAdDisabled"];
                    [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isSubscribed"];
                    [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isSubscribedMonthly"];

                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    [queue finishTransaction:transaction];

                    UIAlertController *alertController = [UIAlertController
                                                          alertControllerWithTitle:@""
                                                          message:NSLocalizedString(@"pur_thanks", @"Thanks a lot for your Purchase! You may need to re-open the app for the Purchase to take Effect.")
                                                          preferredStyle:UIAlertControllerStyleAlert];

                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                                                       self.goprogold.userInteractionEnabled = false;
                                                       [self.gopromonthly setTitle:@"Purchased Monthly" forState:UIControlStateNormal];
                                                       self.subView.hidden = YES;
                                                       self.gopromonthly.userInteractionEnabled = false;
                                                    });

                                               }];

                    NSLog(@"before callGoProScript monthly");
                    //new_7 10june2018 Calling script for pro_status
                    [self callGoProScript:@2];
                    NSLog(@"after callGoProScript  monthly @2");
                    [self hideHud];

                    //NIKHIL ENH_49 getting transactionIdentifier
                    NSString *tranIdentifier = [[SKPaymentQueue defaultQueue].transactions lastObject].transactionIdentifier;
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    NSString *appInstallDate = [def objectForKey:@"installDate"];
                    [Answers logCustomEventWithName:@"Restore Successfull monthly"
                                   customAttributes:@{@"App install date": appInstallDate,@"Transaction ID": tranIdentifier}];


                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];

                }
                
                else
                {

                    //Added code from Nupur ma'am
                    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
                    NSLog(@"received restored from else part transactions: %lu", (unsigned long)queue.transactions.count);

                    for (SKPaymentTransaction *transaction in queue.transactions)
                    {
                        NSString *productID = transaction.payment.productIdentifier;
                        [purchasedItemIDs addObject:productID];
                    }

                    NSLog(@"productID's are :- %@",purchasedItemIDs);


                    NSLog(@"Came in else part as it did not find any product ids");
                    NSLog(@"transaction.payment.productIdentifier :- %@",transaction.payment.productIdentifier);
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    [queue finishTransaction:transaction];
                    [self showAlert:@"No content available to restore" message:@""];
                    //NIKHIL BUG_159
                    //NIKHIL ENH_49 getting transactionIdentifier
                    NSString *tranIdentifier = [[SKPaymentQueue defaultQueue].transactions lastObject].transactionIdentifier;
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    NSString *appInstallDate = [def objectForKey:@"installDate"];
                    [Answers logCustomEventWithName:@"Restore failed on restore"
                                   customAttributes:@{@"App install date": appInstallDate,@"Transaction ID": tranIdentifier}];
                    [self hideHud];
                    SKPaymentTransaction *tran =[[SKPaymentQueue defaultQueue].transactions lastObject];
                    NSLog(@"Transaction failed due to:-%@",tran.error);
                }
                
                break;
         
            case    SKPaymentTransactionStateFailed:
                     {
                    NSLog(@"Came in Failed state and still setting callMethod and setCallMethod to NO");
                    self.callmethod = @"No";
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    [queue finishTransaction:transaction];
                    SKPaymentTransaction *tran =[[SKPaymentQueue defaultQueue].transactions lastObject];
                    NSLog(@"Transaction failed due to what? ahh tell me what???? :- %@",tran.error);
                    //NIKHIL BUG_159
                    //NIKHIL ENH_49 fabric event
                   // NSString *tranIdentifier = [[SKPaymentQueue defaultQueue].transactions lastObject].transactionIdentifier;
                         
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    NSString *appInstallDate = [def objectForKey:@"installDate"];
                    [Answers logCustomEventWithName:@"Purchase failed Event"
                                   customAttributes:@{@"App install date": appInstallDate}];
                         
                    [self hideHud];
                         
                    NSString *error = [NSString stringWithFormat:@"Transaction failed due to %@",tran.error];
                    [self showAlert:@"Purchase cancelled or failed" message:error];
                         
                         
                    break;
                     }
            default: NSLog(@"called default");
                break;
        }
    }
    
    //[self hideHud];
}

-(void)productsRequest:(SKProductsRequest *)request
    didReceiveResponse:(SKProductsResponse *)response
{
    //SKProduct *validProduct = nil;
    //SKProduct *monthlyProduct = nil;
    NSLog(@"App entered in productsRequest: didReceiveResponse");
    long count = [response.products count];
    if (count>0) {
        validProducts = response.products;
        NSLog(@"Valid products are :- %@",validProducts);
        //NSLog(@"validProducts:- %@",response.products);
        //ENH_58 Nikhil 25july2018 added subscription

        for(SKProduct *product in response.products){

            if(_oneTime){

                if([product.productIdentifier
                     isEqualToString:kProductID]){

                    NSLog(@"Gold Version Selected");

                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                    [numberFormatter setLocale:product.priceLocale];
                    NSString *formattedString = [NSString stringWithFormat:@"%@ ONE TIME",[numberFormatter stringFromNumber:product.price]];
                    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isAdDisabled"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                           [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                           self.goprogold.userInteractionEnabled = false;
                        });

                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                           [self.goprogold setTitle:formattedString forState:UIControlStateNormal];
                           self.goprogold.userInteractionEnabled = true;
                        });

                    }
                    NSLog(@"checking callMethod :- %@",self.callmethod);
                    if([self.callmethod isEqualToString:@"Yes"])
                    {
                        NSLog(@"purchaseProduct in gold is called for product :- %@",product);
                        [self purchaseProduct:product];
                    }

                    else
                    {
                        [self hideHud];
                    }
                    break;

                }

            }else if(_yearly || _monthly){

                if([product.productIdentifier isEqualToString:kSubscriptionID]){

                    NSLog(@"Platinum Version Selected");

                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                    [numberFormatter setLocale:product.priceLocale];

                    NSString *formattedString = [NSString stringWithFormat:@"%@ / YEAR",[numberFormatter stringFromNumber:product.price]];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([[NSUserDefaults standardUserDefaults]boolForKey:@"isSubscribed"]){

                            [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                            self.goprogold.userInteractionEnabled = false;
                            [self.goproyearly setTitle:@"Purchased" forState:UIControlStateNormal];
                            self.subView.hidden = YES;
                            self.goproyearly.userInteractionEnabled = false;
                        }else{
                            [self.goproyearly setTitle:formattedString forState:UIControlStateNormal];
                            self.goproyearly.userInteractionEnabled = true;
                        }
                    });


                }else if([product.productIdentifier isEqualToString:kMonthlySubscriptionID]){

                    NSNumberFormatter *numberFormatter1 = [[NSNumberFormatter alloc] init];
                    [numberFormatter1 setFormatterBehavior:NSNumberFormatterBehavior10_4];
                    [numberFormatter1 setNumberStyle:NSNumberFormatterCurrencyStyle];
                    [numberFormatter1 setLocale:product.priceLocale];

                    NSString *formattedString1 = [NSString stringWithFormat:@"%@ / MONTH",[numberFormatter1 stringFromNumber:product.price]];

                    dispatch_async(dispatch_get_main_queue(), ^{
                       if([[NSUserDefaults standardUserDefaults]boolForKey:@"isSubscribedMonthly"]){
                           [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                           self.goprogold.userInteractionEnabled = false;
                           [self.gopromonthly setTitle:@"Purchased" forState:UIControlStateNormal];
                           self.subView.hidden = YES;
                           self.gopromonthly.userInteractionEnabled = false;
                       }else{
                           [self.gopromonthly setTitle:formattedString1 forState:UIControlStateNormal];
                           self.gopromonthly.userInteractionEnabled = true;
                       }
                    });

                }
                NSLog(@"checking callMethod :- %@",self.callmethod);
                if([self.callmethod isEqualToString:@"Yes"])
                {
                    if(_yearly){

                        if([product.productIdentifier isEqualToString:kSubscriptionID]){

                            NSLog(@"purchaseProduct in yearly is called for product :- %@",product);
                            [self purchaseProduct:product];
                            break;
                        }

                    }else if(_monthly){

                        if([product.productIdentifier isEqualToString:kMonthlySubscriptionID]){

                            NSLog(@"purchaseProduct in monthly is called for product :- %@",product);
                            [self purchaseProduct:product];
                            break;
                        }
                    }

                }else {

                    [self hideHud];
                }

            }

        }

    } else {
        
        [self hideHud];
        [self showAlert:@"Not Available" message:@"No products to purchase"];
    }
    
}

-(void)createAndShowHud{
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.label.text = NSLocalizedString(@"loading_msg", @"Loading");
    _hud.offset = CGPointMake(0,85);
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    if(App.result.height == 480) {
        _hud.offset = CGPointMake(0,120);
    }
    
    _hud.label.textColor = [self colorFromHexString:@"#FFCA1D"];
    _hud.bezelView.backgroundColor = [UIColor clearColor];
    _hud.bezelView.alpha =0.6;
}

-(void)hideHud{
    
    NSLog(@"removing loading indicator");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_hud hideAnimated:YES];
        [_hud removeFromSuperViewOnHide];
        [_hud removeFromSuperview];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    });
}

//ENH_58 Nikhil 25july2018 added subscription
-(void)callUploadSubscriptionReceipt:(NSData *)receiptData {

    NSLog(@"Entered in callUploadSubscriptionReceipt");
    if(_receiptSent){

        NSLog(@"receiptSent is yes ");
        [[NSUserDefaults standardUserDefaults]setObject:receiptData forKey:@"receiptData"];
        NSMutableDictionary *uploadDictionary = [[NSMutableDictionary alloc]init];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if([def objectForKey:@"UserEmail"]){
            NSLog(@"user has email ");
            [uploadDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
        }else{
            NSLog(@"user do not have email sending dummy@simplyauto.app");
            [uploadDictionary setObject:@"dummy@simplyauto.app" forKey:@"email"];
        }

        [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                            NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error fetching remote instance ID: %@", error);
            } else {
                NSString *fcmToken = result.token;
                //NSString *fcmToken = [[FIRInstanceID instanceID] token];
                [uploadDictionary setObject:fcmToken forKey:@"reg_id"];
                NSString *base64Data = [receiptData base64EncodedStringWithOptions:0];
                [uploadDictionary setObject:base64Data forKey:@"receipt"];
                //NSLog(@"uploadDictionary:- %@",uploadDictionary);

                NSError *err;
                NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:uploadDictionary options:NSJSONWritingPrettyPrinted error:&err];

                commonMethods *common = [[commonMethods alloc]init];
                [def setBool:NO forKey:@"updateTimeStamp"];
                [common saveToCloud:postDataArray urlString:kSubscriptionScript success:^(NSDictionary *responseDict) {

                    NSLog(@"ResponseDict of callUploadSubscriptionReceipt purchase: %@", responseDict);

                } failure:^(NSError *error){

                    NSLog(@"receipt upload failed");
                }];
            }
        }];

    }
    _receiptSent = NO;
}

-(void)callGoProScript:(NSNumber *)proStatus {

    NSLog(@"App entered in callGoProScript");
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    
    if([def objectForKey:@"UserEmail"]){
        [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
    }else{
        [parametersDictionary setObject:@"" forKey:@"email"];
    }
    [parametersDictionary setObject:proStatus forKey:@"pro_status"];
    NSError *err;
    NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
    
    commonMethods *common = [[commonMethods alloc]init];
    [def setBool:NO forKey:@"updateTimeStamp"];
    [common saveToCloud:postDataArray urlString:kGoProScript success:^(NSDictionary *responseDict) {
        
        NSLog(@"ResponseDict is callGoProScript: %@", responseDict);
        
    } failure:^(NSError *error) {
        
       // NSLog(@"friend request failed");
    }];

}

- (IBAction)goproclick:(id)sender {

    NSLog(@"User clicked on gold button");
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"confirm", @"Confirm")
                                          message:NSLocalizedString(@"go_pro_btn", @"Go Pro")
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"purchase_btn", @"Purchase")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"User clicked on purchase button");
                                   Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                                   NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                                   if (networkStatus == NotReachable) {
                                       
                                       [self showAlert:@"" message:NSLocalizedString(@"err_internet", @"Internet connection not available. Please try again later.")];
                                       
                                   }
                                   else {
                                       NSLog(@"Setting oneTime-YES, yearly-No, monthly-NO");
                                       _oneTime = YES;
                                       _yearly = NO;
                                       _monthly = NO;

                                       NSLog(@"ValidProducts.count is:- %lu",(unsigned long)validProducts.count);
                                       if(validProducts.count == 0)
                                       {
                                           NSLog(@"As count is 0 setting callMethod to YES and calling fetchAvailableProducts");
                                           self.callmethod = @"Yes";
                                           [self fetchAvailableProducts];
                                           
                                       }
                                       else
                                       {
                                           NSLog(@"ValidProducts is:- %@",validProducts);
                                           for(SKProduct *product in validProducts){

                                               if([product.productIdentifier
                                                   isEqualToString:kProductID]){

                                                   NSLog(@"Gold Version Selected and calling purchaseProduct");


                                                   [self purchaseProduct:product];

                                               }

                                           }

                                       }
                                       
                                   }

                               }];
    
    UIAlertAction *restoreAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"restore", @"Restore action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"User clicked on restore button");
                                   [self createAndShowHud];
                                   [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
                                   [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
                                   
                                 if([SKPaymentQueue defaultQueue].transactions.count == 0)
                                  {
                                      
                                      NSLog(@"no transactions available in queue to restore");
                                  }

                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"cancel", @"Cancel action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"User clicked on cancel button");
                                   [self hideHud];
                               }];
    
    [alertController addAction:okAction];
    [alertController addAction:restoreAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (IBAction)goproyearlyclick:(id)sender{

    NSLog(@"User clicked on yearly button");
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"confirm", @"Confirm")
                                          message:NSLocalizedString(@"go_pro_btn", @"Go Pro")
                                          preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"purchase_btn", @"Purchase")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"User clicked on purchase button");
                                   Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                                   NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                                   if (networkStatus == NotReachable) {

                                       [self showAlert:@"" message:NSLocalizedString(@"err_internet", @"Internet connection not available. Please try again later.")];

                                   }
                                   else {

                                       NSLog(@"Setting oneTime-NO, yearly-YES, monthly-NO");
                                       _oneTime = NO;
                                       _yearly = YES;
                                       _monthly = NO;
                                       _receiptSent = YES;
                                       //1 = yearly, 2 = monthly
                                       NSLog(@"Setting subscriptionPeriod to 1 for yearly and calling showSubscriptionAlert");
                                       [[NSUserDefaults standardUserDefaults] setDouble:1 forKey:@"subscriptionPeriod"];
                                       [self showSubscriptionAlert];;

                                   }

                               }];

    UIAlertAction *restoreAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"restore", @"Restore action")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                         NSLog(@"User clicked on restore button");
                                        [self createAndShowHud];
                                        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
                                        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];

                                        if([SKPaymentQueue defaultQueue].transactions.count == 0)
                                        {

                                            NSLog(@"no transactions available in queue to restore");
                                            CLSLog(@"no restore");
                                        }

                                    }];

    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"cancel", @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"User clicked on cancel button");
                                       [self hideHud];
                                   }];

    [alertController addAction:okAction];
    [alertController addAction:restoreAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)gopromonthlyclick:(id)sender{

    NSLog(@"User clicked on monthly button");
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"confirm", @"Confirm")
                                          message:NSLocalizedString(@"go_pro_btn", @"Go Pro")
                                          preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"purchase_btn", @"Purchase")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"User clicked on purchase button");
                                   Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                                   NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                                   if (networkStatus == NotReachable) {

                                       [self showAlert:@"" message:NSLocalizedString(@"err_internet", @"Internet connection not available. Please try again later.")];

                                   }
                                   else {
                                       NSLog(@"Setting oneTime-NO, yearly-NO, monthly-YES");
                                       _oneTime = NO;
                                       _yearly = NO;
                                       _monthly = YES;
                                       _receiptSent = YES;
                                       //1 = yearly, 2 = monthly
                                       NSLog(@"Setting subscriptionPeriod to 2 for monthly and calling showSubscriptionAlert");
                                       [[NSUserDefaults standardUserDefaults] setDouble:2 forKey:@"subscriptionPeriod"];
                                       [self showSubscriptionAlert];

                                   }

                               }];

    UIAlertAction *restoreAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"restore", @"Restore action")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        NSLog(@"User clicked on restore button");
                                        [self createAndShowHud];
                                        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
                                        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];

                                        if([SKPaymentQueue defaultQueue].transactions.count == 0)
                                        {

                                            NSLog(@"no transactions available in queue to restore");
                                            CLSLog(@"no restore");
                                        }

                                    }];

    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"cancel", @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"User clicked on cancel button");
                                       [self hideHud];
                                   }];

    [alertController addAction:okAction];
    [alertController addAction:restoreAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

-(void)showSubscriptionAlert{

    NSLog(@"Entered in showSubscriptionAlert");
    SKProduct *validProduct = nil;
    SKProduct *monthlyProduct = nil;
    if(_yearly){

        for(SKProduct *product in validProducts){

            if([product.productIdentifier
                isEqualToString:kSubscriptionID]){
                NSLog(@"yearly is YES, product is right so setting validProduct = product to get local price");
                validProduct = product;

            }

        }

        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:validProduct.priceLocale];

        [[NSUserDefaults standardUserDefaults] setObject:[numberFormatter stringFromNumber:validProduct.price] forKey:@"priceLocale"];
        NSLog(@"Presenting SubscriptionTermsViewController");
        SubscriptionTermsViewController *subsScreen =(SubscriptionTermsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"subscriptionDetail"];
        subsScreen.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:subsScreen animated:YES completion:nil];

    }else if(_monthly){

        for(SKProduct *product in validProducts){

            if([product.productIdentifier
                isEqualToString:kMonthlySubscriptionID]){
                NSLog(@"monthly is YES, product is right so setting validProduct = product to get local price");
                monthlyProduct = product;

            }

        }

        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:monthlyProduct.priceLocale];

        [[NSUserDefaults standardUserDefaults] setObject:[numberFormatter stringFromNumber:monthlyProduct.price] forKey:@"priceLocale"];
        NSLog(@"Presenting SubscriptionTermsViewController");
        SubscriptionTermsViewController *subsScreen =(SubscriptionTermsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"subscriptionDetail"];
        subsScreen.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:subsScreen animated:YES completion:nil];
    }

}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];
    
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
//    NSLog(@"Entered in viewDidDissappear setting productRequestDelegate to nil and removeTransactionObserver");
//    productsRequest.delegate = nil;
//    [productsRequest cancel];
//    productsRequest =nil;
//    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"Entered in restoreCompletedTransactionsFailedWithError");
    [self hideHud];
   // NSString *tranIdentifier = [[SKPaymentQueue defaultQueue].transactions lastObject].transactionIdentifier;
    NSString *errString = [NSString stringWithFormat:@"%@", error.localizedDescription];
  //  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  //  NSString *appInstallDate = [def objectForKey:@"installDate"];
   // [Answers logCustomEventWithName:@"Restore failed on Canceled"
     //              customAttributes:@{@"App install date": appInstallDate,@"Transaction ID": tranIdentifier,@"Failed with error":errString}];
    NSLog(@"failed restore purchase due to %@",errString);
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
    //Added code from Nupur ma'am
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);

    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
    }

    NSLog(@"productID's are :- %@",purchasedItemIDs);

    if(purchasedItemIDs.count > 0){

        NSLog(@"kProductID :- %@", kProductID);
        NSLog(@"kSubscriptionID :- %@", kSubscriptionID);
        NSLog(@"kSubscriptionID :- %@", kMonthlySubscriptionID);

        BOOL isItPlatinumMonthly = [purchasedItemIDs containsObject: kMonthlySubscriptionID];
        BOOL isItPlatinumYearly = [purchasedItemIDs containsObject: kSubscriptionID];
        BOOL isItGold = [purchasedItemIDs containsObject: kProductID];


        if (isItPlatinumYearly) {

            NSLog(@"Restored Platinum yearly and setting callMethod to No and setting isAdDisabled and isSubscribed to true");
            self.callmethod = @"No";
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];
            //ENH_58 Nikhil 25july2018 added subscription
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isAdDisabled"];
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isSubscribed"];


            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@""
                                                  message:NSLocalizedString(@"pur_thanks", @"Thanks a lot for your Purchase! You may need to re-open the app for the Purchase to take Effect.")
                                                  preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                                           self.goprogold.userInteractionEnabled = false;
                                           [self.goproyearly setTitle:@"Purchased" forState:UIControlStateNormal];
                                           self.subView.hidden = YES;
                                           self.goproyearly.userInteractionEnabled = false;
                                       }];

            NSLog(@"before callGoProScript yearly");
            //new_7 10june2018 Calling script for pro_status
            [self callGoProScript:@2];
            NSLog(@"after callGoProScript  yearly @2");
            [self hideHud];

            //NIKHIL ENH_49 getting transactionIdentifier
            NSString *tranIdentifier = [[SKPaymentQueue defaultQueue].transactions lastObject].transactionIdentifier;
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSString *appInstallDate = [def objectForKey:@"installDate"];
            [Answers logCustomEventWithName:@"Restore Successfull yearly"
                           customAttributes:@{@"App install date": appInstallDate,@"Transaction ID": tranIdentifier}];

            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];


        }else if (isItPlatinumMonthly) {


            NSLog(@"Restored Platinum Monthly and setting callMethod to No and setting isAdDisabled and isSubscribed to true");
            self.callmethod = @"No";
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];
            //ENH_58 Nikhil 25july2018 added subscription
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isAdDisabled"];
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isSubscribed"];
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isSubscribedMonthly"];


            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@""
                                                  message:NSLocalizedString(@"pur_thanks", @"Thanks a lot for your Purchase! You may need to re-open the app for the Purchase to take Effect.")
                                                  preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                                           self.goprogold.userInteractionEnabled = false;
                                           [self.gopromonthly setTitle:@"Purchased Monthly" forState:UIControlStateNormal];
                                           self.subView.hidden = YES;
                                           self.gopromonthly.userInteractionEnabled = false;
                                       }];

            NSLog(@"before callGoProScript monthly");
            //new_7 10june2018 Calling script for pro_status
            [self callGoProScript:@2];
            NSLog(@"after callGoProScript  monthly @2");
            [self hideHud];

            //NIKHIL ENH_49 getting transactionIdentifier
            NSString *tranIdentifier = [[SKPaymentQueue defaultQueue].transactions lastObject].transactionIdentifier;
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSString *appInstallDate = [def objectForKey:@"installDate"];
            [Answers logCustomEventWithName:@"Restore Successfull monthly"
                           customAttributes:@{@"App install date": appInstallDate,@"Transaction ID": tranIdentifier}];


            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];

        }else if (isItGold) {

            NSLog(@"Restored Gold and setting callMethod to No and setting isAdDisabled to true");
            self.callmethod = @"No";
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setCallMethod"];
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isAdDisabled"];

            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@""
                                                  message:NSLocalizedString(@"pur_thanks", @"Thanks a lot for your Purchase! You may need to re-open the app for the Purchase to take Effect.")
                                                  preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                                           self.goprogold.userInteractionEnabled = false;
                                           [self.goprogold setTitle:@"Purchased" forState:UIControlStateNormal];
                                           self.goprogold.userInteractionEnabled = false;
                                       }];

            NSLog(@"before callGoProScript");
            //new_7 10june2018 Calling script for pro_status
            [self callGoProScript:@1];
            NSLog(@"after callGoProScript @1");
            [self hideHud];

            //NIKHIL ENH_49 getting transactionIdentifier
            NSString *tranIdentifier = [[SKPaymentQueue defaultQueue].transactions lastObject].transactionIdentifier;
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSString *appInstallDate = [def objectForKey:@"installDate"];
            [Answers logCustomEventWithName:@"Restore Successfull"
                           customAttributes:@{@"App install date": appInstallDate,@"Transaction ID": tranIdentifier}];

            [alertController addAction:okAction];
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"]){
                [self presentViewController:alertController animated:YES completion:nil];
            }

        }

    }



    [self hideHud];
   
}

@end
