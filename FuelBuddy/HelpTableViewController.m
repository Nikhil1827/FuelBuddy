//
//  HelpTableViewController.m
//  FuelBuddy
//
//  Created by Swapnil on 15/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "HelpTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "Veh_Table.h"
#import "T_Fuelcons.h"
#import "T_Trip.h"
#import "Services_Table.h"
#import "FaqViewController.h"
#import "CloudHelpTableVC.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import "SupportViewController.h"

@interface HelpTableViewController ()
{
    NSArray *tableContent;
    NSArray *subtitles;
    UIView *feedBackView;
    UITextView *feedText;
    UITextField *emailField;
    UILabel *emailThisLabel;
    BOOL validEmail;
}
@end

@implementation HelpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.topItem.title= NSLocalizedString(@"help", @"Help");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    self.helpTable.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    [self.helpTable setSeparatorColor:[UIColor darkGrayColor]];
    [self.helpTable setScrollEnabled:NO];
    
    //NSLocalizedString(@"contact_us", @"Contact Us"),
    tableContent = [[NSArray alloc] initWithObjects:NSLocalizedString(@"support", @"Support"),NSLocalizedString(@"faq", @"FAQ"),
                    NSLocalizedString(@"user_guide", @"User guide"),
                    NSLocalizedString(@"cloud_help", @"Cloud Help"),
                    NSLocalizedString(@"feedback", @"Feedback"), nil];
    
    subtitles = [[NSArray alloc] initWithObjects:NSLocalizedString(@"contactDesc", @"Questions? Need help?"),NSLocalizedString(@"faqfull", @"Frequently Asked Questions"),
                 NSLocalizedString(@"user_guide_sub", @"A manual for Simply Auto"),
                 NSLocalizedString(@"cloudHelpTut", @"Tutorial for Simply Auto's cloud functionality"),
                 NSLocalizedString(@"feedback_desc", @"Suggestions. Feature requests."), nil];
    validEmail = NO;
    emailThisLabel.hidden = YES;
}


-(BOOL)shouldAutorotate {
    return NO;
}

-(void)backbuttonclick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view Datasource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return tableContent.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(cell == nil){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [tableContent objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [subtitles objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:18.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.row == 0){

        SupportViewController *supportView = (SupportViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SupportViewController"];

        dispatch_async(dispatch_get_main_queue(), ^{
            supportView.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:supportView animated:YES completion:nil];
        });


    }

    else if(indexPath.row == 1){
       
        FaqViewController *faq = (FaqViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"faq"];
        faq.urlstring = @"https://www.simplyauto.app/faq.php";
        faq.navtitle = NSLocalizedString(@"faq", @"FAQs");
        faq.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:faq animated:YES];
    }
    
    else if(indexPath.row == 2){
        
        FaqViewController *faq = (FaqViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"faq"];
        faq.urlstring = @"https://simplyauto.app/userguide/index.php";
        faq.navtitle = NSLocalizedString(@"user_guide", @"User guide");
        faq.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:faq animated:YES];
    }
    
    else if(indexPath.row == 3){
        
        CloudHelpTableVC *cloudHelp = (CloudHelpTableVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"cloudHelpTableVC"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cloudHelp.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:cloudHelp animated:YES completion:nil];
        });
        
        
    }
    /*
    else if(indexPath.row == 3){
        
        //email file to user
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
        
        [mailViewController setToRecipients:recipients];
        
        [mailViewController setMessageBody:messageBody isHTML:YES];
        
        mailViewController.navigationBar.tintColor = [UIColor blackColor];
        
                //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
                //NSString *csvFilePath = [documentsDirectory stringByAppendingFormat:@"/PhoneUsage.csv"];
        
        [mailViewController addAttachmentData:[NSData dataWithContentsOfFile:[self prepareDataFile]]
                                             mimeType:@"text/csv"
                                             fileName:@"Data.csv"];
        
        if ([MFMailComposeViewController canSendMail]) {
            // Present mail view controller on screen
            [self presentViewController:mailViewController animated:YES completion:NULL];
        }
        else
        {

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail account not valid or unavailable"
                                                                    message:@"Make sure you have added atleast one valid mail account in Settings > Mail,Contacts,Calendars"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
            [alert show];

        }
    
    }
     */
    else if(indexPath.row == 4){
        
        [self createFeedbackScreen];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70.0;
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark Feedback Screen
-(void)createFeedbackScreen{
    
    //FeedBack View
    CGSize screenSize = [self checkIfiPhoneX];
    
    if (screenSize.height == 812.0f){
       feedBackView = [[UIView alloc] initWithFrame:CGRectMake(14, 145, self.helpTable.frame.size.width-28, 380)];
    }else{
        feedBackView = [[UIView alloc] initWithFrame:CGRectMake(14, 105, self.helpTable.frame.size.width-28, 380)];
    }
    
    feedBackView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:feedBackView];
    
    //First Label
    UILabel *feedbackLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 20, 100, 25)];
    feedbackLabel.backgroundColor = UIColor.clearColor;
    
    NSString *text1 = NSLocalizedString(@"feedback", @"Feedback");
    NSMutableAttributedString *attributedText1 = [[NSMutableAttributedString alloc] initWithString:text1];
    [attributedText1 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:NSMakeRange(0, text1.length-2)];
    feedbackLabel.attributedText = attributedText1;
    [feedbackLabel setFont: [feedbackLabel.font fontWithSize: 18]];
    feedbackLabel.textColor = UIColor.whiteColor;
    [feedBackView addSubview:feedbackLabel];
    
    //Second Label
    UILabel *msgStringLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 46, feedBackView.frame.size.width-20, 90)];
    msgStringLabel.backgroundColor = [UIColor clearColor];
    [msgStringLabel setFont: [msgStringLabel.font fontWithSize: 16]];
    msgStringLabel.textColor = UIColor.whiteColor;
    msgStringLabel.numberOfLines = 4;
    msgStringLabel.text = NSLocalizedString(@"feedback_msg", @"Would you like to suggest a feature? Or just drop in a hi!\nWe love to here from our users.");
    [feedBackView addSubview:msgStringLabel];
    
    //Your feedback label
    UILabel *yourFeedback = [[UILabel alloc] initWithFrame:CGRectMake(14, 145, 150, 25)];
    yourFeedback.backgroundColor = [UIColor clearColor];
    [yourFeedback setFont: [yourFeedback.font fontWithSize: 16]];
    yourFeedback.textColor = [UIColor lightGrayColor];
    yourFeedback.text = NSLocalizedString(@"feedback_hint",@"Your feedback");
    [feedBackView addSubview:yourFeedback];
    
    //feedback text
    feedText = [[UITextView alloc] initWithFrame:CGRectMake(14, 170, feedBackView.frame.size.width-20, 45)];
    feedText.delegate = self;
    feedText.keyboardType = UIKeyboardTypeWebSearch;
    feedText.backgroundColor = [UIColor clearColor];
    [feedText setFont:[feedText.font fontWithSize:14]];
    feedText.textColor = [UIColor whiteColor];
    [feedBackView addSubview:feedText];
    
    UIView *feedUnderLine = [[UIView alloc] initWithFrame:CGRectMake(14, 216, feedBackView.frame.size.width-20, 0.65)];
    feedUnderLine.backgroundColor = [UIColor lightGrayColor];
    [feedBackView addSubview:feedUnderLine];
    
    emailThisLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 240,70 ,25)];
    emailThisLabel.backgroundColor = [UIColor clearColor];
    emailThisLabel.textColor = [UIColor lightGrayColor];
    emailThisLabel.text = NSLocalizedString(@"email",@"Email");
    [feedBackView addSubview:emailThisLabel];
    
    emailField = [[UITextField alloc] initWithFrame:CGRectMake(14, 265, feedBackView.frame.size.width-20, 40)];
    emailField.backgroundColor = [UIColor clearColor];
    emailField.textColor = [UIColor whiteColor];
    [emailField setFont:[emailField.font fontWithSize:14]];
    emailField.delegate = self;
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.placeholder = NSLocalizedString(@"feedback_email", @"Email (optional)");
    [feedBackView addSubview:emailField];
    
    UIView *emailUnderLine = [[UIView alloc] initWithFrame:CGRectMake(14, 306, feedBackView.frame.size.width-20, 0.65)];
    emailUnderLine.backgroundColor = [UIColor lightGrayColor];
    [feedBackView addSubview:emailUnderLine];
    
    
    //Send Button
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(feedBackView.frame.size.width-70, feedBackView.frame.size.height-36, 60, 30)];
    sendButton.backgroundColor = [UIColor clearColor];
    [sendButton setTitle:NSLocalizedString(@"send", @"Send") forState: UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [sendButton addTarget:self action:@selector(sendFeedBack) forControlEvents:UIControlEventTouchUpInside];
    [feedBackView addSubview:sendButton];
    
    //Cancel Button
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(sendButton.frame.origin.x-80, feedBackView.frame.size.height-36, 70, 30)];
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton setTitle:NSLocalizedString(@"cancel", @"Cancel") forState: UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
    [feedBackView addSubview:cancelButton];
}

-(void)sendFeedBack{
    
    NSMutableDictionary *sendDict = [[NSMutableDictionary alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if(feedText.text.length > 0){
        
        [sendDict setObject:@"ios" forKey:@"from"];
        [sendDict setObject:feedText.text forKey:@"comment"];
        if(emailField.text.length > 0){
            [sendDict setObject:emailField.text forKey:@"email"];
        }else{
            [sendDict setObject:@"" forKey:@"email"];
        }
        
        NSError *err1;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:&err1];
        commonMethods *common = [[commonMethods alloc] init];
        [def setBool:NO forKey:@"updateTimeStamp"];
        [common saveToCloud:postData urlString:kFeedBackScript success:^(NSDictionary *responseDict) {
            
            // NSLog(@"FeedBack Response:- %@", responseDict);
            
            
        } failure:^(NSError *error) {
            
             // NSLog(@"Error:- %@",err1.localizedDescription);
            
        }];
        
        
        [feedBackView removeFromSuperview];
        [self showAlert:@"" :NSLocalizedString(@"feedback_thanks", @"Thank you for the feedback!")];
        
    }else{
        
        [self showAlert:@"" :NSLocalizedString(@"feedback_msg_empty", @"Please enter a valid message")];
    }
    
}

-(void)cancelPressed{
    
    [feedBackView removeFromSuperview];
}


#pragma mark - UITextView Delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    
    AppDelegate *app = [AppDelegate sharedAppDelegate];
    self.result=app.result;
    
    if(self.result.height==480)
    {
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-180, self.view.frame.size.width, self.view.frame.size.height)];

    }
    else
    {
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-150, self.view.frame.size.width, self.view.frame.size.height)];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {

        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    return YES;
    
}


-(void)textViewDidEndEditing:(UITextView *)textView{
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x,0, self.view.frame.size.width, self.view.frame.size.height)];
    
}


#pragma mark - TextField Methods

-(void)textfieldsetting: (UITextField *)textfield{
    
    //[textfield setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    NSMutableAttributedString *placeholderAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:textfield.attributedPlaceholder];
    [placeholderAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [placeholderAttributedString length])];
    textfield.attributedPlaceholder = placeholderAttributedString;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    AppDelegate *app = [AppDelegate sharedAppDelegate];
    self.result=app.result;
    
    if(self.result.height==480)
    {
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-180, self.view.frame.size.width, self.view.frame.size.height)];
        
    }
    else
    {
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-150, self.view.frame.size.width, self.view.frame.size.height)];
    }
    
    [self paddingTextFields:textField];
    emailThisLabel.hidden = NO;
    emailField.placeholder = @"                                  ";
    textField.returnKeyType = UIReturnKeyDone;
}

- (void) paddingTextFields: (UITextField *)textField{
    
    UIView *padding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4.8, 20)];
    textField.leftView = padding;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField.text.length > 0){
        
        validEmail = [self validateEmail];
        
        if(!validEmail){
            
            NSString *message = NSLocalizedString(@"enter_valid_email",@"Please enter proper email address");
            NSString *title = NSLocalizedString(@"invalid_email",@"Invalid Email");
            [self showAlert:title :message];
            emailField.text = @"";
            emailThisLabel.hidden = YES;
            emailField.placeholder = NSLocalizedString(@"feedback_email", @"Email (optional)");
        }
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason{
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x,0, self.view.frame.size.width, self.view.frame.size.height)];
    if(textField.text.length == 0){
        emailThisLabel.hidden = YES;
        emailField.placeholder = NSLocalizedString(@"feedback_email", @"Email (optional)");
    }else{
        emailThisLabel.hidden = NO;
    }
}

-(void)showAlert:(NSString *)title :(NSString *) message{
    
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

-(BOOL)validateEmail{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if ([emailTest evaluateWithObject:emailField.text] == YES)
    {
        
        return YES;
    }
    else
    {
        
        return NO;
    }
}

-(CGSize)checkIfiPhoneX
{
    CGSize sizeValue;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        sizeValue = screenSize;
    }
    return sizeValue;
}

@end
