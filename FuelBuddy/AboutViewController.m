//
//  AboutViewController.m
//  FuelBuddy
//
//  Created by surabhi on 07/01/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "AboutViewController.h"
#import "FaqViewController.h"
#import "AppDelegate.h"
#import "Veh_Table.h"
#import "T_Fuelcons.h"
#import "Services_Table.h"
#import "T_Trip.h"

@interface AboutViewController (){
    
    int tapCount;
}

@end
 static GADMasterViewController *shared;
@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
     self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title= NSLocalizedString(@"abt_btn", @"About");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
     initWithAttributedString: self.bottomLabel.attributedText];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:[self colorFromHexString:@"#FFCA1D"]
                 range:NSMakeRange(26, 9)];
    [self.bottomLabel setAttributedText: text];
    self.versionlabel.text = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    
    [self.privacyButton setTitle:NSLocalizedString(@"pattern2", @"Privacy Policy") forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

    tapCount = 0;
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

-(void)backbuttonclick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//New_8 changesDone
- (IBAction)fuelbuddyclick:(id)sender {
    FaqViewController *faq = (FaqViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"faq"];
    faq.urlstring = @"http://www.simplyauto.app";
    faq.navtitle = @"www.simplyauto.app";
    faq.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:faq animated:YES];
}

- (IBAction)supportclick:(id)sender {
   
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[@"support-ios@simplyauto.app"]];
        composeViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:composeViewController animated:YES completion:nil];
    }

}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)customiseclick:(id)sender {

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"customize_tv", @"Customise SimplyAuto")  message:NSLocalizedString(@"customize_message", @"Would you like to customize Simply Auto for your business or personal needs? Please contact us at support-ios@simplyauto.app and we will surely help you out.")                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)faqclick:(id)sender {
    FaqViewController *faq = (FaqViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"faq"];
    faq.urlstring = @"https://simplyauto.app/blog.html";
    faq.navtitle = @"Blog";//NSLocalizedString(@"faq", @"FAQs");
    faq.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:faq animated:YES];
}

- (IBAction)fbclick:(id)sender {
    FaqViewController *faq = (FaqViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"faq"];
    faq.urlstring = @"https://www.facebook.com/fuelbuddytheapp";
    faq.navtitle = @"Facebook";
    faq.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:faq animated:YES];
}


- (IBAction)policyClick:(id)sender {
    
    FaqViewController *faq = (FaqViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"faq"];
    faq.urlstring = @"http://www.simplyauto.app/policy.html";
    faq.navtitle = NSLocalizedString(@"pattern2", @"Privacy Policy");
    faq.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:faq animated:YES];
}

- (IBAction)termsClick:(id)sender{
    
    FaqViewController *faq = (FaqViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"faq"];
    faq.urlstring = @"http://www.simplyauto.app/Terms2.html";
    faq.navtitle = NSLocalizedString(@"pattern1", @"Terms of Service");
    faq.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:faq animated:YES];
    
}

- (IBAction)twitterclick:(id)sender {
    FaqViewController *faq = (FaqViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"faq"];
    faq.urlstring = @"https://twitter.com/simply_auto_app";
    faq.navtitle = @"Twitter";
    faq.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:faq animated:YES];
}

- (IBAction)googleclick:(id)sender {
    
}

- (IBAction)mobifolioclick:(id)sender {
    FaqViewController *faq = (FaqViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"faq"];
    faq.urlstring = @"http://www.mobifolio.net";
    faq.navtitle = @"Mobifolio";
    faq.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:faq animated:YES];
}
- (IBAction)sendConsoleButtonPressed:(id)sender {
    
    tapCount = tapCount + 1;
    
    if(tapCount == 3){
    
        [self showEmail];
        tapCount = 0;
    }
    
}

- (void)showEmail{

    NSString *recipient = @"support-ios@simplyauto.app";
    NSArray *recipients = [NSArray arrayWithObjects:recipient, nil];
    NSString *appVersion = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
    NSString *userStatus;
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];

    if(proUser){
        userStatus = @"I am a <b>Pro User</b>";
    } else {
        userStatus = @"I am <b>NOT a Pro User</b>";
    }
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    //[mailViewController setSubject:@"Space Phone Usage Export"];

    NSString *messageBody = [NSString stringWithFormat:@"I am using <b>Simply Auto : %@</b> and <b>iOS Version : %@</b><br/>%@<br/><br/><i>We have attached your data as an attachment with this mail, to expedite any data related issues you may be encountering.<br/> You may remove this attachment if it is not relevant with your query.</i><br/> -<b>Simply Auto Support Team<b>", appVersion, iosVersion, userStatus];

    [mailViewController setSubject:@"Error Logs and Data"];
    [mailViewController setToRecipients:recipients];

    [mailViewController setMessageBody:messageBody isHTML:YES];

    mailViewController.navigationBar.tintColor = [UIColor blackColor];

    [mailViewController addAttachmentData:[NSData dataWithContentsOfFile:[self prepareDataFile]]
                                 mimeType:@"text/csv"
                                 fileName:@"Data.csv"];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory
                         stringByAppendingPathComponent:@"console.log"];

    NSString *filename = @"console.log";

    NSData *fileData = [NSData dataWithContentsOfFile:logPath];

    NSString *mimeType = @"log";

    if(fileData != nil){

        [mailViewController addAttachmentData:fileData mimeType:mimeType fileName:filename];
        // Present mail view controller on screen
        if ([MFMailComposeViewController canSendMail]) {
            // Present mail view controller on screen
            [self presentViewController:mailViewController animated:YES completion:NULL];
        }else{

            [self showNoConsoleAlert:@"Mail account not valid or unavailable" message:@"Make sure you have added atleast one valid mail account in Settings > Mail,Contacts,Calendars"];

        }

    }else{

        [self showNoConsoleAlert:@"" message:@"No error log file found"];
    }

}

- (void)showNoConsoleAlert:(NSString *)title message:(NSString *)message {
    
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    

    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(NSString*) prepareDataFile
{
    NSString* str= [self exportAllData];

    // Writing

    //Swapnil ENH_24
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Data.csv"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSError *error;

    if (fileExists)    //Does file exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])   //Delete it
        {
            //  NSLog(@"Delete file error: %@", error);
        }
    }

    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];


    return filePath;

}

-(NSString*)exportAllData
{


    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];

    NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
    //Row ID,Make,Model,Fuel Type,Year,Lic#,Vin,Insurance#,Notes,Picture Path,Vehicle ID,Other Specs
    NSString *firstrow = @"Row ID,Make,Model,Fuel Type,Year,Lic#,Vin,Insurance#,Notes,Picture Path,Vehicle ID,Other Specs";
    [results addObject:firstrow];
    int vehid =0;
    for(Veh_Table *veh in vehicle)
    {
        vehid++;
        //NSString *picture = @"";
        //NSString *vehicleid = [NSString stringWithFormat:@"%@ %@",veh.make,veh.model];
        //NSLog(@"vehid id......%@.....",veh.vehid);
        [results addObject:[NSString stringWithFormat:@"%d,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",vehid,veh.make,veh.model,veh.fuel_type,veh.year,veh.lic,veh.vin,veh.insuranceNo,veh.notes,veh.picture,veh.vehid,veh.customSpecs]];
    }


    //Fuel File


    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];

    NSArray *fuel=[contex executeFetchRequest:requset error:&err1];

    firstrow = @"FRec";
    [results addObject:firstrow];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    int fuelid = 0;
    for (T_Fuelcons * fuelrecord in fuel) {

        NSString *vehid = fuelrecord.vehid;
        //NSString *datestring = [formater stringFromDate:fuelrecord.stringDate];
        [formater setDateFormat:@"dd"];
        NSString *day = [formater stringFromDate:fuelrecord.stringDate];
        [formater setDateFormat:@"MM"];
        NSString *month = [formater stringFromDate:fuelrecord.stringDate];

        [formater setDateFormat:@"yyyy"];
        NSString *year = [formater stringFromDate:fuelrecord.stringDate];
        for(Veh_Table *veh in vehicle)
        {
            if([[veh.iD stringValue] isEqualToString:vehid])
            {
                vehid = veh.vehid;
                break;
            }
        }
        fuelid = fuelid +1;
        NSArray *array1 = [[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"] componentsSeparatedByString:@" "];
        NSString *string1 = [array1 firstObject];
        NSString *eff;
        if ([string1 containsString:@"100"])
        {
            eff = [NSString stringWithFormat:@"%.2f",100/[fuelrecord.cons floatValue]];
        }
        else
        {
            eff =[NSString stringWithFormat:@"%.2f",[fuelrecord.cons floatValue]];
        }
        //Row ID (For System Use),Vehicle ID,Odometer,Qty,Partial Tank,Missed Previous Fill up,Total Cost,Distance Travelled,Eff,Octane,Fuel Brand,Filling Station,Notes,Day,Month,Year,Receipt Path,Latitude,Longitude,Record Type,Record Desc
        [results addObject:[NSString stringWithFormat:@"%d,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",fuelid, vehid, fuelrecord.odo, fuelrecord.qty,[fuelrecord.pfill stringValue],[fuelrecord.mfill stringValue],[fuelrecord.cost stringValue],[fuelrecord.dist stringValue],fuelrecord.cons,[fuelrecord.octane stringValue],fuelrecord.fuelBrand,fuelrecord.fillStation,fuelrecord.notes,day,month,year,fuelrecord.receipt,fuelrecord.latitude,fuelrecord.longitude,[fuelrecord.type stringValue],fuelrecord.serviceType]];
    }




    //Service File

    NSFetchRequest *requset2=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    // [requset2 setPredicate:predicate];

    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSArray *sortDescriptors2 = [[NSArray alloc] initWithObjects:sortDescriptor2, nil];
    [requset2 setSortDescriptors:sortDescriptors2];


    NSArray *servicearray=[contex executeFetchRequest:requset2 error:&err1];

    firstrow = @"ServRec";
    [results addObject:firstrow];
    int serviceid=0;
    for (Services_Table *service in servicearray)
    {

        NSString *vehid = service.vehid;
        //NSLog(@"vehicle id in service....%@....",vehid);

        for(Veh_Table *veh in vehicle)
        {
            //NSLog(@"vehicle id in vehicle...%@....",[veh.iD stringValue]);
            if([[veh.iD stringValue] isEqualToString:vehid])
            {
                vehid = veh.vehid;
                break;
            }
        }

        serviceid = serviceid +1;
        NSString *lastdate = [formater stringFromDate:service.lastDate];
        // NSLog(@"lastdate is %@", lastdate);


        NSTimeInterval unixTimeStamp = 0;

        if (!(lastdate == nil || [lastdate isEqualToString:@"01/01/1970"]))
        {

            NSDate *date = [formater dateFromString:lastdate];
            unixTimeStamp = [date timeIntervalSince1970] * 1000;

        }
        //  NSLog(@"timestamp is %f", unixTimeStamp);

        [results addObject:[NSString stringWithFormat:@"%d,%@,%@,%@,%@,%@,%@,%@,%f",serviceid,vehid,service.type,service.serviceName,service.recurring,service.dueMiles,service.dueDays,service.lastOdo,unixTimeStamp]];
    }


    //Trip File

    NSFetchRequest *requset3=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    //[requset setPredicate:predicate];

    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSArray *sortDescriptors3 = [[NSArray alloc] initWithObjects:sortDescriptor3, nil];
    [requset3 setSortDescriptors:sortDescriptors3];

    NSArray *tripArray=[contex executeFetchRequest:requset3 error:&err1];


    firstrow = @"TripRec";
    [results addObject:firstrow];
    //int tripId=0;
    for (T_Trip *tripRec in tripArray)
    {

        NSString *vehid = tripRec.vehId;
        //NSLog(@"vehicle id in service....%@....",vehid);

        for(Veh_Table *veh in vehicle)
        {
            //NSLog(@"vehicle id in vehicle...%@....",[veh.iD stringValue]);
            if([[veh.iD stringValue] isEqualToString:vehid])
            {
                vehid = veh.vehid;
                break;
            }
        }

        fuelid = fuelid +1;
        //NSString *lastdate = [formater stringFromDate:tripRec.depDate];

        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSInteger depDay = [gregorianCalendar component:NSCalendarUnitDay fromDate:tripRec.depDate];
        NSInteger depMonth = [gregorianCalendar component:NSCalendarUnitMonth fromDate:tripRec.depDate];
        NSInteger depYear = [gregorianCalendar component:NSCalendarUnitYear fromDate:tripRec.depDate];
        NSInteger depHour = [gregorianCalendar component:NSCalendarUnitHour fromDate:tripRec.depDate];
        NSInteger depMin = [gregorianCalendar component:NSCalendarUnitMinute fromDate:tripRec.depDate];
        //   NSInteger depSec = [gregorianCalendar component:NSCalendarUnitSecond fromDate:tripRec.depDate];

        NSInteger arrDay = [gregorianCalendar component:NSCalendarUnitDay fromDate:tripRec.arrDate];
        NSInteger arrMonth = [gregorianCalendar component:NSCalendarUnitMonth fromDate:tripRec.arrDate];
        NSInteger arrYear = [gregorianCalendar component:NSCalendarUnitYear fromDate:tripRec.arrDate];
        NSInteger arrHour = [gregorianCalendar component:NSCalendarUnitHour fromDate:tripRec.arrDate];
        NSInteger arrMin = [gregorianCalendar component:NSCalendarUnitMinute fromDate:tripRec.arrDate];
        // NSInteger arrSec = [gregorianCalendar component:NSCalendarUnitSecond fromDate:tripRec.arrDate];


        // NSLog(@"lastdate is %@", lastdate);


        //        NSTimeInterval unixTimeStamp = 0;
        //
        //        if (!(lastdate == nil || [lastdate isEqualToString:@"01/01/1970"]))
        //        {
        //
        //            NSDate *date = [formater dateFromString:lastdate];
        //            unixTimeStamp = [date timeIntervalSince1970] * 1000;
        //
        //        }
        //  NSLog(@"timestamp is %f", unixTimeStamp);

        //NSString *firstrow = @"%d,%@,Departure Odo,Arrival Odo,Departure Loc,Arrival Loc,Departure Day,Departure Month,Departure Year,Departure Hour,Departure Min,Arrival Day, Arrival Month, Arrival Year, Arrival Hour, Arrival Min, Parking,Toll,Tax Ded,Notes,Trip Type";

        //Row ID,Vehicle ID,Departure Odo,Arrival Odo,Departure Loc,Arrival Loc,Departure Day,Departure Month,Departure Year,Departure Hour,Departure Min,Arrival Day, Arrival Month, Arrival Year, Arrival Hour, Arrival Min, Parking,Toll,Tax Ded,Notes,Departure Latitude,Departure Longitude,Arrival Latitiude,Arrival Longitude,Trip Type

        [results addObject:[NSString stringWithFormat:@"%d,%@,%f,%f,%@,%@,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%@,%@,%@,%@,%@,%@,%@,%@, %@",fuelid,vehid,[tripRec.depOdo floatValue],[tripRec.arrOdo floatValue],tripRec.depLocn, tripRec.arrLocn,(long)depDay,(long)depMonth,(long)depYear,(long)depHour,(long)depMin,(long)arrDay,(long)arrMonth,(long)arrYear,(long)arrHour,(long)arrMin,tripRec.parkingAmt,tripRec.tollAmt,tripRec.taxDedn, tripRec.notes,tripRec.depLatitude,tripRec.depLongitude,tripRec.arrLatitude,tripRec.arrLongitude, tripRec.tripType ]];
    }



    NSString *resultString = [results componentsJoinedByString:@"\n"];
    resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    //NSLog(@"result value %@",vehid)
    return resultString;

}


@end
