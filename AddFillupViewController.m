//
//  AddFillupViewController.m
//  FuelBuddy
//
//  Created by Surabhi on 18/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)

#import "AddFillupViewController.h"
#import "AppDelegate.h"
#import "CustomiseFillupViewController.h"
#import "CustomiseViewController.h"
#import "Veh_Table.h"
#import "T_Fuelcons.h"
#import "UIImage+ResizeImage.h"
#import "Services_Table.h"
#import "JRNLocalNotificationCenter.h"
#import "DashBoardViewController.h"
#import "UITextField+TextPadding.h"
#import "LogViewController.h"
#import "commonMethods.h"
#import <Crashlytics/Crashlytics.h>
#import "LocationServices.h"
#import "Loc_Table.h"
#import "Sync_Table.h"
#import "WebServiceURL's.h"
#import "Reachability.h"
#import "Friends_Table.h"
#import "ReceiptCollectionViewCell.h"
#import "GoProViewController.h"
#import "CheckReachability.h"

@import GoogleMobileAds;
@interface AddFillupViewController () 
{
    float prevOdo;
    NSString* recOrder;
    NSNumber *currentLat;
    NSNumber *currentLongitude;
    //NIKHIL BUG_151
    NSNumber *saveCurLat;
    NSNumber *saveCurLongitude;
    CGFloat oldX;
    CGFloat oldY;
    UIScrollView *scrollview;
    UITextField *currentField;
    CGPoint buttonOrigin;
    int unitType;
    NSString *tempUnit;
    NSString *selectedUnit;
    NSNumber *syncRowID;
    bool sendLocationToServer;
    NSNumber *locSyncRowID;
    NSString *sendLocType;
    BOOL priceFieldEdited;
    BOOL qtyFieldEdited;
    BOOL totalFieldEdited;
}

@property (nonatomic, strong) GADInterstitial *interstitial;
//NIKHIL BUG_131 //added property
@property int selPickerRow;

@end

//Swapnil 15 Mar-17
//static GADMasterViewController *shared;
@implementation AddFillupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    sendLocationToServer = NO;
    priceFieldEdited = false;
    qtyFieldEdited = false;
    totalFieldEdited = false;
    // Do any additional setup after loading the view.
    
    //Requset permission for location access to singleton class
     NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
     BOOL fillLocPopUpShown = [def boolForKey:@"fillLocPopUpShown"];
     if(!fillLocPopUpShown){

         if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
             
             [self showPopUps:NSLocalizedString(@"location_access", @"Need location access to detect filling stations") :NSLocalizedString(@"go_to_settings", @"To re-enable, please go to Settings and turn on Location Service for this app.")];
             
         }else if(![CLLocationManager locationServicesEnabled] || !([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)){
             
     
               [[LocationServices sharedInstance].locationManager requestWhenInUseAuthorization];

         }
         [def setBool:YES forKey:@"fillLocPopUpShown"];
     }
    self.interstitial = [self createAndLoadInterstitial];
    
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odovalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odofilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datevalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"notefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"recordfilter"];
    self.topview.backgroundColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    counter =4;

    [[NSUserDefaults standardUserDefaults]setObject:@"yes" forKey:@"reloadtext"];
    [[NSUserDefaults standardUserDefaults]setObject:@"no" forKey:@"reloaddata"];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]!=nil)
    {
     
        self.navigationController.navigationBar.topItem.title=NSLocalizedString(@"edit_fill_up_header", @"edit fillup");
        
        
        self.details = [[[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]mutableCopy];
        //NSLog(@"self.details :- %@",self.details);
    }
    [self fetchdata];
    
    //DashBoardViewController* dvc = [[DashBoardViewController alloc] init];
    [self fetchAvgDist:NSLocalizedString(@"graph_date_range_0", @"All Time")];
    //ENH_57
    self.receiptImageArray = [[NSMutableArray alloc]init];
    self.unitPickerArray = [[NSMutableArray alloc]initWithObjects:NSLocalizedString(@"disp_litre", @"Litre"),NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)"),NSLocalizedString(@"disp_gal_us", @"Gallon (US)"), nil];
    selectedUnit = @"0";

    self.currencyPickerArray = [[NSMutableArray alloc]initWithObjects:@"U.S. Dollar - USD",
                                @"Canadian dollar - CAD",
                                @"British pound - GBP",
                                @"European euro - EUR",
                                @"Australian dollar - AUD",
                                @"Russian ruble - RUB",
                                @"Indian rupee - INR",
                                @"Brazilian real - BRL",
                                @"Czech koruna - CZK",
                                @"Bulgarian lev - BGN",
                                @"Thai baht - THB",
                                @"Slovak koruna - SKK",
                                @"Saudi riyal - SAR",
                                @"Afghan afghani - AFN",
                                @"Albanian lek - ALL",
                                @"Algerian dinar - DZD",
                                @"Angolan kwanza - AOA",
                                @"Argentine peso - ARS",
                                @"Armenian dram - AMD",
                                @"Aruban florin - AWG",
                                @"Azerbaijani manat - AZN",
                                @"Bahamian dollar - BSD",
                                @"Bahraini dinar - BHD",
                                @"Bangladeshi taka - BDT",
                                @"Barbadian dollar - BBD",
                                @"Belarusian ruble - BYR",
                                @"Belize dollar - BZD",
                                @"Bhutanese ngultrum - BTN",
                                @"Bolivian boliviano - BOB",
                                @"Bosnia and Herzegovina konvertibilna marka - BAM",
                                @"Botswana pula - BWP",
                                @"Brunei dollar - BND",
                                @"Burundi franc - BIF",
                                @"Cambodian riel - KHR",
                                @"Cape Verdean escudo - CVE",
                                @"Cayman Islands dollar - KYD",
                                @"Central African CFA franc - XAF",
                                @"Central African CFA franc - GQE",
                                @"CFP franc - XPF",
                                @"Chilean peso - CLP",
                                @"Chinese renminbi - CNY",
                                @"Colombian peso - COP",
                                @"Comorian franc - KMF",
                                @"Congolese franc - CDF",
                                @"Costa Rican colon - CRC",
                                @"Croatian kuna - HRK",
                                @"Cuban peso - CUC",
                                @"Danish krone - DKK",
                                @"Djiboutian franc - DJF",
                                @"Dominican peso - DOP",
                                @"East Caribbean dollar - XCD",
                                @"Egyptian pound - EGP",
                                @"Eritrean nakfa - ERN",
                                @"Estonian kroon - EEK",
                                @"Ethiopian birr - ETB",
                                @"Falkland Islands pound - FKP",
                                @"Fijian dollar - FJD",
                                @"Gambian dalasi - GMD",
                                @"Georgian lari - GEL",
                                @"Ghanaian cedi - GHS",
                                @"Gibraltar pound - GIP",
                                @"Guatemalan quetzal - GTQ",
                                @"Guinean franc - GNF",
                                @"Guyanese dollar - GYD",
                                @"Haitian gourde - HTG",
                                @"Honduran lempira - HNL",
                                @"Hong Kong dollar - HKD",
                                @"Hungarian forint - HUF",
                                @"Icelandic krona - ISK",
                                @"Indonesian rupiah - IDR",
                                @"Iranian rial - IRR",
                                @"Iraqi dinar - IQD",
                                @"Israeli new sheqel - ILS",
                                @"Jamaican dollar - JMD",
                                @"Japanese yen - JPY",
                                @"Jordanian dinar - JOD",
                                @"Kazakhstani tenge - KZT",
                                @"Kenyan shilling - KES",
                                @"Kuwaiti dinar - KWD",
                                @"Kyrgyzstani som - KGS",
                                @"Lao kip - LAK",
                                @"Latvian lats - LVL",
                                @"Lebanese lira - LBP",
                                @"Lesotho loti - LSL",
                                @"Liberian dollar - LRD",
                                @"Libyan dinar - LYD",
                                @"Lithuanian litas - LTL",
                                @"Macanese pataca - MOP",
                                @"Macedonian denar - MKD",
                                @"Malagasy ariary - MGA",
                                @"Malawian kwacha - MWK",
                                @"Malaysian ringgit - MYR",
                                @"Maldivian rufiyaa - MVR",
                                @"Mauritanian ouguiya - MRO",
                                @"Mauritian rupee - MUR",
                                @"Mexican peso - MXN",
                                @"Moldovan leu - MDL",
                                @"Mongolian tugrik - MNT",
                                @"Moroccan dirham - MAD",
                                @"Mozambican metical - MZM",
                                @"Myanma kyat - MMK",
                                @"Namibian dollar - NAD",
                                @"Nepalese rupee - NPR",
                                @"Netherlands Antillean gulden - ANG",
                                @"New Taiwan dollar - TWD",
                                @"New Zealand dollar - NZD",
                                @"Nicaraguan cordoba - NIO",
                                @"Nigerian naira - NGN",
                                @"North Korean won - KPW",
                                @"Norwegian krone - NOK",
                                @"Omani rial - OMR",
                                @"Paanga - TOP",
                                @"Pakistani rupee - PKR",
                                @"Panamanian balboa - PAB",
                                @"Papua New Guinean kina - PGK",
                                @"Paraguayan guarani - PYG",
                                @"Peruvian nuevo sol - PEN",
                                @"Philippine peso - PHP",
                                @"Polish zloty - PLN",
                                @"Qatari riyal - QAR",
                                @"Romanian leu - RON",
                                @"Rwandan franc - RWF",
                                @"Saint Helena pound - SHP",
                                @"Samoan tala - WST",
                                @"Sao Tome and Principe dobra - STD",
                                @"Serbian dinar - RSD",
                                @"Seychellois rupee - SCR",
                                @"Sierra Leonean leone - SLL",
                                @"Singapore dollar - SGD",
                                @"Solomon Islands dollar - SBD",
                                @"Somali shilling - SOS",
                                @"South African rand - ZAR",
                                @"South Korean won - KRW",
                                @"Special Drawing Rights - XDR",
                                @"Sri Lankan rupee - LKR",
                                @"Sudanese pound - SDG",
                                @"Surinamese dollar - SRD",
                                @"Swazi lilangeni - SZL",
                                @"Swedish krona - SEK",
                                @"Swiss Franc - CHF",
                                @"Syrian pound - SYP",
                                @"Tajikistani somoni - TJS",
                                @"Tanzanian shilling - TZS",
                                @"Trinidad and Tobago dollar - TTD",
                                @"Tunisian dinar - TND",
                                @"Turkish new lira - TRY",
                                @"Turkmen manat - TMM",
                                @"UAE dirham - AED",
                                @"Ugandan shilling - UGX",
                                @"Ukrainian hryvnia - UAH",
                                @"Uruguayan peso - UYU",
                                @"Uzbekistani som - UZS",
                                @"Vanuatu vatu - VUV",
                                @"Venezuelan bolivar - VEB",
                                @"Vietnamese dong - VND",
                                @"West African CFA franc - XOF",
                                @"Yemeni rial - YER",
                                @"Zambian kwacha - ZMK",
                                @"Zimbabwean dollar - ZWD",
                                nil];
}

//Nikhil if denied goto settings
-(void)showPopUps:(NSString *)tite :(NSString *)message{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:tite message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

}

//Added to ask user to GoPro 30may2018 nikhil
- (void)goProAlertBox{
    
    NSString *title = NSLocalizedString(@"multi_recpt_title", @"Attach Multiple Receipts");
    NSString *message = NSLocalizedString(@"multi_recpt_msg", @"Attaching multiple receipts is only available in the pro version");
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"cancel", @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    
    //NSString *go_pro_btn = @"Go Pro";
    UIAlertAction *goproAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"go_pro_btn", @"Ok action")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          gopro.modalPresentationStyle = UIModalPresentationFullScreen;
                                          [self presentViewController:gopro animated:YES completion:nil];
                                      });
                                  }];
    
    
    [alertController addAction:goproAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (GADInterstitial *)createAndLoadInterstitial{
    
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-6674448976750697/6378475565"];
    interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    [interstitial loadRequest:request];
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    
    self.interstitial = [self createAndLoadInterstitial];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    //NIKHIL BUG_125 
    //To scroll contentview when keyboard appears
    [self registerForKeyboardNotifications];
    
    //[self fetchallfillup];
    [self fetchprevfuel];
    
    //NSString *add_fill_up_header = @"Add Fillup";
    self.navigationItem.title=[NSLocalizedString(@"add_fill_up_header", @"add fillup") capitalizedString];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]!=nil)
    {
        //Editdata *e = [[Editdata alloc]init];
        //NSString *edit_fill_up_header = @"Edit Fillup";
        self.navigationController.navigationBar.topItem.title=NSLocalizedString(@"edit_fill_up_header", @"edit fillup");
    }//top , left, bottom, right
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 20.0, buttonImage.size.width+4,buttonImage.size.height+4);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];

    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    self.textplace =[[NSMutableArray alloc]initWithArray:[[def arrayForKey:@"arrayvalue"] mutableCopy]];
    //Swapnil BUG_91
    if([self.textplace containsObject: @"Attach reciept"]){
        NSInteger index = [self.textplace indexOfObject:@"Attach reciept"];
        [self.textplace replaceObjectAtIndex:index withObject:@"Attach receipt"];
    }
    if(self.textplace.count==0)
    {
        self.textplace=[[NSMutableArray alloc]initWithObjects:
                        @"Select",
                        NSLocalizedString(@"date", @"Date"),
                        NSLocalizedString(@"odometer", @"Odometer"),
                        NSLocalizedString(@"qty_required", @"Qty"),
                        NSLocalizedString(@"pf_tv", @"Partial Tank"),
                        NSLocalizedString(@"mf_tv", @"Missed Previous Fill up"),
                        NSLocalizedString(@"prc_per_unt", @"Price/Unit"),
                        NSLocalizedString(@"tc_tv", @"Total Cost"),
                        NSLocalizedString(@"octane", @"Octane"),
                        NSLocalizedString(@"fb_tv", @"Fuel Brand"),
                        NSLocalizedString(@"fs_tv", @"Filling station"),
                        NSLocalizedString(@"notes_tv", @"Notes"),
                        NSLocalizedString(@"attach_receipt", @"Attach receipt"),nil];
    }
    else if(self.textplace.count==11)
    {
        self.textplace=[[NSMutableArray alloc]initWithObjects:
                        @"Select",
                        NSLocalizedString(@"date", @"Date"),
                        NSLocalizedString(@"odometer", @"Odometer"),
                        NSLocalizedString(@"qty_required", @"Qty"),
                        NSLocalizedString(@"pf_tv", @"Partial Tank"),
                        @"",
                        NSLocalizedString(@"prc_per_unt", @"Price/Unit"),
                        NSLocalizedString(@"tc_tv", @"Total Cost"),
                        NSLocalizedString(@"octane", @"Octane"),
                        NSLocalizedString(@"fb_tv", @"Fuel Brand"),
                        NSLocalizedString(@"fs_tv", @"Filling station"),
                        NSLocalizedString(@"notes_tv", @"Notes"),
                        NSLocalizedString(@"attach_receipt", @"Attach receipt"),nil];
    }
    else
    {
        [self.textplace insertObject:@"Select" atIndex:0];
        
    }
    
  if([[[NSUserDefaults standardUserDefaults]objectForKey:@"reloadtext"]isEqualToString:@"yes"])
  {
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,0, self.view.frame.size.width, self.view.frame.size.height)];
        self.automaticallyAdjustsScrollViewInsets=NO;
        [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        [self addtext];
        
        //[[NSUserDefaults standardUserDefaults]setObject:@"yes" forKey:@"reloaddata"];
        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"copyvalues"]isEqualToString:@"copy"])
        {
            [self fetchfillup];
            
        }
   

    if([[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]!=nil)
    {
        //Editdata *e = [[Editdata alloc]init];
        
        
        // self.details = [[[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]mutableCopy];
        // NSLog(@"edit details %@",self.details);
        UITextField *text1 = [self.view viewWithTag:1]; //Date
        UITextField *text2 = [self.view viewWithTag:2]; //ODO
        UITextField *text3 = [self.view viewWithTag:3]; //QTY
        UITextField *text5 = [self.view viewWithTag:6]; //Price
        //[text5 addTarget:self action:@selector(myTextFieldDidChange) forControlEvents:UIControlEventTouchUpInside];
        UITextField *text6 = [self.view viewWithTag:7]; //COST
        UITextField *text7 = [self.view viewWithTag:8]; //octane
        UITextField *text8 = [self.view viewWithTag:9]; //brand
        UITextField *text9 = [self.view viewWithTag:10]; //filling
        UITextView *text10 = [self.view viewWithTag:12]; //notes
        
        // UILabel *label1 = [self.view viewWithTag:20];
        UILabel *label2 = [self.view viewWithTag:40];
        UILabel *label3 = [self.view viewWithTag:60];
        UILabel *label5 = [self.view viewWithTag:120];
        UILabel *label6 = [self.view viewWithTag:140];
        UILabel *label7 = [self.view viewWithTag:160];
        UILabel *label8 = [self.view viewWithTag:180];
        UILabel *label9 = [self.view viewWithTag:200];
        //UILabel *label10 = [self.view viewWithTag:220];
        //NSLog(@"details : %@", self.details);
        NSDateFormatter *f=[[NSDateFormatter alloc] init];
        [f setDateFormat:@"dd-MMM-yyyy"];
        NSDate *date = [f dateFromString:[self.details objectForKey:@"date"]];
        
        text1.text=[f stringFromDate:date];
        NSUserDefaults *Def = [NSUserDefaults standardUserDefaults];
        //Changed the object type bcuz it is causing langaue issues
//        if([[Def objectForKey:@"filluptype"]isEqualToString:NSLocalizedString(@"trp", @"Trip")]){
//            text2.text = [[self.details objectForKey:@"distance"]stringValue];
//        }
        if([[Def objectForKey:@"filluptype"]isEqualToString:@"Trip"]){
            text2.text = [[self.details objectForKey:@"distance"]stringValue];
        }
        else {
            text2.text = [[self.details objectForKey:@"odo"]stringValue];
        }
        
        //NSLog(@"value of %@",[[self.details objectForKey:@"distance"]stringValue]);
        text3.text = [[self.details objectForKey:@"qty"]stringValue];
        if([[self.details objectForKey:@"cost"]floatValue]!=0)
        {
            text6.text = [NSString stringWithFormat:@"%.2f",[[self.details objectForKey:@"cost"]floatValue]];
            
            NSString *str=[NSString stringWithFormat:@"%.2f",[[self.details objectForKey:@"cost"]floatValue]/[[self.details objectForKey:@"qty"]floatValue]];
            NSArray *arr=[[NSArray alloc]init];
            NSMutableArray *arr1 = [[NSMutableArray alloc]init];
            arr = [str componentsSeparatedByString:@"."];
            int temp=[[arr lastObject] intValue];
            // NSLog(@"temp value %@",arr);
            NSString *decimalval = [NSString stringWithFormat:@"%d",temp];
            for(int i=0;i<decimalval.length;i++)
            {
                [arr1 addObject:[NSString stringWithFormat:@"%c",[decimalval characterAtIndex:i]]];
            }
            //text5.text = [NSString stringWithFormat:@"%.3f", [[self.details objectForKey:@"cost"]floatValue]/[[self.details objectForKey:@"qty"]floatValue]];
            
            //NIKHIL BUG_124  //Changed format F 2f T 3f
            if([[arr1 lastObject]intValue]!=0)
            {
                text5.text = [NSString stringWithFormat:@"%.3f",[[self.details objectForKey:@"cost"]floatValue]/[[self.details objectForKey:@"qty"]floatValue]];
            }
            
            else
            {
                
                text5.text = [NSString stringWithFormat:@"%.3f",[[self.details objectForKey:@"cost"]floatValue]/[[self.details objectForKey:@"qty"]floatValue]];
            }
            
            
        }
        text7.text = [[self.details objectForKey:@"octane"]stringValue];
        text8.text = [self.details objectForKey:@"brand"];
        text9.text = [self.details objectForKey:@"filling"];
        text10.text = [self.details objectForKey:@"notes"];
        
        if(text2.text.length != 0)
        {
            [self paddingTextFields:text2];
            [self labelanimatetoshow:label2];
        }
        
        if(text3.text.length != 0)
        {
            [self paddingTextFields:text3];
            [self labelanimatetoshow:label3];
        }
        
        if(text5.text.length != 0)
        {
            [self paddingTextFields:text5];
            [self labelanimatetoshow:label5];
        }
        
        if(text6.text.length != 0)
        {
            [self paddingTextFields:text6];
            [self labelanimatetoshow:label6];
        }
        
        if(text7.text.length != 0)
        {
            [self paddingTextFields:text7];
            [self labelanimatetoshow:label7];
        }
        
        if(text8.text.length != 0)
        {
            [self paddingTextFields:text8];
            [self labelanimatetoshow:label8];
        }
        
        if(text9.text.length != 0)
        {
            [self paddingTextFields:text9];
            [self labelanimatetoshow:label9];
        }
        
        
        UIButton *button  = (UIButton *)[self.view viewWithTag:1000];
        
        if([[self.details objectForKey:@"partial"]integerValue]==1)
        {
            button.selected=YES;
            
        }
        
        else
        {
            button.selected =NO;
        }
        
        UIButton *mbutton  = (UIButton *)[self.view viewWithTag:2000];
        
        if([[self.details objectForKey:@"mfill"]integerValue]==1)
        {
            mbutton.selected=YES;
            //NSLog(@"in mfill");
        }
        
        else
        {
            mbutton.selected =NO;
        }
        
        
        //NSLog(@"self.details:- %@",self.details);
        NSString *emptyString = @"";
        if([self.details objectForKey:@"receipt"] !=nil && ![[self.details objectForKey:@"receipt"] isEqualToString:emptyString])
        {
            NSString *imageString = [self.details objectForKey:@"receipt"];
            NSArray *separatedPaths = [imageString componentsSeparatedByString:@":::"];
            [self.receiptImageArray addObjectsFromArray:separatedPaths];
            //NSLog(@"self.receiptImageArray:- %@",self.receiptImageArray);
            [self.receiptCollectionView reloadData];
        }
    }
  }
    //NIKHIL BUG_150
   // [self fetchCurrentLocation];
    [self.receiptCollectionView reloadData];
}


-(void)viewDidAppear:(BOOL)animated
{
    [self createPageVC];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", @"Save") style:UIBarButtonItemStylePlain target:self action:@selector(savefillup)];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    UITextField *text2 = [self.view viewWithTag:2]; //ODO
    UITextField *text3 = [self.view viewWithTag:3]; //QTY
    UITextField *text5 = [self.view viewWithTag:6]; //Price
   // [text5 addTarget:self action:@selector(myTextFieldDidChange) forControlEvents:UIControlEventTouchUpInside];
    UITextField *text6 = [self.view viewWithTag:7]; //COST
    UITextField *text7 = [self.view viewWithTag:8]; //octane
    UITextField *text8 = [self.view viewWithTag:9]; //brand
    UITextField *text9 = [self.view viewWithTag:10]; //filling
    
    if(text2.text.length != 0){
        [self paddingTextFields:text2];
    }
    if(text3.text.length != 0){
        [self paddingTextFields:text3];
    }
    if(text5.text.length != 0){
        [self paddingTextFields:text5];
    }
    if(text6.text.length != 0){
        [self paddingTextFields:text6];
    }
    if(text7.text.length != 0){
        [self paddingTextFields:text7];
    }
    if(text8.text.length != 0){
        [self paddingTextFields:text8];
    }
    if(text9.text.length != 0){
        [self paddingTextFields:text9];
    }
    
    //NIKHIL BUG_150
    // Copied code from here to make new function::fetchCurrentLocation
    //NIKHIL BUG_150 once again let it run here
    //to get exact location atlst once 26march2018
    [self fetchCurrentLocation];
    
}


//NIKHIL BUG_150
-(void)fetchCurrentLocation{
    
    //Swapnil ENH_11
     NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    
    //check if auto detect locn checkmark is checked, permission to access locn is granted and location services are enabled
    if([[def objectForKey:@"autoDetectLoc"]  isEqual: @"YES"] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager locationServicesEnabled]))){
        
        //Request current location
        [[LocationServices sharedInstance].locationManager requestLocation];
        
        //Get latest locn in currentLocation
        CLLocation *currentLocation = [LocationServices sharedInstance].latestLoc;
        
        //Converting lat, long to 3 decimals only
        //NIKHIL BUG_151
        //        NSString *latString = [NSString stringWithFormat:@"%.3f", currentLocation.coordinate.latitude];
        //        NSString *longiString = [NSString stringWithFormat:@"%.3f", currentLocation.coordinate.longitude];
      
        if(currentLocation == nil){

            currentLocation = [[NSUserDefaults standardUserDefaults]objectForKey:@"currentLocationFromAppDelegate"];
        }
        NSNumberFormatter *lformatter = [NSNumberFormatter new];
        [lformatter setRoundingMode:NSNumberFormatterRoundFloor];
        [lformatter setMaximumFractionDigits:3];
        [lformatter setPositiveFormat:@"0.###"];
        NSString *latString = [lformatter stringFromNumber: [NSNumber numberWithDouble: currentLocation.coordinate.latitude]];
        NSString *longiString = [lformatter stringFromNumber: [NSNumber numberWithDouble: currentLocation.coordinate.longitude]];
       
        double latValue = [latString doubleValue];
        double longitudeValue = [longiString doubleValue];
        
        currentLat = [NSNumber numberWithDouble:latValue];
        currentLongitude = [NSNumber numberWithDouble:longitudeValue];
        //Mention changes in Sheet
        //NIKHIL BUG_151
        saveCurLat = [NSNumber numberWithDouble: currentLocation.coordinate.latitude];
        saveCurLongitude = [NSNumber numberWithDouble: currentLocation.coordinate.longitude];
        
        //NSLog(@"currentLat ::%@,  currentLongitude::%@,   saveCurLat::%@,  saveCurLongitude::%@",currentLat,currentLongitude,saveCurLat,saveCurLongitude);
        //Accessing Loc_Table from DB
        NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
        NSError *err;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
        
        NSArray *locationArray = [[NSArray alloc] init];
        locationArray = [context executeFetchRequest:request error:&err];
        
        //NSLog(@"locArr : %@", locationArray);
        
        //First set locFound to NO
        BOOL locFound = NO;
        
        if(![currentLat  isEqual: @0.0] && ![currentLongitude isEqual:@0.0]){
            
            //Loop thr' each record in Loc_Table
            for (Loc_Table *location in locationArray) {
                NSString *latString = [lformatter stringFromNumber: location.lat];
                NSString *longiString = [lformatter stringFromNumber: location.longitude];
                location.lat = [NSNumber numberWithDouble:[latString doubleValue]];
                location.longitude = [NSNumber numberWithDouble:[longiString doubleValue]];
                
                //Check if current lat, long is present in that record of Loc_Table
                
                if([currentLat floatValue] == [location.lat floatValue] && [currentLongitude floatValue] == [location.longitude floatValue]){
                    
                    //If present, set locFound to YES
                    locFound = YES;
                    
                    //Extract brand and address from Loc_Table for matching coordinates and set to fuelbrand and filling station
                   // UITextField *fuelbrand = (UITextField *)[self.view viewWithTag:9];
                    UITextField *filling = (UITextField *) [self.view viewWithTag:10];
                    
//                    if(fuelbrand.text.length == 0){
//                        fuelbrand.text = location.brand;
//                    }
                    if(filling.text.length == 0){
                        filling.text = location.address;
                    }
                    break;
                } else {
                    
                    //Set locFound to NO
                    locFound = NO;
                }
            }
        }
        
        //current lat, long not present in Loc_Table
        //NIKHIL 10Dec2019 made google places for Pro version

        BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];

        if(proUser){

            if(![currentLat  isEqual: @0.0] && ![currentLongitude isEqual:@0.0] && currentLat){

                //Hit query to google places api to find nearest gas station around 500m
                NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=500&types=gas_station&sensor=true&key=AIzaSyAT6PGoESv5KtMC8Tu13LOB5NRXseCOYHk",
                                       currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
                NSURL *googleRequestUrl = [NSURL URLWithString:urlString];

                // dispatch_async(kBgQueue, ^{
                NSData* data = [NSData dataWithContentsOfURL:googleRequestUrl];
                [self performSelectorOnMainThread:@selector(placesFetchedData:) withObject:data waitUntilDone:YES];
                // });

            }
        }
        
    }
    
}

//Swapnil ENH_11
- (void)placesFetchedData: (NSData *)responseData{
    
    //Parsing Json response from places api
    NSError *error;
    NSArray *places = [[NSArray alloc] init];
    if(responseData != nil){
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        //NSLog(@"data : %@", dataDictionary);
        places = [dataDictionary objectForKey:@"results"];
    }
    //NSLog(@"places : %@", places);
    
    if(places.count != 0){
        
       // NSString *fuelBrandName = [[places firstObject] objectForKey:@"name"];
        NSString *fillStation = [[places firstObject] objectForKey:@"name"];
        
        //NSLog(@"FB : %@", fuelBrandName);
        //NSLog(@"fill station : %@", fillStation);
        
       // UITextField *fuelBrand = (UITextField *)[self.view viewWithTag:9];
        UITextField *filling = (UITextField *) [self.view viewWithTag:10];
        
        //Populate filling station and fuelBrand thr' places api
        
        
       // NSString *StringFuelVal = [fuelBrandName stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSString *StringFillVal = [fillStation stringByReplacingOccurrencesOfString:@"," withString:@""];
    
        filling.text = StringFillVal;
       // fuelBrand.text = StringFuelVal;
        
    }
    
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
    //[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]!=nil
    //    NSLog(@"user default %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"reloaddata"]);
    //    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"reloaddata"]isEqualToString:@"yes"])
    //    {
    //    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
    //    //[[NSUserDefaults standardUserDefaults]setObject:@"yes" forKey:@"reloaddata"];
    //
    //    }
    
    
}


-(void)fetchAvgDist :(NSString *) filterstring
{

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    
    NSArray *datavaluefilter = [[NSArray alloc]init];
    NSMutableArray *datavalue= [[NSMutableArray alloc]init];
    datavaluefilter =[contex executeFetchRequest:requset error:&err];
    
    if([filterstring isEqualToString:NSLocalizedString(@"graph_date_range_0", @"All Time")])
    {
        
        datavalue = [[NSMutableArray alloc]initWithArray:datavaluefilter];
    }
    
    NSString *distance;
    
    T_Fuelcons *maxodo = [datavalue lastObject];
    T_Fuelcons *minodo = [datavalue firstObject];
    
    [[NSUserDefaults standardUserDefaults] setObject:maxodo.odo forKey:@"TopOdo"];
    
    distance = [NSString stringWithFormat:@"%.2f",[maxodo.odo floatValue] - [minodo.odo floatValue]];
    
    int fillupno=0;
    
    NSMutableArray *dataval = [[NSMutableArray alloc]init];
    
    NSMutableArray* filluparray = [[NSMutableArray alloc]init];
    //NSLog(@"comp %d",comp.day);
    for(T_Fuelcons *fillup in datavalue)
    {
        if([fillup.type integerValue]==0)
        {
            [dataval addObject:fillup];
            [filluparray addObject:fillup];
        }
        
    }
    fillupno = (int)dataval.count;
    float qty=0.0;
    float cost =0.0;
    float dist=0.0;
    int filluprecord = 0;
    
    
    
    // NSLog(@"max date %@",[formater1 stringFromDate:maxdate]);
    //NSLog(@"min date %@",[formater1 stringFromDate:mindate]);
    
    
    for(T_Fuelcons *fillup in dataval)
    {
        qty = qty + [fillup.qty floatValue];
        cost = cost + [fillup.cost floatValue];
        dist = dist + [fillup.dist floatValue];
        if([fillup.dist floatValue]!=0)
        {
            filluprecord =filluprecord+1;
        }
        
    }
    
    //Start
    // self.avgfuelstat = [[NSMutableArray alloc] init];
    if(dist!=0)
    {
        
        float disteffperqty=0.0;
        disteffperqty = dist/filluprecord;
        NSString *str1=[NSString stringWithFormat:@"%.2f",disteffperqty];
        NSArray *arr2=[[NSArray alloc]init];
        arr2 = [str1 componentsSeparatedByString:@"."];
        int temp=[[arr2 lastObject] intValue];
        NSString *decimalval1 = [NSString stringWithFormat:@"%d",temp];
        if(temp==0)
        {
            // add NSUserDefaults here
            [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",(int)ceilf(disteffperqty)] forKey:@"AvgDistance"];
            
        }
        
        else if(![[decimalval1 substringFromIndex:1]isEqualToString:@"0"])
        {
            [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%.2f",dist/filluprecord] forKey:@"AvgDistance"];
        }
        
        else
        {
            [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%.1f",dist/filluprecord] forKey:@"AvgDistance"];
        }
        
    }
    
}

//Edited to use Sorted log for Odo Check.
//new_7  2018may
-(void)editfillup
{
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSMutableDictionary *forFriendDict = [[NSMutableDictionary alloc]init];
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    //BUG_177 Nikhil For carChange
    NSString *oldComapreString = [NSString stringWithFormat:@"%@",[Def objectForKey:@"oldFillupid"]];
    
    
    //NSLog(@"compareString:::%@",comparestring);
    //NSLog(@"self.details array has old values:- %@",self.details);
    NSString* oldOdo =[self.details objectForKey:@"odo"];
    if(oldOdo != nil){
        [forFriendDict setObject:oldOdo forKey:@"oldOdo"];
    }else{
        [forFriendDict setObject:@"" forKey:@"oldOdo"];
    }
    
    NSString *oldServiceType = [self.details objectForKey:@"service"];
    if(oldServiceType != nil){
        [forFriendDict setObject:oldServiceType forKey:@"oldServiceType"];
    }else{
        [forFriendDict setObject:@"" forKey:@"oldServiceType"];
    }
    
    NSString* oldDateStr =[self.details objectForKey:@"date"];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    NSDate *oldDate =[formater dateFromString:oldDateStr];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    //BUG_177 replaced campareString with oldcamparestring
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ and type = 0 and odo = %@ and stringDate = %@",oldComapreString, oldOdo, oldDate];
    [requset setPredicate:predicate];
    
    NSArray *dataArray=[contex executeFetchRequest:requset error:&err];
    T_Fuelcons *updRecord = [dataArray firstObject];
    
    NSArray *datavalue=[[NSUserDefaults standardUserDefaults] objectForKey:@"SortedLog"];
    //NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    //[formater setDateFormat:@"dd/MM/yyyy"];
    
    //TO get vehid
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %i",[comparestring intValue]];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
    
    Veh_Table *vehicleData = [vehData firstObject];
    NSString *vehid = vehicleData.vehid;
    //NSLog(@"gadiname:- %@",vehid);
    //till here
    
    if([Def objectForKey:@"UserEmail"]){
        [forFriendDict setObject:[Def objectForKey:@"UserEmail"] forKey:@"email"];
        [forFriendDict setObject:[Def objectForKey:@"UserName"] forKey:@"name"];
    }
    [forFriendDict setObject:@"update" forKey:@"action"];
    if(updRecord.iD != nil){
        [forFriendDict setObject:updRecord.iD forKey:@"id"];
    }
    syncRowID = updRecord.iD;
    
    NSDateFormatter *f=[[NSDateFormatter alloc] init];
    [f setDateFormat:@"dd-MMM-yyyy"];
    
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    UITextField *qty = (UITextField *)[self.view viewWithTag:3];
    UITextField *date = (UITextField *)[self.view viewWithTag:1];
    UITextField *price = (UITextField *)[self.view viewWithTag:7];
    UITextField *octane = (UITextField *)[self.view viewWithTag:8];
    UITextField *fuel = (UITextField *)[self.view viewWithTag:9];
    UITextField *filling = (UITextField *)[self.view viewWithTag:10];
    UITextView *notes = (UITextView *)[self.view viewWithTag:12];
    UILabel *priceUnitLabel = (UILabel *)[self.view viewWithTag:13];
    UILabel *totalUnitLabel = (UILabel *)[self.view viewWithTag:14];
    //if Odo or Date has been changed, Check if Odo is valid
    NSDictionary *prevrecord, *nextrecord;
    float nextodo = 0;
    
    //Swapnil BUG_77
    if(odometer.text.length!=0 && qty.text.length!=0 && date.text.length!=0 && [qty.text floatValue] != 0 && [odometer.text floatValue] != 0)
    {
        //Changed the object type bcuz it is causing langaue issues
        //if ([[Def objectForKey:@"filluptype"]isEqualToString:NSLocalizedString(@"trp", @"Trip")])
        if ([[Def objectForKey:@"filluptype"]isEqualToString:@"Trip"])
        {
            //Swapnil BUG_69
            NSPredicate *tripDistPredicate = [NSPredicate predicateWithFormat:@"type == 0"];
            NSArray *tripDistArray = [datavalue filteredArrayUsingPredicate:tripDistPredicate];
            
            int k = [[self.details objectForKey:@"valueindex"]intValue];
            
            if(tripDistArray.count !=1 && k!=0)
            {
                nextrecord = [datavalue objectAtIndex:k-1];
                nextodo  = [[nextrecord objectForKey:@"odo" ] floatValue];
            }
            else
            {
                nextodo = [odometer.text floatValue];
            }
            
            if(tripDistArray.count>k+1)
            {
                prevrecord = [tripDistArray objectAtIndex:k+1];
                prevOdo = [[prevrecord objectForKey:@"odo" ] floatValue];
            }
            
            else
            {
                prevOdo = [odometer.text floatValue];
            }
            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"dd/MM/yyyy"];
      
            NSDate *formatteddate =[formater dateFromString:date.text];
            
            if(tripDistArray.count >1 && k!=tripDistArray.count-1){
                updRecord.odo =@([odometer.text floatValue]+prevOdo);
                if(updRecord.odo != nil){
                    [forFriendDict setObject:updRecord.odo forKey:@"odo"];
                }else{
                    [forFriendDict setObject:@"" forKey:@"odo"];
                }
                
                updRecord.dist =@([odometer.text floatValue]);
            }
            else {
                updRecord.odo = @([odometer.text floatValue]);
                updRecord.dist =@([odometer.text floatValue]);
                if(updRecord.odo != nil){
                    [forFriendDict setObject:updRecord.odo forKey:@"odo"];
                }else{
                    [forFriendDict setObject:@"" forKey:@"odo"];
                }
            }
            // NSLog(@"odo value %@",dataval.odo);
            updRecord.vehid = comparestring;
            if(updRecord.vehid != nil){
                [forFriendDict setObject:vehid forKey:@"vehid"];
            }
            
            //10june2018 nikhil to truncate qty to 3digits
//            commonMethods *common = [[commonMethods alloc]init];
//            NSNumberFormatter *lformatter = [common decimalFormatter];
//            float calculatedQty = [self calculateQty:[qty.text floatValue]];
//            NSString *qtyValue = [lformatter stringFromNumber: [NSNumber numberWithDouble: calculatedQty]];
            
           // float calculatedQty = [self calculateQty:[qty.text floatValue]];
            updRecord.qty = @([qty.text floatValue]);
            if(updRecord.qty != nil){
                [forFriendDict setObject:updRecord.qty forKey:@"qty"];
            }else{
                [forFriendDict setObject:@"" forKey:@"qty"];
            }
            
            updRecord.stringDate= formatteddate;
            if(updRecord.stringDate != nil){
                [forFriendDict setObject:updRecord.stringDate forKey:@"date"];
            }else{
                [forFriendDict setObject:@"" forKey:@"date"];
            }
            
            updRecord.type = @(0);
            if(updRecord.type != nil){
               [forFriendDict setObject:updRecord.type forKey:@"type"];
            }
            
            updRecord.serviceType = @"Fuel Record";
            if(updRecord.serviceType != nil){
                [forFriendDict setObject:updRecord.serviceType forKey:@"serviceType"];
            }

            NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
            NSString *string = [array lastObject];

            if([priceUnitLabel.text isEqualToString:string] || [totalUnitLabel.text isEqualToString:string]){

                NSLog(@"No need of calculating");
                updRecord.cost = @([price.text floatValue]);
            }else{

                NSString *calculatedCost = [self getCalculatedCost:price.text selectedCurrUnit:priceUnitLabel.text];
                updRecord.cost = @([calculatedCost floatValue]);
            }
           // updRecord.cost = @([price.text floatValue]);
            if(updRecord.cost != nil){
                [forFriendDict setObject:updRecord.cost forKey:@"cost"];
            }
            updRecord.octane = @([octane.text floatValue]);
            if(updRecord.octane != nil){
                [forFriendDict setObject:updRecord.octane forKey:@"octane"];
            }
            updRecord.fuelBrand = fuel.text;
            if(updRecord.fuelBrand != nil){
                 [forFriendDict setObject:updRecord.fuelBrand forKey:@"fuelBrand"];
            }else{
                 [forFriendDict setObject:@"" forKey:@"fuelBrand"];
            }
            updRecord.fillStation = filling.text;
            if(updRecord.fillStation != nil){
                 [forFriendDict setObject:updRecord.fillStation forKey:@"fillStation"];
            }else{
                 [forFriendDict setObject:@"" forKey:@"fillStation"];
            }
           
            updRecord.notes =notes.text;
            if(updRecord.notes != nil){
                [forFriendDict setObject:updRecord.notes forKey:@"notes"];
            }else{
                [forFriendDict setObject:@"" forKey:@"notes"];
            }
            
            
            //New_11 Maps: if latLong is nil or 0 check for latLong
            if(!updRecord.longitude || [updRecord.longitude intValue] < 1){
                
                updRecord.longitude = saveCurLongitude;
            }
            if(!updRecord.latitude || [updRecord.latitude intValue] < 1){
                
                updRecord.longitude = saveCurLat;
            }
            
            //dataval.dist =@([odometer.text floatValue]);
            
            UIButton *button  = (UIButton *)[self.view viewWithTag:1000];
            
            if(button.selected==YES)
            {
                updRecord.pfill = @(1);
                CLSLog(@"pfill value:-%@",updRecord.pfill);
                CLS_LOG(@"pfill value:-%@",updRecord.pfill);
                if(updRecord.pfill)
                [forFriendDict setObject:updRecord.pfill forKey:@"pfill"];
            }
            else
            {
                updRecord.pfill = @(0);
                CLSLog(@"pfill value:-%@",updRecord.pfill);
                CLS_LOG(@"pfill value:-%@",updRecord.pfill);
                if(updRecord.pfill)
                [forFriendDict setObject:updRecord.pfill forKey:@"pfill"];
                
            }
            UIButton *mfButton  = (UIButton *)[self.view viewWithTag:2000];
            
            if(mfButton.selected==YES)
            {
                updRecord.mfill = @(1);
                CLSLog(@"mfill value:-%@",updRecord.mfill);
                CLS_LOG(@"mfill value:-%@",updRecord.mfill);
                if(updRecord.mfill)
                    
                [forFriendDict setObject:updRecord.mfill forKey:@"mfill"];
                
            }
            else
            {
                updRecord.mfill = @(0);
                CLSLog(@"mfill value:-%@",updRecord.mfill);
                CLS_LOG(@"mfill value:-%@",updRecord.mfill);
                if(updRecord.mfill)
                [forFriendDict setObject:updRecord.mfill forKey:@"mfill"];
                
            }
            //NIKHIL BUG_166
            NSString *emptyString = @"";
            if((self.receiptImageArray == nil || self.receiptImageArray.count == 0 ) && ![updRecord.receipt isEqualToString:emptyString])
            {
                //Swapnil 25 Apr-2017
                NSFileManager *filemanager = [NSFileManager defaultManager];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                
                //Swapnil ENH_24
                NSString *documentsDirectory = [paths firstObject];
                NSString *imagePath = updRecord.receipt;
                NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", imagePath]];
                NSError *error;
                BOOL imageExist = [[NSFileManager defaultManager] fileExistsAtPath:completeImgPath];
                if(imageExist){
                    [filemanager removeItemAtPath:completeImgPath error:&error];
                }
                updRecord.receipt =nil;
            }
            else
            {
               
                    
                    //ENH_57 to save multiple receipt
                    if(self.receiptImageArray == nil){
                        updRecord.receipt = nil;
                    }else{
                       
                        NSString *wholeImageString = [[NSString alloc]init];
                        NSString *finalString = [[NSString alloc]init];
                        for(NSString *imageString in self.receiptImageArray){
                        
                             wholeImageString = [wholeImageString stringByAppendingString:imageString];
                             wholeImageString = [wholeImageString stringByAppendingString:@":::"];
                        
                        }
                        if(wholeImageString.length > 0){
                             int lastThree =(int)wholeImageString.length-3;
                             finalString = [wholeImageString substringToIndex:lastThree];
                        }
                    
                      updRecord.receipt = finalString;

                        //To show receipt Go Pro alert
                        [Def setBool:YES forKey:@"receiptPresent"];
                    }
                
            }
            
            if ([contex hasChanges])
            {
                BOOL saved = [contex save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
                [[CoreDataController sharedInstance] saveMasterContext];
                
                //Swapnil NEW_6
                NSString *userEmail = [Def objectForKey:@"UserEmail"];
                
                //If user is signed In, then only do the sync process..
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

                    if(userEmail != nil && userEmail.length > 0){

                        [self writeToSyncTableWithRowID:syncRowID tableName:@"LOG_TABLE" andType:@"edit" andOS:@"self"];

                    }
                });

                
                //Swapnil 6 Jun-17
                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                //[def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
                
                BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
                
                if(!proUser){
                    NSInteger gadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"adCount"];
                    gadCount = gadCount + 1;
                    [[NSUserDefaults standardUserDefaults] setInteger:gadCount forKey:@"adCount"];
                }
                
                [def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
                
            }

            //[self updatedistance];
            [self updateodometer];
            [self updateconvalue];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
          //  [self checkNetworkForCloudStorage];
            //Upload data from common methods
//            commonMethods *common = [[commonMethods alloc] init];
//            [common checkNetworkForCloudStorage:@"isLog"];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        
        //Changed the object type bcuz it is causing langaue issues
        //else if ([[Def objectForKey:@"filluptype"]isEqualToString:NSLocalizedString(@"odometer", @"Odometer")]
        else if ([[Def objectForKey:@"filluptype"]isEqualToString:@"odometer"] /*&& [self checkOdo:[odometer.text floatValue] ForDate: [f dateFromString: date.text]]*/)
        {
            //Swapnil BUG_76
            BOOL isDateOdoEdited, isValid = NO;
            if(([oldOdo floatValue] != [odometer.text floatValue]) || [[f dateFromString:oldDateStr] compare:[f dateFromString:date.text]] != NSOrderedSame || [Def boolForKey:@"editPageOpen"]){
                isValid = [self checkOdo:[odometer.text floatValue] ForDate: [f dateFromString: date.text]];
                isDateOdoEdited = YES;
               // [Def setBool:NO forKey:@"editPageOpen"];
            } else {
                isDateOdoEdited = NO;
            }
            
            if(isValid == YES || isDateOdoEdited == NO){
                
                
                //Save values in the database
                NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                [formater setDateFormat:@"dd/MM/yyyy"];
                NSDate *formatteddate =[formater dateFromString:date.text];
                updRecord.odo =@([odometer.text floatValue]);
                if(updRecord.odo != nil){
                    [forFriendDict setObject:updRecord.odo forKey:@"odo"];
                }else{
                    [forFriendDict setObject:@"" forKey:@"odo"];
                }
                
                updRecord.vehid = comparestring;
                if(vehid != nil){
                    [forFriendDict setObject:vehid forKey:@"vehid"];
                }else{
                    [forFriendDict setObject:@"" forKey:@"vehid"];
                }
                
               // float calculatedQty = [self calculateQty:[qty.text floatValue]];
                updRecord.qty = @([qty.text floatValue]);// @(calculatedQty);
                if(updRecord.qty != nil){
                    [forFriendDict setObject:updRecord.qty forKey:@"qty"];
                }else{
                    [forFriendDict setObject:@0 forKey:@"qty"];
                }
                updRecord.stringDate= formatteddate;
                if(updRecord.stringDate != nil){
                    [forFriendDict setObject:updRecord.stringDate forKey:@"date"];
                }else{
                    [forFriendDict setObject:@"" forKey:@"date"];
                }
                
                updRecord.type = @(0);
                if(updRecord.type != nil){
                    [forFriendDict setObject:updRecord.type forKey:@"type"];
                }
                
                updRecord.serviceType = @"Fuel Record";
                if(updRecord.serviceType != nil){
                    [forFriendDict setObject:updRecord.serviceType forKey:@"serviceType"];
                }
                updRecord.cost = @([price.text floatValue]);
                if(updRecord.cost != nil){
                    [forFriendDict setObject:updRecord.cost forKey:@"cost"];
                }
                updRecord.octane = @([octane.text floatValue]);
                if(updRecord.octane != nil){
                    [forFriendDict setObject:updRecord.octane forKey:@"octane"];
                }
                
                updRecord.fuelBrand = fuel.text;
                if(updRecord.fuelBrand != nil){
                     [forFriendDict setObject:updRecord.fuelBrand forKey:@"fuelBrand"];
                }else{
                      [forFriendDict setObject:@"" forKey:@"fuelBrand"];
                }
                updRecord.fillStation = filling.text;
                if(updRecord.fillStation != nil){
                    [forFriendDict setObject:updRecord.fillStation forKey:@"fillStation"];
                }else{
                    [forFriendDict setObject:@"" forKey:@"fillStation"];
                }
                
                updRecord.notes =notes.text;
                if(updRecord.notes != nil){
                    [forFriendDict setObject:updRecord.notes forKey:@"notes"];
                }else{
                    [forFriendDict setObject:@"" forKey:@"notes"];
                }
                
                //New_11 Maps: if latLong is nil or 0 check for latLong
                if(!updRecord.longitude || [updRecord.longitude intValue] < 1){
                    
                    updRecord.longitude = saveCurLongitude;
                }
                if(!updRecord.latitude || [updRecord.latitude intValue] < 1){
                    
                    updRecord.longitude = saveCurLat;
                }
                
                updRecord.dist =@([odometer.text floatValue]-prevOdo);
                
                UIButton *button  = (UIButton *)[self.view viewWithTag:1000];
                
                if(button.selected==YES)
                {
                    updRecord.pfill = @(1);
                    CLSLog(@"pfill value:-%@",updRecord.pfill);
                    CLS_LOG(@"pfill value:-%@",updRecord.pfill);
                    if(updRecord.pfill)
                    [forFriendDict setObject:updRecord.pfill forKey:@"pfill"];
                    
                    
                }
                else
                {
                    updRecord.pfill = @(0);
                    CLSLog(@"pfill value:-%@",updRecord.pfill);
                    CLS_LOG(@"pfill value:-%@",updRecord.pfill);
                    if(updRecord.pfill)
                        [forFriendDict setObject:updRecord.pfill forKey:@"pfill"];
                    
                }
                UIButton *mfButton  = (UIButton *)[self.view viewWithTag:2000];
                
                if(mfButton.selected==YES)
                {
                    updRecord.mfill = @(1);
                    CLSLog(@"pfill value:-%@",updRecord.mfill);
                    CLS_LOG(@"pfill value:-%@",updRecord.mfill);
                    if(updRecord.mfill)
                        [forFriendDict setObject:updRecord.mfill forKey:@"pfill"];
                    
                    
                }
                else
                {
                    updRecord.mfill = @(0);
                    CLSLog(@"pfill value:-%@",updRecord.mfill);
                    CLS_LOG(@"pfill value:-%@",updRecord.mfill);
                    if(updRecord.mfill)
                        [forFriendDict setObject:updRecord.mfill forKey:@"pfill"];
                    
                }
                //BUG_166
                NSString *emptyString = @"";
                if((self.receiptImageArray == nil || self.receiptImageArray.count == 0 ) && ![updRecord.receipt isEqualToString:emptyString])
                {
                    //Swapnil 25 Apr-2017
                    NSFileManager *filemanager = [NSFileManager defaultManager];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    
                    //Swapnil ENH_24
                    NSString *documentsDirectory = [paths firstObject];
                    
                    NSString *imagePath = updRecord.receipt;
                    NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", imagePath]];
                    NSError *error;
                    BOOL imageExist = [[NSFileManager defaultManager] fileExistsAtPath:completeImgPath];
                    if(imageExist){
                        [filemanager removeItemAtPath:completeImgPath error:&error];
                    }
                    updRecord.receipt =nil;
                }
                else
                {
                    
                        
                        //ENH_57 to save multiple receipt
                        if(self.receiptImageArray.count == 0){
                            updRecord.receipt = nil;
                        }else{
                          
                            NSString *wholeImageString = [[NSString alloc]init];
                            NSString *finalString = [[NSString alloc]init];
                            for(NSString *imageString in self.receiptImageArray){
                            
                                wholeImageString = [wholeImageString stringByAppendingString:imageString];
                                wholeImageString = [wholeImageString stringByAppendingString:@":::"];
                            
                            }
                            if(wholeImageString.length > 0){
                                   int lastThree =(int)wholeImageString.length-3;
                                   finalString = [wholeImageString substringToIndex:lastThree];
                            }
                        
                            updRecord.receipt = finalString;
                            //To show receipt Go Pro alert
                            [Def setBool:YES forKey:@"receiptPresent"];
                        }
                    
                }
                
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    [[CoreDataController sharedInstance] saveMasterContext];
                    
                    //Swapnil NEW_6
                    NSString *userEmail = [Def objectForKey:@"UserEmail"];
                    
                    //If user is signed In, then only do the sync process..
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

                        if(userEmail != nil && userEmail.length > 0){

                            [self writeToSyncTableWithRowID:syncRowID tableName:@"LOG_TABLE" andType:@"edit" andOS:@"self"];

                        }
                    });

                    //Swapnil 6 Jun-17
                     NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    //[def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
                    
                    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
                    
                    if(!proUser){
                        NSInteger gadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"adCount"];
                        gadCount = gadCount + 1;
                        [[NSUserDefaults standardUserDefaults] setInteger:gadCount forKey:@"adCount"];
                    }
                    
                    [def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
                    
                }
                
                //Nikhil_BUG_163 cons value updated separatly if odo is maxOdo, 23/11/2019 How do you know?
                //commonMethods *common = [[commonMethods alloc]init];
                [self updatedistance];

//                if([oldOdo floatValue] < [odometer.text floatValue]){
//                    [common updateConsumptionMaxOdo];
//                }else{
//                [self updateconvalue];
//                }
                [self updateconvalue];
                [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
                [self getOdoServices];
                
               // [self checkNetworkForCloudStorage];
                //Upload data from common methods
//                [common checkNetworkForCloudStorage:@"isLog"];
                [self dismissViewControllerAnimated:YES completion:nil];
                [Def setBool:NO forKey:@"editPageOpen"];
                [Def setObject:[Def objectForKey:@"fillupid"] forKey:@"oldFillupid"];
            }//Swapnil BUG_76
            else {
                
                [self showAlert:NSLocalizedString(@"incorrect_odo", @"Incorrect Odometer value for Date") message:@""];
            }
        }
        
    }
    else
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Enter Date,Odometer and Quantity"
                                              message:@""
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
    
    
}

-(BOOL)checkOdo:(float)iOdo ForDate:(NSDate*)iDate
{
    //Swapnil BUG_76
    commonMethods *commMethod = [[commonMethods alloc] init];
    BOOL valuesOK = [commMethod checkOdo:iOdo ForDate:iDate];
    recOrder = [[NSUserDefaults standardUserDefaults] objectForKey:@"recordOrder"];
    prevOdo = [[NSUserDefaults standardUserDefaults] floatForKey:@"prevOdom"];
    return valuesOK;
    
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    
    
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

-(void)addtext
{
    AppDelegate *app = [AppDelegate sharedAppDelegate];
    self.result=app.result;
    
    scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0,60, app.result.width,app.result.height)];
    
    scrollview.showsVerticalScrollIndicator=YES;
    scrollview.scrollEnabled=YES;
    scrollview.userInteractionEnabled=YES;
    scrollview.contentSize = CGSizeMake(app.result.width,app.result.height+300);
    scrollview.tag=-3;
    [self.view addSubview:scrollview];
    UIView *bgview = [[UIView alloc]init];
    bgview.frame = CGRectMake(0, 0, app.result.width, app.result.height+300);
    bgview.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    bgview.tag=-2;
    [scrollview addSubview:bgview];
    
    
    int y=0;
    for(int i= 0; i<self.textplace.count;i++)
    {
        
        if(![[self.textplace objectAtIndex:i]isEqualToString:@""])
        {
        
            UITextField *text = [[UITextField alloc]init];
            UITextView *notesTextView = [[UITextView alloc]init];
            
            //NIKHIL ENH_41 //date brought down
            text.frame = CGRectMake(10,y,self.result.width-30,51);
            text.tag=i;
            text.textColor=[UIColor whiteColor];
            text.font =[UIFont systemFontOfSize:13];
            
            
            notesTextView.textColor=[UIColor whiteColor];
            notesTextView.font =[UIFont systemFontOfSize:13];
            
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")]||[[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"prc_per_unt", @"Price/Unit")])
            {
                text.keyboardType =UIKeyboardTypeDecimalPad;
                
                UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
                numberToolbar.barStyle = UIBarStyleDefault;
                numberToolbar.backgroundColor =[UIColor whiteColor];
                numberToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                       [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                                       nil];
                
                [numberToolbar sizeToFit];
                text.inputAccessoryView = numberToolbar;
                text.frame = CGRectMake(10,y,130,51);//NIKHIL ENH_41 152 to 130
                
                //NIKHIL ENH_41 //underlined odometer
                //ENH_56 //shifting underline to left by 30
                UILabel *odoLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, text.frame.origin.y+35, 107, 0.65)];
                odoLineLabel.backgroundColor = [UIColor lightGrayColor];
                [bgview addSubview:odoLineLabel];
                //till here
                
                if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"prc_per_unt", @"Price/Unit")] && ![self.textplace containsObject:NSLocalizedString(@"tc_tv", @"Total Cost")])
                {
                    
                    text.frame = CGRectMake(10,y,self.result.width-170,51);//NIKHIL ENH_41 -30 to -170
                    y=y+50;
                    
                }
                
                else
                {
                    text.frame = CGRectMake(10,y,152,51);
                }
            }
            
            
            if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"qty_required", @"Qty")] ||[[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"tc_tv", @"Total Cost")])
            {
                
                text.keyboardType =UIKeyboardTypeDecimalPad;
                UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
                numberToolbar.barStyle = UIBarStyleDefault;
                numberToolbar.backgroundColor =[UIColor whiteColor];
                numberToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                       [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                                       nil];
                
                [numberToolbar sizeToFit];
                text.inputAccessoryView = numberToolbar;
                
                
                //NIKHIL ENH_41 //underlined qty, added if statement
                if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"qty_required", @"Qty")] || ([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"tc_tv", @"Total Cost")] && [self.textplace containsObject:NSLocalizedString(@"prc_per_unt", @"Price/Unit")])){
                    //ENH_56 shortening underline 140 -> 110
                    UILabel *odoLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, text.frame.origin.y+35, 110, 0.65)];
                    
                    
                    odoLineLabel.backgroundColor = [UIColor lightGrayColor];
                    [bgview addSubview:odoLineLabel];
                }
                //till here
                
                if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"tc_tv", @"Total Cost")] && ![self.textplace containsObject:NSLocalizedString(@"prc_per_unt", @"Price/Unit")])
                {
                    
                    
                    text.frame = CGRectMake(10,y,self.result.width-170,51);
                    
                    //NIKHIL ENH_41 //underlined only total
                    UILabel *odoLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, text.frame.origin.y+35, text.frame.size.width+5, 0.65)];
                    odoLineLabel.backgroundColor = [UIColor lightGrayColor];
                    [bgview addSubview:odoLineLabel];
                    //till here
                    
                }
                
                else
                {
                    //ENH_56 trying to reduce width of qty and total cost by -30
                    if(self.result.width==320)
                    {
                        text.frame = CGRectMake(156,y,self.result.width/2-50,51);
                    }
                    
                    else if(self.result.width==414)
                    {
                        text.frame = CGRectMake(156,y,self.result.width/2,51);
                        
                    }
                    else if(self.result.width==375)
                    {
                        text.frame = CGRectMake(156,y,self.result.width/2-15,51);
                        
                    }
                    
                    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,10, 20)];
                    text.leftView = paddingView;
                    text.leftViewMode = UITextFieldViewModeAlways;
                }
                
                
            }
            
            
            if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"pf_tv", @"Partial Tank")] || [[self.textplace objectAtIndex:i]isEqualToString:@"Select"])
            {
                UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,60, 20)];
                text.leftView = paddingView;
                text.leftViewMode = UITextFieldViewModeAlways;
                text.enabled=NO;
                
                if([[self.textplace objectAtIndex:i] isEqualToString:@"Select"])
                {
                    if([[NSUserDefaults standardUserDefaults]objectForKey:@"fillupmake"]!=nil)
                    {
                        text.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"fillupmake"];
                    }
                    else
                    {
                        text.text = @"";
                    }
                    text.frame = CGRectMake(0,y,app.result.width,56);
                    // NIKHIL ENH_41 //51 to 56
                    
                    text.tag=-9;
                    
                    
                }
                if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"pf_tv", @"Partial Tank")])
                {
                    UIView *view = [[UIView alloc]init];
                    view.frame =CGRectMake(10,y,self.result.width-30,51);
                    view.backgroundColor =[UIColor clearColor];
                    
                    [bgview addSubview:view];
                    UIButton *check = [[UIButton alloc]init];
                    check.frame = CGRectMake(10, 5, 40, 40);
                    check.userInteractionEnabled=YES;
                    check.tag=1000;
                    [check setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
                    [check setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
                    [check addTarget:self action:@selector(checkclick:) forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:check];
                }
                
                
                
            }
            if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"mf_tv", @"Missed Previous Fill up")] )
            {
                UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,60, 20)];
                text.leftView = paddingView;
                text.leftViewMode = UITextFieldViewModeAlways;
                text.enabled=NO;
                
                if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"mf_tv", @"Missed Previous Fill up")])
                {
                    UIView *view = [[UIView alloc]init];
                    view.frame =CGRectMake(10,y,self.result.width-30,51);
                    view.backgroundColor =[UIColor clearColor];
                    
                    [bgview addSubview:view];
                    UIButton *check = [[UIButton alloc]init];
                    check.frame = CGRectMake(10, 5, 40, 40);
                    check.userInteractionEnabled=YES;
                    check.tag=2000;
                    [check setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
                    [check setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
                    [check addTarget:self action:@selector(checkMissedFillUp:) forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:check];
                }
                
                
                
            }
            
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"octane", @"Octane")])
            {
                text.keyboardType =UIKeyboardTypeDecimalPad;
                UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
                numberToolbar.barStyle = UIBarStyleDefault;
                numberToolbar.backgroundColor =[UIColor whiteColor];
                numberToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                       [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                                       nil];
                
                [numberToolbar sizeToFit];
                text.inputAccessoryView = numberToolbar;
                //NIKHIL ENH_41 //frame added to octane and underlined octane
                text.frame = CGRectMake(10,y,self.result.width-30,70);
                UILabel *octaneLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, text.frame.origin.y+45, text.frame.size.width, 0.65)];
                octaneLineLabel.backgroundColor = [UIColor lightGrayColor];
                [bgview addSubview:octaneLineLabel];
                //till here
                
            }
            if(![[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")] && ![[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"prc_per_unt", @"Price/Unit")])
            {
                
                y=y+50;
                
            }
            
            //NIKHIL ENH_41 //(adding 3 if statements to put underline to fuel brand,filling station and notes
            
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"fb_tv", @"Fuel Brand")])
            {
                
                text.frame = CGRectMake(10,y-35,self.result.width-30,70);
                UILabel *threeLinesLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, text.frame.origin.y+45, text.frame.size.width, 0.65)];
                threeLinesLabel.backgroundColor = [UIColor lightGrayColor];
                [bgview addSubview:threeLinesLabel];
                
            }
            
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"fs_tv", @"Filling Station")])
            {
                text.frame = CGRectMake(10,y-25,self.result.width-30,70);
                UILabel *threeLinesLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, text.frame.origin.y+45, text.frame.size.width, 0.65)];
                threeLinesLabel.backgroundColor = [UIColor lightGrayColor];
                [bgview addSubview:threeLinesLabel];
            }
            
            
            text.placeholder = [self.textplace objectAtIndex:i];
            text.delegate=self;
            notesTextView.delegate = self;
            //text.textAlignment=NSTextAlignmentCenter;
            [self textfieldsetting:text];
           
            [bgview addSubview:text];
            //[bgview addSubview:NotesTextView];
            
            UILabel *label =[[UILabel alloc]init];
            label.frame=CGRectMake(4, 4, text.frame.size.width,15);
            label.text= [self.textplace objectAtIndex:i];
            label.textColor=[UIColor lightGrayColor];
            label.font =[UIFont systemFontOfSize:10];
            label.hidden=YES;
            label.tag=i*20;
            [text addSubview:label];
            
            
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")])
            {
                UILabel *odo = [[ UILabel alloc]init];
                //NIKHIL ENH_41 shifting miles to right by 16
                odo.frame = CGRectMake(text.frame.size.width-43, 15, 50, 20);
                odo.textColor = [UIColor grayColor];
                odo.font = [UIFont systemFontOfSize:13];
                
                label.frame=CGRectMake(4, 0, text.frame.size.width,15);
                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
                {
                    odo.text = NSLocalizedString(@"mi", @"mi");
                }
                
                else
                {
                    odo.text = NSLocalizedString(@"kms", @"km");
                }
                [text addSubview:odo];
            }
            
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"qty_required", @"Qty")])
            {
                
                
                UILabel *odo = [[ UILabel alloc]init];
                //NIKHIL ENH_41 //shifting gal to right by 35
                //ENH_56 //shifting curr_unit
                odo.frame = CGRectMake(text.frame.size.width+3, 15, 50, 20);
                odo.textColor = [UIColor grayColor];
                odo.font = [UIFont systemFontOfSize:13];
                odo.tag = 18;
                label.frame=CGRectMake(4, 0, text.frame.size.width,15);

                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

                    odo.text = NSLocalizedString(@"kwh", @"kWh");

                }else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
                {
                    odo.text = NSLocalizedString(@"ltr", @"Ltr");
                    
                }
                else {
                    odo.text = NSLocalizedString(@"gal", @"gal");
                }

                [text addSubview:odo];
                
                //ENH_56 Added picker view for unit dropdown button
                if(![[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

                    unitButton = [[UIButton alloc]init];
                    CGSize stringsize = [odo.text sizeWithAttributes:@{NSFontAttributeName:odo.font}];
                    unitButton.frame=CGRectMake(stringsize.width+105, odo.frame.origin.y-8, 40, 40);
                    [unitButton setImage:[UIImage imageNamed:@"dowpdown_grey"] forState:UIControlStateNormal];
                    [unitButton addTarget:self action:@selector(openUnitPicker) forControlEvents:UIControlEventTouchUpInside];
                    [text addSubview:unitButton];
                    UIButton *bgbutton = [[UIButton alloc]init];
                    bgbutton.frame =CGRectMake(text.frame.origin.x+100, text.frame.origin.y-8, text.frame.size.width-50, text.frame.size.height);

                    bgbutton.titleLabel.text=@"";
                    bgbutton.backgroundColor =[UIColor clearColor];
                    [bgbutton addTarget:self action:@selector(openUnitPicker) forControlEvents:UIControlEventTouchUpInside];
                    [bgview addSubview:bgbutton];
                }

            }
            
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"prc_per_unt", @"Price/Unit")])
            {
                UILabel *odo = [[ UILabel alloc]init];
                //NIKHIL ENH_41 //shifting USD to right by 9
                //ENH_56 //shifting curr_unit
                odo.frame = CGRectMake(text.frame.size.width-70, 15, 50, 20);
                odo.textColor = [UIColor grayColor];
                odo.font = [UIFont systemFontOfSize:13];
                odo.tag = 13;
                label.frame=CGRectMake(4, 0, text.frame.size.width,15);
                NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                NSString *string = [array lastObject];
                odo.text = string;
                [text addSubview:odo];

                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

                    text.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"kwh", @"kWh")];

                    label.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"kwh", @"kWh")];
                    odo.text = NSLocalizedString(@"kwh", @"kWh");

                }else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
                {
                    text.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"ltr", @"Ltr")];
                    
                    label.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"ltr", @"Ltr")];
                    
                }
                
                else
                {
                    text.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"gal", @"gal")];
                    label.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"gal", @"gal")];
                    
                }

                //ENH_56 Added picker view for unit dropdown button

                priceCurrencyButton = [[UIButton alloc]init];
                //CGSize stringsize = [odo.text sizeWithAttributes:@{NSFontAttributeName:odo.font}];
                priceCurrencyButton.frame=CGRectMake(odo.frame.origin.x+20, odo.frame.origin.y-8, 40, 40);
                [priceCurrencyButton setImage:[UIImage imageNamed:@"dowpdown_grey"] forState:UIControlStateNormal];
                [priceCurrencyButton addTarget:self action:@selector(openCurrencyPicker) forControlEvents:UIControlEventTouchUpInside];
                [text addSubview:priceCurrencyButton];
                UIButton *bgbutton = [[UIButton alloc]init];
                bgbutton.frame =CGRectMake(text.frame.origin.x+100, text.frame.origin.y-8, text.frame.size.width-50, text.frame.size.height);

                bgbutton.titleLabel.text=@"";
                bgbutton.backgroundColor =[UIColor clearColor];
                [bgbutton addTarget:self action:@selector(openCurrencyPicker) forControlEvents:UIControlEventTouchUpInside];
                [bgview addSubview:bgbutton];
                
            }
            
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"tc_tv", @"Total Cost")])
            {
                UILabel *odo = [[ UILabel alloc]init];
                //NIKHIL ENH_41 //shifting Total USD to right by 25
                //ENH_56 //shifting curr_unit
                odo.frame = CGRectMake(text.frame.size.width-2, 15, 50, 20);
                odo.tag = 14;
                odo.textColor = [UIColor grayColor];
                odo.font = [UIFont systemFontOfSize:13];
                label.frame=CGRectMake(4, 0, text.frame.size.width,15);
                NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                NSString *string = [array lastObject];
                odo.text = string;
                [text addSubview:odo];

                //ENH_56 Added picker view for unit dropdown button

                totalCurrencyButton = [[UIButton alloc]init];
                CGSize stringsize = [odo.text sizeWithAttributes:@{NSFontAttributeName:odo.font}];
                totalCurrencyButton.frame=CGRectMake(stringsize.width+105, odo.frame.origin.y-8, 40, 40);
                [totalCurrencyButton setImage:[UIImage imageNamed:@"dowpdown_grey"] forState:UIControlStateNormal];
                [totalCurrencyButton addTarget:self action:@selector(openCurrencyPicker) forControlEvents:UIControlEventTouchUpInside];
                [text addSubview:totalCurrencyButton];
                UIButton *bgbutton = [[UIButton alloc]init];
                bgbutton.frame =CGRectMake(text.frame.origin.x+100, text.frame.origin.y-8, text.frame.size.width-50, text.frame.size.height);

                bgbutton.titleLabel.text=@"";
                bgbutton.backgroundColor =[UIColor clearColor];
                [bgbutton addTarget:self action:@selector(openCurrencyPicker) forControlEvents:UIControlEventTouchUpInside];
                [bgview addSubview:bgbutton];
            }
            
            
            //Changed the object type bcuz it is causing langaue issues
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")])
            {
//                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"filluptype"]isEqualToString:NSLocalizedString(@"trp", @"Trip")])
                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"filluptype"]isEqualToString:@"Trip"])
                {
                    text.placeholder= NSLocalizedString(@"trp", @"Trip");
                    label.text =NSLocalizedString(@"trp", @"Trip");
                }
            }
            
            
            if([[self.textplace objectAtIndex:i] isEqualToString:@"Select"])
            {
                
                text.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
                CGSize stringsize = [text.text sizeWithAttributes:@{NSFontAttributeName:text.font}];
                dropdown = [[UIButton alloc]init];
                dropdown.frame=CGRectMake(stringsize.width+60, text.frame.origin.y+8, 40, 40);
                [dropdown setImage:[UIImage imageNamed:@"dowpdown_white"] forState:UIControlStateNormal];
                [dropdown addTarget:self action:@selector(openselectpicker) forControlEvents:UIControlEventTouchUpInside];
                [text addSubview:dropdown];
                UIButton *bgbutton = [[UIButton alloc]init];
                bgbutton.frame =CGRectMake(text.frame.origin.x, text.frame.origin.y+5, text.frame.size.width - 100, text.frame.size.height);
                
                bgbutton.titleLabel.text=@"";
                bgbutton.backgroundColor =[UIColor clearColor];
                bgbutton.tag = -6;
                [bgbutton addTarget:self action:@selector(openselectpicker) forControlEvents:UIControlEventTouchUpInside];
                [bgview addSubview:bgbutton];
                UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(_result.width-45, 0, 50, 50)];
                [button setImage:[UIImage imageNamed:@"settings_med"] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(buttonclick) forControlEvents:UIControlEventTouchUpInside];
                [bgview addSubview:button];
                
                _vehimage = [[UIImageView alloc]init];
                _vehimage.frame = CGRectMake(5,1, 45, 45);//NIKHIL ENH_41 //frame y0 changed to 1
                _vehimage.layer.cornerRadius = 22;
                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
                {
                    // NSLog(@"blank....");
                    _vehimage.image=[UIImage imageNamed:@"car4.jpg"];
                }
                
                else
                {
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    
                    //Swapnil ENH_24
                    self.urlstring = [paths firstObject];
                    
                    NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",self.urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
                    _vehimage.image =[UIImage imageWithContentsOfFile:vehiclepic];
                }
                _vehimage.contentMode = UIViewContentModeScaleAspectFill;
                _vehimage.layer.borderWidth=0;
                _vehimage.layer.masksToBounds=YES;
                [bgbutton addSubview:_vehimage];
             
            }
            
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"date", @"Date")])
            {
                //text.placeholder=@"";
                //NIKHIL ENH_41 // date frame re-ordering
                text.frame = CGRectMake(10,y-50,130,70);
                //text.backgroundColor = [UIColor redColor];
                NSDateFormatter *f=[[NSDateFormatter alloc] init];
                [f setDateFormat:@"dd-MMM-yyyy"];
                NSString *date=[f stringFromDate:[NSDate date]];
                text.text=date;
                UIButton *bgbutton = [[UIButton alloc]init];
                bgbutton.frame =CGRectMake(text.frame.origin.x, text.frame.origin.y+5, text.frame.size.width, text.frame.size.height);

                
                //NIKHIL ENH_41 Added dateLabel
                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,50, 50, 40)];
                dateLabel.text = @"Date";
                dateLabel.textColor = [UIColor lightGrayColor];
                dateLabel.font = [UIFont systemFontOfSize:10];
                //till here
                
                bgbutton.tag=-5;
                bgbutton.backgroundColor =[UIColor clearColor];
                [bgbutton addTarget:self action:@selector(openpicker:) forControlEvents:UIControlEventTouchUpInside];
                
                //NIKHIL ENH_41 //Adding date image
                _date = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"date"]];
                _date.frame = CGRectMake(text.frame.origin.x+90, text.frame.origin.y+27, 12, 12);
                _date.contentMode = UIViewContentModeScaleAspectFill;
                _date.clipsToBounds = YES;
                [bgview addSubview:_date];
                _date.userInteractionEnabled = YES;
                //till here
                
                [bgview addSubview:bgbutton];
                [bgview addSubview:dateLabel];
                
            }
            
            if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"attach_receipt", @"Attach receipt") ])
            {
                //NIKHIL ENH_41 //frame added to receipt
                text.frame = CGRectMake(10,y+5,self.result.width-30,70);
                [text setUserInteractionEnabled:false];
                UIButton *bgbutton = [[UIButton alloc]init];
                bgbutton.frame =CGRectMake(text.frame.origin.x, text.frame.origin.y+11, text.frame.size.width, text.frame.size.height);
                bgbutton.titleLabel.text=@"";
                [bgbutton.titleLabel setFont:[UIFont systemFontOfSize:10]];
                bgbutton.backgroundColor =[UIColor clearColor];
                
                //NIKHIL BUG_137 // changed the value of reload text to NO for edited record
                [[NSUserDefaults standardUserDefaults]setObject:@"no" forKey:@"reloadtext"];
              
              
                UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
                 _receiptCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(text.frame.origin.x, y+60,text.frame.size.width,200) collectionViewLayout:layout];
                 [_receiptCollectionView setDataSource:self];
                 [_receiptCollectionView setDelegate:self];
                 
                 [_receiptCollectionView registerClass:[ReceiptCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
                 [_receiptCollectionView setBackgroundColor:[UIColor clearColor]];
                 
                 [bgview addSubview:_receiptCollectionView];
             
            }
            
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"notes_tv", @"Notes")])
            {
                //NIKHIL BUG_130
                notesTextView.frame = CGRectMake(10,y+9,self.result.width-30,40);
                notesTextView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];//[UIColor purpleColor];
                text.userInteractionEnabled = false;
                text.frame = CGRectMake(10,y-15,self.result.width-30,35);
                label.text = @"Notes";
                label.font =[UIFont systemFontOfSize:10];
                UILabel *threeLinesLabel = [[UILabel alloc]initWithFrame:CGRectMake(notesTextView.frame.origin.x, notesTextView.frame.origin.y+45, notesTextView.frame.size.width, 0.65)];
                threeLinesLabel.backgroundColor = [UIColor lightGrayColor];
               
                [bgview addSubview:text];
                [bgview addSubview:notesTextView];
                [bgview addSubview:threeLinesLabel];
                notesTextView.tag = 12;
            }
        }
        
    }
}

-(void)checkclick: (UIButton*)sender
{
    //Show alert for missed fill-ups
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PFShowAlert"] || [[NSUserDefaults standardUserDefaults] objectForKey:@"PFShowAlert"]==nil)
    {
        
        //NSString *first_partial_click_msg = @"A partial tank fill-up is when the tank is not filled to the brim. The efficiency against this record will be shown as 'n/a' until a full tank fill-up is performed";
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"first_partial_click_msg", @"A partial tank fill-up is when the tank is not filled to the brim. The efficiency against this record will be shown as 'n/a' until a full tank fill-up is performed")
                                              message:@""
                                              preferredStyle:UIAlertControllerStyleAlert];
        //NSString *button_later_for_partial_click = @"Show again later";
        UIAlertAction *showAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"button_later_for_partial_click", @"Show again later")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PFShowAlert" ];
                                         
                                         
                                     }];
        
        //NSString *button_ok_for_tip = @"OK, thanks";
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"button_ok_for_tip", @"OK, thanks")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"PFShowAlert" ];
                                       
                                   }];
        [alertController addAction:okAction];
        [alertController addAction:showAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    if(sender.selected == YES)
    {
        
        sender.selected=NO;
        // NSLog(@"selected");
    }
    
    else
    {
        
        sender.selected=YES;
        
        
    }
    
}

-(void)doneWithNumberPad
{
    UITextField *odo = (UITextField *) [self.view viewWithTag:2];
    UITextField *qty = (UITextField *) [self.view viewWithTag:3];
    UITextField *price = (UITextField *) [self.view viewWithTag:6];
    UITextField *total = (UITextField *) [self.view viewWithTag:7];
    UITextField *octane = (UITextField *) [self.view viewWithTag:8];

    [odo resignFirstResponder];
    [qty resignFirstResponder];
    [price resignFirstResponder];
    [total resignFirstResponder];
    [octane resignFirstResponder];
}

-(void)openpicker:(UIButton *)btn
{
    //NIKHIL BUG_134 //added setbutton and _picker removeFromSuperview
    [_pic removeFromSuperview];
    [_picker removeFromSuperview];
    [_setbutton removeFromSuperview];
    
    _pic=[[UIDatePicker alloc] init];
    NSString *str;
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _pic.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _pic.backgroundColor=[self colorFromHexString:@"#edebeb"];
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_pic.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.frame;
    maskLayer.path = maskPath.CGPath;
    _pic.layer.mask = maskLayer;
    _pic.timeZone=[NSTimeZone localTimeZone];
    _pic.datePickerMode=UIDatePickerModeDate;
    str= NSLocalizedString(@"date_hint", @"Set Date");
    self.pickerval= NSLocalizedString(@"date", @"Date");
    
    UIView *topview = (UIView*)[self.view viewWithTag:-2];
    [topview addSubview:_pic];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_setbutton addTarget:self action:@selector(donelabel) forControlEvents:UIControlEventTouchUpInside];
    [topview addSubview:_setbutton];
    
    
    
}

-(void)donelabel
{
    //NSLog(@"pickerVal : %@", self.pickerval);
    if([self.pickerval isEqualToString:NSLocalizedString(@"date", @"Date")])
    {
        [self.setbutton removeFromSuperview];
        [self.pic removeFromSuperview];
        NSDateFormatter *f=[[NSDateFormatter alloc] init];
        [f setDateFormat:@"dd-MMM-yyyy"];
        NSString *date=[f stringFromDate:_pic.date];
        //NSLog(@"picker date....%@",[f stringFromDate:_pic.date]);
        UITextField *textfield = (UITextField *)[self.view viewWithTag:1];
        textfield.text = date;
        
    }
    
    else if([self.pickerval isEqualToString:@"Select"])
    {
        
        [self.setbutton removeFromSuperview];
        [self.picker removeFromSuperview];
        [self.pic removeFromSuperview];
        NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
        if([def boolForKey:@"editPageOpen"]){
            
            [def setObject:[def objectForKey:@"fillupid"] forKey:@"oldFillupid"];
            
        }
        
        NSDictionary *dictionary = [[NSDictionary alloc]init];
        dictionary = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
        // NSLog(@"id value for vehid %@",[dictionary objectForKey:@"Id"]);
        [[NSUserDefaults standardUserDefaults]setObject:[dictionary objectForKey:@"Id"] forKey:@"fillupid"];
        // [[NSUserDefaults standardUserDefaults]setObject:[dictionary objectForKey:@"Id"] forKey:@"idvalue"];
        
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"fillupmake"];
        UITextField *textfield = (UITextField *)[self.view viewWithTag:-9];
        textfield.text = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
        CGSize stringsize = [textfield.text sizeWithAttributes:@{NSFontAttributeName:textfield.font}];
        dropdown.frame=CGRectMake(stringsize.width+60, textfield.frame.origin.y+7, 40, 40);
        [def setObject:[dictionary objectForKey:@"Id"] forKey:@"idvalue"];
        [def setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"vehname"];
        [def setObject:[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"Id"]] forKey:@"fillupid"];
        [def setObject:[dictionary objectForKey:@"Picture"] forKey:@"vehimage"];
        
        //Call Method to refresh the Sorted Log
        
        LogViewController *lvc = [[LogViewController alloc] init];
        [lvc fetchallfillup];
        
        
        
        if([[[NSUserDefaults standardUserDefaults]objectForKey: @"copyvalues"]isEqualToString:@"copy"])
        {
            [self fetchfillup];
        }
        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
        {
            // NSLog(@"blank....");
            _vehimage.image=[UIImage imageNamed:@"car4.jpg"];
        }
        
        else
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            //Swapnil ENH_24
            self.urlstring = [paths firstObject];
            
            NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",self.urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
            _vehimage.image =[UIImage imageWithContentsOfFile:vehiclepic];
        }
        
        
        
        }else if([self.pickerval isEqualToString:@"UnitPicker"]){
        
            [self.setbutton removeFromSuperview];
            [self.picker removeFromSuperview];
            [self.pic removeFromSuperview];
            selectedUnit = [[NSString alloc]init];
            selectedUnit = [self.unitPickerArray objectAtIndex:[self.picker selectedRowInComponent:0]];
            //NSLog(@"SelectedUnit:- %@",selectedUnit);
            if(tempUnit != nil){
                if(tempUnit != selectedUnit){
                    if([selectedUnit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")] && [tempUnit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
                    {
                        UILabel *qtyUnitLabel = (UILabel *)[self.view viewWithTag:18];
                        qtyUnitLabel.text = NSLocalizedString(@"ltr", @"Ltr");
                        UITextField *text = [self.view viewWithTag:6];
                        text.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"ltr", @"Ltr")];

                        UILabel *label = [self.view viewWithTag:120];
                        label.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"ltr", @"Ltr")];
                        tempUnit = selectedUnit;
                    }
                    
                    else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")] && [tempUnit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
                    {
                        UILabel *qtyUnitLabel = (UILabel *)[self.view viewWithTag:18];
                        qtyUnitLabel.text = NSLocalizedString(@"ltr", @"Ltr");
                        UITextField *text = [self.view viewWithTag:6];
                        text.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"ltr", @"Ltr")];
                        UILabel *label = [self.view viewWithTag:120];
                        label.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"ltr", @"Ltr")];
                        tempUnit = selectedUnit;
                    }
                    
                    else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")] && [tempUnit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
                    {
                        UILabel *qtyUnitLabel = (UILabel *)[self.view viewWithTag:18];
                        qtyUnitLabel.text = NSLocalizedString(@"gal", @"gal");
                        UITextField *text = [self.view viewWithTag:6];
                        text.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"gal", @"gal")];
                        UILabel *label = [self.view viewWithTag:120];
                        label.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"gal", @"gal")];
                        tempUnit = selectedUnit;
                    }
                    
                    else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")] && [tempUnit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
                    {
                        UILabel *qtyUnitLabel = (UILabel *)[self.view viewWithTag:18];
                        qtyUnitLabel.text = NSLocalizedString(@"gal", @"gal");
                        UITextField *text = [self.view viewWithTag:6];
                        text.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"gal", @"gal")];
                        UILabel *label = [self.view viewWithTag:120];
                        label.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"gal", @"gal")];
                        tempUnit = selectedUnit;
                    }
                    
                    else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")] && [tempUnit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
                    {
                        tempUnit = selectedUnit;
                    }
                    
                    else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")] && [tempUnit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
                    {
                        tempUnit = selectedUnit;
                    }
                }
            }else{
                
                if([selectedUnit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
                {
                    UILabel *qtyUnitLabel = (UILabel *)[self.view viewWithTag:18];
                    qtyUnitLabel.text = NSLocalizedString(@"ltr", @"Ltr");
                    UITextField *text = [self.view viewWithTag:6];
                    text.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"ltr", @"Ltr")];
                    UILabel *label = [self.view viewWithTag:120];
                    label.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"ltr", @"Ltr")];
                    tempUnit = selectedUnit;
                }
                
                else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
                {
                    UILabel *qtyUnitLabel = (UILabel *)[self.view viewWithTag:18];
                    qtyUnitLabel.text = NSLocalizedString(@"ltr", @"Ltr");
                    UITextField *text = [self.view viewWithTag:6];
                    text.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"ltr", @"Ltr")];
                    UILabel *label = [self.view viewWithTag:120];
                    label.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"ltr", @"Ltr")];
                    tempUnit = selectedUnit;
                }
                
                else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
                {
                    UILabel *qtyUnitLabel = (UILabel *)[self.view viewWithTag:18];
                    qtyUnitLabel.text = NSLocalizedString(@"gal", @"gal");
                    UITextField *text = [self.view viewWithTag:6];
                    text.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"gal", @"gal")];
                    UILabel *label = [self.view viewWithTag:120];
                    label.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"gal", @"gal")];
                    tempUnit = selectedUnit;
                }
                
                else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
                {
                    UILabel *qtyUnitLabel = (UILabel *)[self.view viewWithTag:18];
                    qtyUnitLabel.text = NSLocalizedString(@"gal", @"gal");
                    UITextField *text = [self.view viewWithTag:6];
                    text.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"gal", @"gal")];
                    UILabel *label = [self.view viewWithTag:120];
                    label.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_per_unit_tv", @"Price/"), NSLocalizedString(@"gal", @"gal")];
                    tempUnit = selectedUnit;
                }
                
                else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
                {
                    tempUnit = selectedUnit;
                }
                
                else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
                {
                    tempUnit = selectedUnit;
                }
                
            }
            
        
        }else if([self.pickerval isEqualToString:@"CurrencyPicker"]){

            [self.setbutton removeFromSuperview];
            [self.picker removeFromSuperview];
            [self.pic removeFromSuperview];

            NSString *selectedCurr = [self.currencyPickerArray objectAtIndex:[self.picker selectedRowInComponent:0]];
            UILabel *priceUnitLabel = (UILabel *)[self.view viewWithTag:13];
            UILabel *totalUnitLabel = (UILabel *)[self.view viewWithTag:14];

            NSArray *array = [selectedCurr componentsSeparatedByString:@"-"];
            NSString *string = [array lastObject];
            priceUnitLabel.text = string;
            totalUnitLabel.text = string;
        }
}





-(void)buttonclick
{
    CustomiseViewController *custom = (CustomiseViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"customise"];
    custom.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:custom animated:YES];
}

- (void)pictureclick{
    
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:NSLocalizedString(@"cancel", @"Cancel")
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Take a new photo"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self takeNewPhotoFromCamera];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Choose from existing"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self choosePhotoFromExistingImages];
                              }];
    
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
    [self presentViewController:alert animated:YES completion:nil];
}



- (void)takeNewPhotoFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.allowsEditing = NO;
       // controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        
    }
}

-(void)choosePhotoFromExistingImages
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.allowsEditing = NO;
        //controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
   // UIImage *newimage = [[UIImage alloc]init];
    NSString *imageURLString = [[NSString alloc]init];

    //27022020 increased ratio from 320:480, as images were not clear testing
    UIImage *compressedImage = [[UIImage alloc] init];//[self scaleImage:image toSize:CGSizeMake(480.0,720.0)];

    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        imageURLString = @"PNG";

    }else{
        
       imageURLString = [NSString stringWithFormat:@"%@", [info valueForKey: UIImagePickerControllerReferenceURL]];
    }

    if ([imageURLString containsString:@"PNG"])
    {
        NSData *imageSizeData = UIImagePNGRepresentation(image);
        long imagesize = [imageSizeData length]/1024;

        if(imagesize  <1000){

            //27022020 increased ratio from 320:480, as images were not clear testing
            compressedImage = image;//[self scaleImage:image toSize:CGSizeMake(480.0,720.0)];

           // newimage = [image imageWithImage:image scaledToSize:CGSizeMake(image.size.width/3, image.size.height/3)];
           // imageData = UIImagePNGRepresentation(newimage);
           // NSString *ext = [self contentTypeForImageData:imageData];
            //NSLog(@"ext:- %@",ext);
        }
        else if (imagesize>1000 && imagesize <3000){

            //27022020 increased ratio from 320:480, as images were not clear testing
            compressedImage = [self scaleImage:image toSize:CGSizeMake(image.size.width/2, image.size.height/2)];
           // newimage = [image imageWithImage:image scaledToSize:CGSizeMake(image.size.width/4, image.size.height/4)];
           // imageData = UIImagePNGRepresentation(newimage);
           // NSString *ext = [self contentTypeForImageData:imageData];
            //NSLog(@"ext:- %@",ext);
        }

        else if (imagesize>3000){

            //27022020 increased ratio from 320:480, as images were not clear testing
            compressedImage = [self scaleImage:image toSize:CGSizeMake(image.size.width/4, image.size.height/4)];

           // newimage = [image imageWithImage:image scaledToSize:CGSizeMake(image.size.width/6, image.size.height/6)];
           // imageData = UIImagePNGRepresentation(newimage);
          //  NSString *ext = [self contentTypeForImageData:imageData];
            //NSLog(@"ext:- %@",ext);
        }
        
        if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            
            UIImageWriteToSavedPhotosAlbum(compressedImage, nil, nil, nil);
            
        }

        NSData *imageData = UIImagePNGRepresentation(compressedImage);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *UniqueName = [NSString stringWithFormat:@"image-%f",[[NSDate date] timeIntervalSince1970]];
        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.png",@"cached",UniqueName]];
        
        if (![imageData writeToFile:imagePath atomically:NO])
        {
            //NSLog((@"Failed to cache image data to disk"));
        }
        else
        {
            self.imagepath= [NSString stringWithFormat:@"cached%@.png",UniqueName];
            
        }
    //if([imageURLString containsString:@"JPG"])
    }else {
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0);
//        long imagesize = [imageData length]/1024;
//
//        if(imagesize <600){
//            newimage = [image imageWithImage:image scaledToSize:CGSizeMake(image.size.width/2, image.size.height/2)];
//            imageData = UIImageJPEGRepresentation(newimage, 0);
//            //NSString *ext = [self contentTypeForImageData:imageData];
//            //NSLog(@"ext:- %@",ext);
//        }
//        else if(imagesize>600 && imagesize <1000){
//            newimage = [image imageWithImage:image scaledToSize:CGSizeMake(image.size.width/3, image.size.height/3)];
//            imageData = UIImageJPEGRepresentation(newimage, 0);
//            //NSString *ext = [self contentTypeForImageData:imageData];
//            //NSLog(@"ext:- %@",ext);
//        }
//        else if (imagesize>1000 && imagesize <3000){
//            newimage = [image imageWithImage:image scaledToSize:CGSizeMake(image.size.width/4, image.size.height/4)];
//            imageData = UIImageJPEGRepresentation(newimage, 0);
//            //NSString *ext = [self contentTypeForImageData:imageData];
//            //NSLog(@"ext:- %@",ext);
//        }
//
//        else if (imagesize>3000){
//            newimage = [image imageWithImage:image scaledToSize:CGSizeMake(image.size.width/6, image.size.height/6)];
//            imageData = UIImageJPEGRepresentation(newimage, 0);
//            //NSString *ext = [self contentTypeForImageData:imageData];
//           // NSLog(@"ext:- %@",ext);
//        }
        
        if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            
            UIImageWriteToSavedPhotosAlbum(compressedImage, nil, nil, nil);
            
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *UniqueName = [NSString stringWithFormat:@"image-%f",[[NSDate date] timeIntervalSince1970]];
        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpg",@"cached",UniqueName]];
        
        if (![imageData writeToFile:imagePath atomically:NO])
        {
            NSLog((@"Failed to cache image data to disk"));
        }
        else
        {
            self.imagepath= [NSString stringWithFormat:@"cached%@.jpg",UniqueName];
            
        }
        
    }
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        
        UIImageWriteToSavedPhotosAlbum(compressedImage, nil, nil, nil);
        
    }
    [[NSUserDefaults standardUserDefaults]setObject:@"no" forKey:@"reloadtext"];
    [[NSUserDefaults standardUserDefaults]setObject:@"no" forKey:@"reloaddata"];
    if(self.imagepath != nil){
      [self.receiptImageArray addObject:self.imagepath];
    }
    
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
    [self.receiptCollectionView reloadData];
}

-(NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"jpg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
            
    }
    return nil;
}

-(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//ENH_57
#pragma mark - UICollectionView Delegate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.receiptImageArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ReceiptCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    //add_receipt
    UIImage *image;
    if(indexPath.row == self.receiptImageArray.count || self.receiptImageArray.count == 0){
        cell.backgroundColor=[UIColor clearColor];
        image = [UIImage imageNamed:@"add_receipt"];
    }else{
        //NSString *imageName;
        cell.backgroundColor=[UIColor clearColor];
        NSString *path = [self.receiptImageArray objectAtIndex:indexPath.row];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", path]];
        //NSLog(@"completeImgPath:- %@",completeImgPath);
        image = [UIImage imageWithContentsOfFile:completeImgPath];
    }
    cell.receiptImage.contentMode = UIViewContentModeScaleToFill;
    cell.receiptImage.clipsToBounds = YES;
    cell.receiptImage.frame = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
    cell.receiptImage.image = image;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

      return CGSizeMake(60, 70);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
    if(indexPath.row == self.receiptImageArray.count || self.receiptImageArray.count == 0){
        
        if(!proUser && self.receiptImageArray.count > 0){
            
            [self goProAlertBox];
        }else{
            
            [self pictureclick];
        }
    }else{
       
        //ENH_57  expandImage
        ReceiptViewController *receiptVC = [self.storyboard instantiateViewControllerWithIdentifier:@"receiptViewContoller"];
        receiptVC.receiptDelegate = self;
        receiptVC.receiptsArray = self.receiptImageArray;
        receiptVC.index = (int)indexPath.row;
        receiptVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:receiptVC animated:YES];

    }
    
}

-(void)sendDataToA:(NSMutableArray *)sendArray
{
    NSArray *copyArray = [[NSArray alloc] initWithArray:sendArray];
    [self.receiptImageArray removeAllObjects];
    [self.receiptImageArray addObjectsFromArray:copyArray];

}


#pragma mark - UITextView Delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    //NSLog(@"textViewShouldBeginEditing:");
    
    buttonOrigin = textView.frame.origin;
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    
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
    UITextView *notes = (UITextView *)[self.view viewWithTag:12];
    if(textView == notes){
        
        if([textView.text containsString:@","]){
            
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"comma_enter_err", @"Notes cannot accept commas") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textView.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textView.text = Stringval;
        }
    }
    
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    return YES;
    
}


-(void)textViewDidEndEditing:(UITextView *)textView{
[autocompletable removeFromSuperview];
[autocompletable1 removeFromSuperview];
[autocompletable2 removeFromSuperview];

[self.view setFrame:CGRectMake(self.view.frame.origin.x,0, self.view.frame.size.width, self.view.frame.size.height)];
    
        if([textView.text containsString:@","]){
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"comma_enter_err", @"Notes cannot accept commas and new lines") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textView.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textView.text = Stringval;
        }

}



#pragma mark - UITextField Delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [autocompletable removeFromSuperview];
    [autocompletable1 removeFromSuperview];
    [autocompletable2 removeFromSuperview];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextField *qty = (UITextField *) [self.view viewWithTag:3];
    UITextField *odo = (UITextField *) [self.view viewWithTag:2];
    UITextField *price = (UITextField *) [self.view viewWithTag:6];
    UITextField *total = (UITextField *) [self.view viewWithTag:7];
    
    UITextField *fuel = (UITextField *) [self.view viewWithTag:9];
    
    UITextField *filling = (UITextField *) [self.view viewWithTag:10];
    
    UITextField *octane = (UITextField *) [self.view viewWithTag:8];
    //UITextField *notes = (UITextField *)[self.view viewWithTag:12];
    UITextField *fuelbrand = (UITextField *)[self.view viewWithTag:9];

    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    [f setPositiveFormat:@"0.##"];
    //currencyfield vishay

    if((textField==price) || (textField==qty) || (textField==total)){

        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"autoAdd009"]  isEqual: @"YES"]){

            if (textField==price){

                priceFieldEdited = true;
                qtyFieldEdited = false;
                totalFieldEdited = false;
                NSString *givenString = textField.text;
                NSString *noNineString;
                if(givenString.length>0){

                    NSString *isNine = [givenString substringFromIndex: [givenString length] - 1];

                    if([isNine isEqual: @"9"]){

                        noNineString = [givenString substringToIndex:givenString.length-1];

                    }else{
                        noNineString = textField.text;
                    }
                }else{
                    noNineString = textField.text;
                }
                double currentValue = [self removeFormatPrice:noNineString];
                double cents = round(currentValue * 100.0f);

                if (([string isEqualToString:@"."]) && ((int)currentValue == 0)) {
                    cents = floor(cents * 100);
                } else if ([string length]) {
                    for (size_t i = 0; i < [string length]; i++) {
                        unichar c = [string characterAtIndex:i];
                        if (isnumber(c)) {
                            cents *= 10;
                            cents += c - '0';
                        }
                    }
                } else {
                    // back Space
                    cents = floor(cents / 10);
                }

                NSString *str = [NSString stringWithFormat:@"%f", cents];
                if ([str length] > 15) {
                    NSString *newStr = [str substringFromIndex:1];
                    cents = [newStr doubleValue];
                }

                NSString *resultString = [self addFormatPrice:[[NSString
                                                                stringWithFormat:@"%.2f", cents / 100.0f] doubleValue]];
                textField.text = [resultString stringByAppendingString:@"9"];

                NSLog(@"%@",textField.text);

                NSString *rString = textField.text;
                NSString * nrString = [rString substringFromIndex:2];
                NSLog(@"%@",nrString);
                if (qty.text.length>0 && [qty.text floatValue] != 0.0){

                    NSNumber *totalvalue = [NSNumber numberWithFloat:([qty.text floatValue] * [nrString floatValue])];

                    NSLog(@"%@",totalvalue);
                    total.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];
                }
                //Kept commented code if requires in future
//                double currenttValue = [self removeFormatPrice:textField.text];
//                NSString *removedCurrString = [NSString stringWithFormat:@"%.3f",currenttValue];
//
//                NSLog(@"Current Value is :- %@",removedCurrString);
//                textField.text = removedCurrString;
//
//                if([removedCurrString floatValue] != 0.0){
//
//                    if (qty.text.length>0 && [qty.text floatValue] != 0.0){
//
//                        NSNumber *totalvalue = [NSNumber numberWithFloat:([qty.text floatValue] * [removedCurrString floatValue])];
//
//                        total.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];
//
//                    }else if (total.text.length>0 && [total.text floatValue] != 0.0){
//
//                        NSNumber *totalvalue = [NSNumber numberWithFloat:([total.text floatValue] / [removedCurrString floatValue])];
//
//                        qty.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];
//
//                    }
//                }
                return NO;

            }else if(textField==qty) {

                priceFieldEdited = false;
                qtyFieldEdited = true;
                totalFieldEdited = false;
                if (qty.text.length>0 && [qty.text floatValue] != 0.0){

                    if (price.text.length>0 && [price.text floatValue] != 0.0){

                        NSString *value =[qty.text stringByReplacingCharactersInRange:range withString:string];

                        NSNumber *totalvalue = [NSNumber numberWithFloat:([value floatValue] * [price.text floatValue])];

                        total.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];

                    }else if (total.text.length>0 && [total.text floatValue] != 0.0){

                        NSNumber *totalvalue = [NSNumber numberWithFloat:([total.text floatValue] / [qty.text floatValue])];

                        price.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];

                    }

                }
                if([textField.text containsString:@","]){
                    NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
                    textField.text = Stringval;
                }

                //[self doneWithNumberPad];
                return YES;

            }else if(textField==total){

                priceFieldEdited = false;
                qtyFieldEdited = false;
                totalFieldEdited = true;

                if (total.text.length>0 && [total.text floatValue] != 0.0){

                    if (qty.text.length>0 && [qty.text floatValue] != 0.0){

                        NSString *value =[total.text stringByReplacingCharactersInRange:range withString:string];

                        NSNumber *totalvalue = [NSNumber numberWithFloat:([value floatValue] / [qty.text floatValue])];
                        price.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];

                    }else if (price.text.length>0 && [price.text floatValue] != 0.0){

                        NSNumber *totalvalue = [NSNumber numberWithFloat:([total.text floatValue] / [price.text floatValue])];

                        qty.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];

                    }

                }

                if([textField.text containsString:@","]){
                    NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
                    textField.text = Stringval;
                }
                //[self doneWithNumberPad];
                return YES;

            }else{

                return YES;
            }

        }else{

            if(textField==price){
                priceFieldEdited = true;
                qtyFieldEdited = false;
                totalFieldEdited = false;
                if (qty.text.length>0 && [qty.text floatValue] != 0.0){

                    NSString *value =[price.text stringByReplacingCharactersInRange:range withString:string];
                    NSNumber *totalvalue = [NSNumber numberWithFloat:([qty.text floatValue] * [value floatValue])];
                    //NSNumber *totalvalue = [NSNumber numberWithFloat:([qty.text floatValue] * [price.text floatValue])];

                    total.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];

                }else if (total.text.length>0 && [total.text floatValue] != 0.0){

                    NSNumber *totalvalue = [NSNumber numberWithFloat:([total.text floatValue] / [price.text floatValue])];

                    qty.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];

                }

            }else if(textField==qty){

                priceFieldEdited = false;
                qtyFieldEdited = true;
                totalFieldEdited = false;
                if (qty.text.length>0 && [qty.text floatValue] != 0.0){

                    if (price.text.length>0 && [price.text floatValue] != 0.0){

                        NSString *value =[qty.text stringByReplacingCharactersInRange:range withString:string];
                        NSNumber *totalvalue = [NSNumber numberWithFloat:([value floatValue] * [price.text floatValue])];

                        total.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];

                    }else if (total.text.length>0 && [total.text floatValue] != 0.0){

                        NSNumber *totalvalue = [NSNumber numberWithFloat:([total.text floatValue] / [qty.text floatValue])];

                        price.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];

                    }

                }
            }else if(textField == total)
            {
                priceFieldEdited = false;
                qtyFieldEdited = false;
                totalFieldEdited = true;
                if (total.text.length>0 && [total.text floatValue] != 0.0){

                    if (qty.text.length>0 && [qty.text floatValue] != 0.0){

                        NSString *value =[total.text stringByReplacingCharactersInRange:range withString:string];
                        NSNumber *totalvalue = [NSNumber numberWithFloat:([value floatValue] / [qty.text floatValue])];

                        price.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];

                    }else if (price.text.length>0 && [price.text floatValue] != 0.0){

                        NSNumber *totalvalue = [NSNumber numberWithFloat:([total.text floatValue] / [price.text floatValue])];

                        qty.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];

                    }

                }

            }
            if([textField.text containsString:@","]){
                NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
                textField.text = Stringval;
            }
            //[self doneWithNumberPad];
            return YES;
        }

    }else{

        if(textField==odo || textField == octane)
        {
            if([textField.text containsString:@","]){
                NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
                textField.text = Stringval;
            }
        }

        if(textField==fuel)
        {
            //NSLog(@"called.....");
            UIView *view1 = (UIView *)[self.view viewWithTag:-2];
            [autocompletable removeFromSuperview];
            autocompletable = [[UITableView alloc] initWithFrame:
                               CGRectMake(0, 350, 320, 120) style:UITableViewStylePlain];
            autocompletable.delegate = self;
            autocompletable.dataSource = self;
            autocompletable.scrollEnabled = YES;
            autocompletable.hidden = YES;
            [view1 addSubview:autocompletable];
            //[self.view insertSubview:autocompletable aboveSubview:self.sc]

            NSString *substring = [NSString stringWithString:textField.text];
            substring = [substring
                         stringByReplacingCharactersInRange:range withString:string];
            [self searchAutocompleteEntriesWithSubstring:substring];
        }

        if(textField==filling)
        {
            UIView *view1 = (UIView *)[self.view viewWithTag:-2];
            [autocompletable1 removeFromSuperview];
            autocompletable1 = [[UITableView alloc] initWithFrame:
                                CGRectMake(0, 400, 320, 120) style:UITableViewStylePlain];
            autocompletable1.delegate = self;
            autocompletable1.dataSource = self;
            autocompletable1.scrollEnabled = YES;
            autocompletable1.hidden = YES;
            [view1 addSubview:autocompletable1];
            //[self.view insertSubview:autocompletable aboveSubview:self.sc]

            NSString *substring = [NSString stringWithString:textField.text];
            substring = [substring
                         stringByReplacingCharactersInRange:range withString:string];
            [self searchAutocompleteEntriesWithSubstring1:substring];

        }

        if(textField==octane)
        {
            UIView *view1 = (UIView *)[self.view viewWithTag:-2];
            [autocompletable2 removeFromSuperview];
            autocompletable2 = [[UITableView alloc] initWithFrame:
                                CGRectMake(0, 300, 320, 120) style:UITableViewStylePlain];
            autocompletable2.delegate = self;
            autocompletable2.dataSource = self;
            autocompletable2.scrollEnabled = YES;
            autocompletable2.hidden = YES;
            [view1 addSubview:autocompletable2];
            //[self.view insertSubview:autocompletable aboveSubview:self.sc]

            NSString *substring = [NSString stringWithString:textField.text];
            substring = [substring
                         stringByReplacingCharactersInRange:range withString:string];
            // NSLog(@"substring value %@",substring);
            [self searchAutocompleteEntriesWithSubstring2:substring];

        }


        //            if(textField==price)
        //            {
        //
        //                NSString *value =[price.text stringByReplacingCharactersInRange:range withString:string];
        //                NSNumber *totalvalue = [NSNumber numberWithFloat:([qty.text floatValue] * [value floatValue])];
        //
        //                total.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];
        //                if([total.text containsString:@","]){
        //                    NSString *Stringval = [total.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
        //                    total.text = Stringval;
        //                }
        //                UILabel *label = (UILabel *)[total viewWithTag:140];
        //                [self labelanimatetoshow:label];
        //
        //            }

        //        if(textField==qty)
        //        {
        //            NSNumberFormatter * ft = [[NSNumberFormatter alloc] init];
        //            [ft setNumberStyle:NSNumberFormatterDecimalStyle];
        //            [ft setPositiveFormat:@"0.###"];//NIKHIL BUG_124 changed format
        //
        //            NSString *value =[qty.text stringByReplacingCharactersInRange:range withString:string];
        //            NSNumber *totalvalue = [NSNumber numberWithFloat:([price.text floatValue] * [value floatValue])];
        //            // NSLog(@"....value...%@",[NSNumber numberWithFloat:[totalvalue floatValue]]);
        //            if([[NSNumber numberWithFloat:[totalvalue floatValue]]floatValue]!=0)
        //            {
        //                total.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];
        //                UILabel *label = (UILabel *)[total viewWithTag:120];
        //                [self labelanimatetoshow:label];
        //            }
        //
        //        }
        //
        //        if(textField==total)
        //        {
        //            NSNumberFormatter * ft = [[NSNumberFormatter alloc] init];
        //            [ft setNumberStyle:NSNumberFormatterDecimalStyle];
        //            [ft setPositiveFormat:@"0.###"];
        //
        //            NSString *value =[total.text stringByReplacingCharactersInRange:range withString:string];
        //
        //            if([value floatValue]!=0 && [price.text floatValue]!=0 && [qty.text floatValue]==0)
        //            {
        //                NSNumber *totalvalue = [NSNumber numberWithFloat:([value floatValue]/ [price.text floatValue])];
        //
        //                qty.text = [f stringFromNumber:[NSNumber numberWithFloat:[totalvalue floatValue]]];
        //                UILabel *label = (UILabel *)[qty viewWithTag:60];
        //                [self labelanimatetoshow:label];
        //            }
        //
        //            if([qty.text floatValue]!=0 && [value floatValue]!=0 && [total.text floatValue]!=0)
        //            {
        //                NSNumber *totalvalue1 = [NSNumber numberWithFloat:( [value floatValue] / [qty.text floatValue])];
        //                //NIKHIL BUG_124 //Added formatter ft to make 3 decimals
        //                price.text = [ft stringFromNumber:[NSNumber numberWithFloat:[totalvalue1 floatValue]]];
        //
        //                if([price.text containsString:@","]){
        //                    NSString *Stringval = [price.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
        //                    price.text = Stringval;
        //                }
        //                UILabel *label1 = (UILabel *)[price viewWithTag:120];
        //                [self labelanimatetoshow:label1];
        //            }
        //        }

        if(textField == fuelbrand){

            if([fuelbrand.text containsString:@","]){

                UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"fb_tv", @"Fuel Brand"), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

                }];
                [alertControl addAction:ok];
                [self presentViewController:alertControl animated:YES completion:nil];
                NSString *Stringval = [fuelbrand.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                fuelbrand.text = Stringval;
            }
        }

        if(textField == filling){

            if([filling.text containsString:@","]){

                UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"fs_tv", @"Filling Station"), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

                }];
                [alertControl addAction:ok];
                [self presentViewController:alertControl animated:YES completion:nil];
                NSString *Stringval = [filling.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                filling.text = Stringval;
            }
        }

        return YES;

    }

}

-(NSString*)addFormatPrice:(double)dblPrice {
    NSNumber *temp = [NSNumber numberWithDouble:dblPrice];
    NSDecimalNumber *someAmount = [NSDecimalNumber decimalNumberWithDecimal:
                                   [temp decimalValue]];
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    return [currencyFormatter stringFromNumber:someAmount];
}

-(double)removeFormatPrice:(NSString *)strPrice {
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber* number = [currencyFormatter numberFromString:strPrice];
    return [number doubleValue];
}

//NIKHIL BUG_125 //added below method
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    currentField = textField;
    buttonOrigin = currentField.frame.origin;
    
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if(textField.tag==8 || textField.tag == 9 || textField.tag ==7 )//|| textField.tag==11)
    {
        if(self.result.height==480)
        {
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-180, self.view.frame.size.width, self.view.frame.size.height)];
            
        }
        else
        {
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-150, self.view.frame.size.width, self.view.frame.size.height)];
        }
    }
    
    if(textField.tag==10)
    {
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-180, self.view.frame.size.width, self.view.frame.size.height)];
        
    }
    
    if(textField.tag==1)
    {
        
        UILabel *label = (UILabel *)[textField viewWithTag:20];
        [self labelanimatetoshow:label];
        textField.placeholder=@"";
    }
    
    if(textField.tag==2)
    {
        [self paddingTextFields:textField];
        UILabel *label = (UILabel *)[textField viewWithTag:40];
        [self labelanimatetoshow:label];
        textField.placeholder=@"";
        
    }
    
    if(textField.tag==3)
    {
        [self paddingTextFields:textField];
        UILabel *label = (UILabel *)[textField viewWithTag:60];
        [self labelanimatetoshow:label];
        textField.placeholder=@"";
        
    }
    
    if(textField.tag==6)
    {
        [self paddingTextFields:textField];
        UILabel *label = (UILabel *)[textField viewWithTag:120];
        [self labelanimatetoshow:label];
        textField.placeholder=@"";
        
    }
    
    if(textField.tag==7)
    {
        [self paddingTextFields:textField];
        UILabel *label = (UILabel *)[textField viewWithTag:140];
        [self labelanimatetoshow:label];
        textField.placeholder=@"";
        
    }
    
    if(textField.tag==8)
    {
        [self paddingTextFields:textField];
        UILabel *label = (UILabel *)[textField viewWithTag:160];
        [self labelanimatetoshow:label];
        textField.placeholder=@"";
        
    }
    
    if(textField.tag==9)
    {
        [self paddingTextFields:textField];
        UILabel *label = (UILabel *)[textField viewWithTag:180];
        [self labelanimatetoshow:label];
        textField.placeholder=@"";
        
    }
    
    if(textField.tag==10)
    {
        [self paddingTextFields:textField];
        UILabel *label = (UILabel *)[textField viewWithTag:200];
        [self labelanimatetoshow:label];
        textField.placeholder=@"";
        
    }
    
}


- (void) paddingTextFields: (UITextField *)textField{
    
    UIView *padding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4.8, 20)];
    textField.leftView = padding;
    textField.leftViewMode = UITextFieldViewModeAlways;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    [autocompletable removeFromSuperview];
    [autocompletable1 removeFromSuperview];
    [autocompletable2 removeFromSuperview];
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x,0, self.view.frame.size.width, self.view.frame.size.height)];
    if(textField.tag==1)
    {
        if(textField.text.length==0)
        {
            UILabel *label = (UILabel *)[textField viewWithTag:20];
            [self labelanimatetohide:label];
            
            textField.placeholder=NSLocalizedString(@"date", @"Date");
        }
    }
    if(textField.tag==2 )
    {
        [self paddingTextFields:textField];
        //Changed the object type bcuz it is causing langaue issues
        if(textField.text.length==0)
        {
            UILabel *label = (UILabel *)[textField viewWithTag:40];
            [self labelanimatetohide:label];
//            if([[[NSUserDefaults standardUserDefaults]objectForKey:@"filluptype"]isEqualToString:NSLocalizedString(@"trp", @"Trip")])
            if([[[NSUserDefaults standardUserDefaults]objectForKey:@"filluptype"]isEqualToString:@"Trip"])
            {
                //NSString *trp = @"Trip";
                textField.placeholder = NSLocalizedString(@"trp", @"Trip");
            }
            else
            {
                textField.placeholder=NSLocalizedString(@"odometer", @"Odometer");
            }
        }
        
    }
    
    
    
    if(textField.tag==3)
    {
        [self paddingTextFields:textField];
        if(textField.text.length==0)
        {
            UILabel *label = (UILabel *)[textField viewWithTag:60];
            [self labelanimatetohide:label];
            textField.placeholder= NSLocalizedString(@"qty_required", @"Qty");
        }
    }
    
    
    if(textField.tag==6)
    {
        [self paddingTextFields:textField];
        if(textField.text.length==0)
        {
            UILabel *label = (UILabel *)[textField viewWithTag:120];
            [self labelanimatetohide:label];
            
            //NSString *prc_per_unt = @"Price/Unit";
            textField.placeholder=NSLocalizedString(@"prc_per_unt", @"Price/Unit");
        }
    }
    
    if(textField.tag==7)
    {
        [self paddingTextFields:textField];
        if(textField.text.length==0)
        {
            UILabel *label = (UILabel *)[textField viewWithTag:140];
            [self labelanimatetohide:label];
            
            //NSString *tc_tv = @"Total Cost";
            textField.placeholder=NSLocalizedString(@"tc_tv", @"Total Cost");
        }
        
        else{
            [self paddingTextFields:textField];
            textField.text = [NSString stringWithFormat:@"%.2f",[textField.text floatValue]];
        }
    }
    
    if(textField.tag==8)
    {
        [self paddingTextFields:textField];
        if(textField.text.length==0)
        {
            UILabel *label = (UILabel *)[textField viewWithTag:160];
            [self labelanimatetohide:label];
            
            textField.placeholder=NSLocalizedString(@"octane", @"Octane");
        }
    }
    
    if(textField.tag==9)
    {
        [self paddingTextFields:textField];
        if(textField.text.length==0)
        {
            UILabel *label = (UILabel *)[textField viewWithTag:180];
            [self labelanimatetohide:label];
            
            //NSString *fb_tv = @"Fuel Brand";
            textField.placeholder=NSLocalizedString(@"fb_tv", @"Fuel Brand");
        }
        
        if([textField.text containsString:@","]){
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"fb_tv", @"Fuel Brand"), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
        
        
    }
    
    if(textField.tag==10 )
    {
        [self paddingTextFields:textField];
        if(textField.text.length==0)
        {
            UILabel *label = (UILabel *)[textField viewWithTag:200];
            [self labelanimatetohide:label];
            
            //NSString *fs_tv = @"Filling station";
            textField.placeholder=NSLocalizedString(@"fs_tv", @"Filling station");
        }
        
        if([textField.text containsString:@","]){
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"fs_tv", @"Filling station"), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
        
    }
    
}


-(void)textfieldsetting: (UITextField *)textfield
{
   
   // [textfield setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    NSMutableAttributedString *placeholderAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:textfield.attributedPlaceholder];
    [placeholderAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [placeholderAttributedString length])];
    textfield.attributedPlaceholder = placeholderAttributedString;
}


- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    autocompletearray =[[NSMutableArray alloc]init];
    [autocompletearray removeAllObjects];
    for(NSString *curString in self.fuelarray) {
        NSRange substringRange = [[NSString stringWithFormat:@"%@",curString]rangeOfString:substring];
        if (substringRange.location == 0) {
            autocompletable.hidden=NO;
            [autocompletearray addObject:curString];
        }
    }
    [autocompletable reloadData];
}


- (void)searchAutocompleteEntriesWithSubstring1:(NSString *)substring {
    
    autocompletearray =[[NSMutableArray alloc]init];
    [autocompletearray removeAllObjects];
    for(NSString *curString in self.fillingarray) {
        NSRange substringRange = [[NSString stringWithFormat:@"%@",curString]rangeOfString:substring];
        if (substringRange.location == 0) {
            autocompletable1.hidden=NO;
            [autocompletearray addObject:curString];
        }
    }
    [autocompletable1 reloadData];
}


- (void)searchAutocompleteEntriesWithSubstring2:(NSString *)substring {
    
    autocompletearray =[[NSMutableArray alloc]init];
    [autocompletearray removeAllObjects];
    for(NSString *curString in self.octanearray) {
        NSRange substringRange = [[NSString stringWithFormat:@"%@",curString]rangeOfString:substring];
        if (substringRange.location == 0) {
            autocompletable2.hidden=NO;
            [autocompletearray addObject:curString];
            //NSLog(@"array of curl %@",autocompletearray);
            
        }
    }
    [autocompletable2 reloadData];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return autocompletearray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] ;
        
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[autocompletearray objectAtIndex:indexPath.row]];
    // cell.textLabel.textColor =[UIColor blackColor];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if(tableView==autocompletable)
    {
        UITextField *fuel = (UITextField *) [self.view viewWithTag:9];
        
        fuel.text = [NSString stringWithFormat:@"%@",[autocompletearray objectAtIndex:indexPath.row]];
        [autocompletable removeFromSuperview];
    }
    
    if(tableView==autocompletable1)
    {
        UITextField *fill = (UITextField *) [self.view viewWithTag:10];
        
        fill.text = [NSString stringWithFormat:@"%@",[autocompletearray objectAtIndex:indexPath.row]];
        [autocompletable1 removeFromSuperview];
    }
    
    if(tableView==autocompletable2)
    {
        UITextField *octane = (UITextField *) [self.view viewWithTag:8];
        
        octane.text = [NSString stringWithFormat:@"%@",[autocompletearray objectAtIndex:indexPath.row]];
        [autocompletable2 removeFromSuperview];
    }
    
}



//NIKHIL BUG_125 //added methods to focus on textfield
#pragma mark Numeric Keyboard methods

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    //Get old offset
    
    oldY = scrollview.contentOffset.y;
    oldX = scrollview.contentOffset.x;
    
    
    CGFloat buttonHeight = currentField.frame.size.height;
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= (keyboardSize.height + 66);
    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
        
        
        [scrollview setContentOffset:scrollPoint animated:YES];
        //NSLog(@"scrollPoint Coordinates is %@",NSStringFromCGPoint( scrollPoint));
        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    //[self.scrollView setContentOffset:CGPointZero animated:YES];
    [scrollview setContentOffset: CGPointMake(oldX, oldY+ 1) animated:YES];
    
}

-(void)labelanimatetoshow: (UIView *)view {
    
    [UIView transitionWithView:view
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    view.hidden = NO;
}

-(void)labelanimatetohide: (UIView *)view

{
    
    [UIView transitionWithView:view
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    view.hidden = YES;
}

-(void)backbuttonclick
{
    // [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
    
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    
    UITextField *qty = (UITextField *)[self.view viewWithTag:3];
    
    //  NSLog(@"[NSUserDefaults standardUserDefaults]objectForKey:@editdetails]: %@", [[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSObject * object = [prefs objectForKey:@"editdetails"];
    if(object != nil){
        //Edit
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (odometer.text.length > 0 && qty.text.length > 0 )
    {
        //Check if user wants to exit
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Exit without saving?"
                                              message:@"Are you sure you want to exit without saving?"
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *saveAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"save", @"Save action")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         [self savefillup];
                                     }];
        UIAlertAction *dntSaveAction = [UIAlertAction
                                        actionWithTitle:NSLocalizedString(@"no_save", @"Don't Save action")
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action)
                                        {
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                            
                                        }];
        [alertController addAction:saveAction];
        [alertController addAction:dntSaveAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];
    
    
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
    
    
    
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



- (void) checkMissedFillUp:(UIButton*)sender
{
    // Set Button state with tag 2000
    if(sender.selected == YES)
    {   sender.selected=NO;
        // NSLog(@"selected");
    }
    else
    {
        sender.selected=YES;
    }
    
    
    //Show alert for missed fill-ups
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MFUShowAlert"] || [[NSUserDefaults standardUserDefaults] objectForKey:@"MFUShowAlert"]==nil)
    {
        
        //NSString *first_missed_fu_click_msg = @"Select this option if you have missed one or more of your previous fill-ups and don't want it to affect your fuel efficiency";
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"first_missed_fu_click_msg", @"Select this option if you have missed one or more of your previous fill-ups and don't want it to affect your fuel efficiency")
                                              message:@""
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        //NSString *button_later_for_partial_click = @"Show again later";
        UIAlertAction *showAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"button_later_for_partial_click", @"Show again later")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MFUShowAlert" ];
                                         
                                         
                                     }];
        //NSString *button_ok_for_tip = @"OK, thanks";
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"button_ok_for_tip", @"OK, thanks")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MFUShowAlert" ];
                                       
                                   }];
        [alertController addAction:okAction];
        [alertController addAction:showAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    
}

-(void)fetchdata
{
    self.vehiclearray =[[NSMutableArray alloc]init];
 
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSError *err;
    NSArray *data=[contex executeFetchRequest:requset error:&err];
    
    for(Veh_Table *vehicle in data)
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:vehicle.make forKey:@"Make"];
        [dictionary setObject:vehicle.model forKey:@"Model"];
        [dictionary setObject:vehicle.iD forKey:@"Id"];
        if(vehicle.picture!=nil)
        {
            [dictionary setObject:vehicle.picture forKey:@"Picture"];
        }
        else
        {
            
            [dictionary setObject:@"" forKey:@"Picture"];
            
        }
        if(vehicle.lic!=nil)
        {
            [dictionary setObject:vehicle.lic forKey:@"Lic"];
        }
        else
        {
            
            [dictionary setObject:@"" forKey:@"Lic"];
        }
        if(vehicle.vin!=nil)
        {
            [dictionary setObject:vehicle.vin forKey:@"Vin"];
        }
        else
        {
            [dictionary setObject:@"" forKey:@"Vic"];
        }
        if(vehicle.year!=nil)
        {
            [dictionary setObject:vehicle.year forKey:@"Year"];
        }
        else
        {
            
            [dictionary setObject:@"" forKey:@"Year"];
        }
        [self.vehiclearray addObject:dictionary];
    }
    
}

//Copy values from previous Fill-up
-(void)fetchfillup
{
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    // NSLog(@"compare %@",comparestring);
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    // NSLog(@"compare string %@",comparestring);
    
    //Swapnil BUG_90
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND type == 0",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    T_Fuelcons *fetchdata = [datavalue lastObject];
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    UILabel *label = (UILabel *)[self.view viewWithTag:40];
    UITextField *qty = (UITextField *)[self.view viewWithTag:3];
    UILabel *label1 = (UILabel *)[self.view viewWithTag:60];
    //Changed the object type bcuz it is causing langaue issues
   // if( [[Def objectForKey:@"filluptype"]isEqualToString:NSLocalizedString(@"trp", @"Trip")])
    if( [[Def objectForKey:@"filluptype"]isEqualToString:@"Trip"])
    {
        odometer.text=[fetchdata.dist stringValue];
    }
    else
    {
        odometer.text=[fetchdata.odo stringValue];
    }
    UITextField *price = (UITextField *)[self.view viewWithTag:6];

    qty.text =[fetchdata.qty stringValue];
    
    UITextField *total = (UITextField *)[self.view viewWithTag:7];
    UILabel *label2 = (UILabel *)[self.view viewWithTag:120];
    UILabel *label3 = (UILabel *)[self.view viewWithTag:140];
    
    //Swapnil BUG_90
    total.text = [fetchdata.cost stringValue];
    UIButton *pbutton  = (UIButton *)[self.view viewWithTag:1000];
    UIButton *mbutton  = (UIButton *)[self.view viewWithTag:2000];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    [f setPositiveFormat:@"0.##"];
    
    //Swapnil BUG_90
    if([total.text floatValue]!=0  && [qty.text floatValue]!=0)
    {
        NSNumber *pricePerLtr = [NSNumber numberWithFloat:([total.text floatValue] / [qty.text floatValue])];
        price.text = [f stringFromNumber:[NSNumber numberWithFloat:[pricePerLtr floatValue]]];
        UILabel *label1 = (UILabel *)[self.view viewWithTag:140];
        [self labelanimatetoshow:label1];
    }
    
    else
    {
        UILabel *label1 = (UILabel *)[self.view viewWithTag:140];
        [self labelanimatetohide:label1];
        total.text=@"";
    }
    
    if([fetchdata.octane floatValue]>0)
    {
        UITextField *octane = (UITextField *)[self.view viewWithTag:8];
        octane.text = [fetchdata.octane stringValue];
        UILabel *label2 = (UILabel *)[self.view viewWithTag:160];
        [self labelanimatetoshow:label2];
        
    }
    
    else
    {
        UILabel *label2 = (UILabel *)[self.view viewWithTag:160];
        //[self labelanimatetoshow:label2];
        [self labelanimatetohide:label2];
    }
    
    if(fetchdata.fuelBrand.length>0)
    {
        UITextField *fuelbrand = (UITextField *)[self.view viewWithTag:9];
        fuelbrand.text = fetchdata.fuelBrand;
        UILabel *label2 = (UILabel *)[self.view viewWithTag:180];
        [self labelanimatetoshow:label2];
        
    }
    
    else
    {
        UILabel *label2 = (UILabel *)[self.view viewWithTag:180];
        //[self labelanimatetoshow:label2];
        [self labelanimatetohide:label2];
    }
    
    
    if(fetchdata.fillStation.length>0)
    {
        UITextField *fuelbrand = (UITextField *)[self.view viewWithTag:10];
        fuelbrand.text = fetchdata.fillStation;
        UILabel *label2 = (UILabel *)[self.view viewWithTag:200];
        [self labelanimatetoshow:label2];
        
    }
    else
    {
        UILabel *label2 = (UILabel *)[self.view viewWithTag:200];
        //[self labelanimatetoshow:label2];
        [self labelanimatetohide:label2];
    }
    
    
    
    if(fetchdata.notes.length>0)
    {
        UITextView *fuelbrand = (UITextView *)[self.view viewWithTag:12];
        fuelbrand.text = fetchdata.notes;
        UILabel *label2 = (UILabel *)[self.view viewWithTag:220];
        [self labelanimatetoshow:label2];
        
    }
    
    else
    {
        UILabel *label2 = (UILabel *)[self.view viewWithTag:220];
        //[self labelanimatetoshow:label2];
        [self labelanimatetohide:label2];
    }
    
    //Swapnil BUG_90
    if([fetchdata.pfill isEqual:@1]){
        
        pbutton.selected = YES;
    }
    
    //Swapnil BUG_90
    if([fetchdata.mfill isEqual:@1]){
        
        mbutton.selected = YES;
    }
    
    if(total.text.length>0)
    {
        [self labelanimatetoshow:label3];
    }
    
    
    else
    {
        [self labelanimatetohide:label3];
    }
    
    if(qty.text.length>0)
    {
        [self labelanimatetoshow:label1];
    }
    
    else
    {
        [self labelanimatetohide:label1];
    }
    
    if(odometer.text.length>0)
    {
        [self labelanimatetoshow:label];
    }
    
    else
    {
        [self labelanimatetohide:label];
    }
    
    if(price.text.length>0)
    {
        [self labelanimatetoshow:label2];
    }
    else
    {
        [self labelanimatetohide:label2];
    }
    
    
}


-(void)fetchprevfuel
{
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    // NSLog(@"compare %@",comparestring);
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    // NSLog(@"compare string %@",comparestring);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    self.fuelarray=[[NSMutableArray alloc]init];
    self.octanearray=[[NSMutableArray alloc]init];
    self.fillingarray = [[NSMutableArray alloc]init];
    
    for(T_Fuelcons *fuel in datavalue)
    {
        if(![self.fuelarray containsObject:fuel.fuelBrand] && fuel.fuelBrand!=nil)
        {
            [self.fuelarray addObject:fuel.fuelBrand];
        }
        
        if(![self.octanearray containsObject:fuel.octane]&& fuel.octane!=nil)
        {
            [self.octanearray addObject:fuel.octane];
        }
        
        if(![self.fillingarray containsObject:fuel.fillStation] && fuel.fillStation!=nil)
        {
            [self.fillingarray addObject:fuel.fillStation];
        }
        
        
    }
    
}

-(void)openUnitPicker{
    
    BOOL proUser = [[NSUserDefaults standardUserDefaults]boolForKey:@"isAdDisabled"];
    
    if(proUser){
        
        [_picker removeFromSuperview];
        [_pic removeFromSuperview];
        [_setbutton removeFromSuperview];
        
        _picker = [[UIPickerView alloc]init];
        AppDelegate *App = [AppDelegate sharedAppDelegate];
        _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
        _picker.backgroundColor=[UIColor grayColor];
        
        _picker.clipsToBounds=YES;
        _picker.delegate =self;
        _picker.dataSource=self;
        _picker.tag=-10;
        
        //NIKHIL BUG_131 //added below line
        NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
        int picRowId = (int)[setRowValue integerForKey:@"rowValue"];
        [_picker selectRow:picRowId inComponent:0 animated:NO];
        self.pickerval = @"UnitPicker";
        
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:_picker.bounds
                                         byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                               cornerRadii:CGSizeMake(5.0, 5.0)];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.view.frame;
        maskLayer.path = maskPath.CGPath;
        _picker.layer.mask = maskLayer;
        
        
        UIView *topview = (UIView*)[self.view viewWithTag:-2];
        [topview addSubview:_picker];
        _setbutton =[[UIButton alloc]init];
        _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
        [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
        [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
        [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_setbutton addTarget:self action:@selector(donelabel) forControlEvents:UIControlEventTouchUpInside];
        [topview addSubview:_setbutton];
    
    }else{
      
        [self showAlert:NSLocalizedString(@"fillup_unit_change_title", @"Change Unit for Individual Fill-up") message:NSLocalizedString(@"fillup_unit_change_msg", @"Changing units for individual fill-ups is a part of the upgraded version.\n\nIn the free version you can change the default unit for the app, from Settings.")];
    }

}

-(void)openCurrencyPicker{

    BOOL proUser = [[NSUserDefaults standardUserDefaults]boolForKey:@"isAdDisabled"];

    if(proUser){

        [_picker removeFromSuperview];
        [_pic removeFromSuperview];
        [_setbutton removeFromSuperview];

        _picker = [[UIPickerView alloc]init];
        AppDelegate *App = [AppDelegate sharedAppDelegate];
        _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
        _picker.backgroundColor=[UIColor grayColor];

        _picker.clipsToBounds=YES;
        _picker.delegate =self;
        _picker.dataSource=self;
        _picker.tag=-11;

        //NIKHIL BUG_131 //added below line
        NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
        int picRowId = (int)[setRowValue integerForKey:@"rowValue"];
        [_picker selectRow:picRowId inComponent:0 animated:NO];
        self.pickerval = @"CurrencyPicker";

        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:_picker.bounds
                                         byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                               cornerRadii:CGSizeMake(5.0, 5.0)];

        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.view.frame;
        maskLayer.path = maskPath.CGPath;
        _picker.layer.mask = maskLayer;


        UIView *topview = (UIView*)[self.view viewWithTag:-2];
        [topview addSubview:_picker];
        _setbutton =[[UIButton alloc]init];
        _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
        [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
        [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
        [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_setbutton addTarget:self action:@selector(donelabel) forControlEvents:UIControlEventTouchUpInside];
        [topview addSubview:_setbutton];

    }else{

        //Change for currency
        [self showAlert:NSLocalizedString(@"fillup_unit_change_title", @"Change Unit for Individual Fill-up") message:NSLocalizedString(@"fillup_unit_change_msg", @"Changing units for individual fill-ups is a part of the upgraded version.\n\nIn the free version you can change the default unit for the app, from Settings.")];
    }
}

-(void)openselectpicker
{
    if(self.vehiclearray.count>0)
    {
        [self picker:@"Select Vehicle"];
    }
    
    else
    {
        
        
        [self showAlert:NSLocalizedString(@"no_veh_id", @"No Vehicle Found") message:@""];
        
    }
}

- (void)picker : (NSString *) string{
    //NIKHIL BUG_134 //added setbutton and _pic removeFromSuperview
    [_picker removeFromSuperview];
    [_pic removeFromSuperview];
    [_setbutton removeFromSuperview];
    
    _picker = [[UIPickerView alloc]init];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _picker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _picker.backgroundColor=[UIColor grayColor];
    
    _picker.clipsToBounds=YES;
    _picker.delegate =self;
    _picker.dataSource=self;
    _picker.tag=-8;
    
    //NIKHIL BUG_131 //added below line
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    int picRowId = (int)[setRowValue integerForKey:@"rowValue"];
    [_picker selectRow:picRowId inComponent:0 animated:NO];
    self.pickerval = @"Select";
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_picker.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.frame;
    maskLayer.path = maskPath.CGPath;
    _picker.layer.mask = maskLayer;
    
    
    UIView *topview = (UIView*)[self.view viewWithTag:-2];
    [topview addSubview:_picker];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    //button.titleLabel.text = @"Set" ;
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //_setbutton.layer.cornerRadius = 5;
    [_setbutton addTarget:self action:@selector(donelabel) forControlEvents:UIControlEventTouchUpInside];
    [topview addSubview:_setbutton];
    
}


#pragma mark pickerView Delegate methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag==-8)
    {
        return  self.vehiclearray.count;
    }else if(pickerView.tag==-10){
        return self.unitPickerArray.count;
    }else if(pickerView.tag==-11){
        return self.currencyPickerArray.count;
    }
    else
        return 0;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag==-8)
    {
        NSDictionary *dictionary = [[NSDictionary alloc]init];
        // NSLog(@"dictionary value %@",dictionary);
        dictionary = [self.vehiclearray objectAtIndex:row];
        return [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
    }else if(pickerView.tag==-10){
        
        NSString *currentUnit = [[NSString alloc]init];
        currentUnit = [self.unitPickerArray objectAtIndex:row];
        return currentUnit;
    }else if(pickerView.tag==-11){

        NSString *currentCurr = [[NSString alloc]init];
        currentCurr = [self.currencyPickerArray objectAtIndex:row];
        return currentCurr;
    }
    else
        
        return 0;
}


//NIKHIL BUG_131 added below method
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    _selPickerRow = (int)[pickerView selectedRowInComponent:0];
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    [setRowValue setInteger:_selPickerRow forKey:@"rowValue"];
}


-(void)savefillup
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //NSLog(@"TOP ODO : %d", [[def objectForKey:@"TopOdo"] intValue]);
    //Changed the object type bcuz it is causing langaue issues
//    if([[def objectForKey:@"filluptype"]isEqualToString:NSLocalizedString(@"trp", @"Trip")] && [[def objectForKey:@"TopOdo"] intValue] == 0)
    if([[def objectForKey:@"filluptype"]isEqualToString:@"Trip"] && [[def objectForKey:@"TopOdo"] intValue] == 0)
    {
        
        //NSString *trp_after_first_fu = @"The first fill up requires you to enter the Odometer value. You will be able to switch to Trip Distance for subsequent fill ups";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"trp_after_first_fu", @"The first fill up requires you to enter the Odometer value. You will be able to switch to Trip Distance for subsequent fill ups") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    else {
        self.checkedarray=[[NSMutableArray alloc]initWithArray:[[def arrayForKey:@"checked"]mutableCopy]];
        //NSLog(@"self checkedArr = %@", self.checkedarray);
        if([def objectForKey:@"idvalue"]!=nil)
        {
            //NSLog(@"idvalue::: %@",[def objectForKey:@"idvalue"]);
            UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
            
            int odo = [odometer.text intValue];
            int lastOdo =[[def objectForKey:@"TopOdo"] intValue];
            int avg = [[def objectForKey:@"AvgDistance"] intValue];
            int diff = odo - lastOdo;
            NSString* message = NSLocalizedString(@"odo_correct_msg", @"Are you sure the odometer value is correct? It seems a bit large.");
            //Changed the object type bcuz it is causing langaue issues
          //  if ([[def objectForKey:@"filluptype"]isEqualToString:NSLocalizedString(@"trp", @"Trip")])
            if ([[def objectForKey:@"filluptype"]isEqualToString:@"Trip"])
            {
                diff = odo;
                message =NSLocalizedString(@"trp_correct_msg", @"Are you sure the trip value is correct? It seems a bit large.");
                
            }
            
            if (diff > avg +1000)
            {

                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:message
                                                      message:@""
                                                      preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *changeAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"Change", @"Change action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   
                                               } ];
                
                UIAlertAction *continueAction = [UIAlertAction
                                                 actionWithTitle:NSLocalizedString(@"continue", @"Continue")
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action)
                                                 {
                                                     if([[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]==nil)
                                                     {
                                                         //[self savetolocaldatabase];
                                                         [self saveToLocalDatabaseNew];
                                                     }
                                                     else
                                                     {
                                                         [self editfillup];
                                                     }
                                                     
                                                 }];
                
                [alertController addAction:changeAction];
                [alertController addAction:continueAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            
            else{
                
                if([[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]==nil)
                {
                    //[self savetolocaldatabase];
                    [self saveToLocalDatabaseNew];
                }
                else
                {
                    [self editfillup];
                }
            }
            
        }
        
        else
        {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:NSLocalizedString(@"no_veh_id", @"No Vehicle Found")
                                                  message:@""
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
    }
}

-(void)saveToLocalDatabaseNew
{
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    
    UITextField *qty = (UITextField *)[self.view viewWithTag:3];
    UITextField *date = (UITextField *)[self.view viewWithTag:1];

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    //Changed the object type bcuz it is causing langaue issues
    if([Def objectForKey:@"filluptype"]==nil)
    {
        //[Def setObject:NSLocalizedString(@"odometer", @"Odometer") forKey:@"filluptype"];
        [Def setObject:@"odometer" forKey:@"filluptype"];
    }
    
    //Swapnil BUG_77
    if(odometer.text.length!=0 && qty.text.length!=0 && date.text.length!=0 && [qty.text floatValue] != 0 && [odometer.text floatValue] != 0)
    {
        //Changed the object type bcuz it is causing langaue issues
       // if( [[Def objectForKey:@"filluptype"]isEqualToString:NSLocalizedString(@"odometer", @"Odometer")])
            //START
        if( [[Def objectForKey:@"filluptype"]isEqualToString:@"odometer"])
        {
            
            if ([self checkOdo:[odometer.text floatValue] ForDate:[formatter dateFromString:date.text]])
            {
                
                if ([recOrder isEqualToString:@"MAX"])
                {
                    [self insertrecord:([odometer.text floatValue]-prevOdo)];
                    [self updatedistance];

                    //Swapnil BUG_78
                    //[self dateisgreater];
                    //[self updateconvalue];
                    //Nikhil_BUG_163 cons value updated separatly if odo is maxOdo
                    commonMethods *common = [[commonMethods alloc]init];
                    [common updateConsumptionMaxOdo];
                    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
                    [self getOdoServices];
                    [self dismissViewControllerAnimated:YES completion:nil];

                }
                else if ([recOrder isEqualToString:@"MIN"])
                {
                    [self insertrecord:0];
                    [self isfirstrecord];
                    [self updatedistance];
                    [self updateconvalue];
                    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
                    [self getOdoServices];
                    [self dismissViewControllerAnimated:YES completion:nil];

                }
                else if ([recOrder isEqualToString:@"BETWEEN"])
                {
                    [self insertrecord:([odometer.text floatValue]-prevOdo)];
                    [self updatedistance];
                    
                    //Swapnil BUG_78
                    //[self dateisless];
                    
                    [self updateconvalue];
                    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
                    [self getOdoServices];
                    [self dismissViewControllerAnimated:YES completion:nil];

                }
                
                //Swapnil Fabric events
                NSString *appInstallDate = [Def objectForKey:@"installDate"];
                NSInteger fillupCountEvent = [Def integerForKey:@"fillupCountEvent"] + 1;
                [Def setInteger:fillupCountEvent forKey:@"fillupCountEvent"];
                NSString *fillupCnt = [NSString stringWithFormat:@"%ld", (long)fillupCountEvent];
                
                NSString *completeFillupEvent = [NSString stringWithFormat:@"%@; %@", appInstallDate, fillupCnt];
                [Answers logCustomEventWithName:@"Fill Up Event"
                               customAttributes:@{@"Fill Ups": completeFillupEvent}];
                
                BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
                
                if(!proUser){
                    NSInteger gadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"adCount"];
                    gadCount = gadCount + 1;
                    [[NSUserDefaults standardUserDefaults] setInteger:gadCount forKey:@"adCount"];
                }
                
                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                [def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
            }
            else {
                [self showAlert:NSLocalizedString(@"incorrect_odo", @"Incorrect Odometer value for Date") message:@""];
            }
            
          //  [self checkNetworkForCloudStorage];
            ///Upload data from common methods
//            commonMethods *common = [[commonMethods alloc] init];
//            [common checkNetworkForCloudStorage:@"isLog"];

        } //END
        //Trip record
        //Changed the object type bcuz it is causing langaue issues
        //else if( [[Def objectForKey:@"filluptype"]isEqualToString:NSLocalizedString(@"trp", @"Trip")])
        else if( [[Def objectForKey:@"filluptype"]isEqualToString:@"Trip"])
        {
            NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
            NSError *err;
            NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
            
            //Swapnil BUG_70
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid == %@ and type = 0",comparestring];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                           ascending:YES];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            [requset setPredicate:predicate];
            [requset setSortDescriptors:sortDescriptors];
            NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
            
            
            T_Fuelcons *lastrecord =[datavalue lastObject];
            
            //Swapnil BUG_71
            T_Fuelcons *firstRecord = [datavalue firstObject];
            
            if(datavalue.count>0)
            {

                //greater date
                //Swapnil BUG_71
                if([lastrecord.stringDate compare:[formatter dateFromString:date.text]]==NSOrderedAscending || [lastrecord.stringDate compare:[formatter dateFromString:date.text]] == NSOrderedSame || [firstRecord.stringDate compare:[formatter dateFromString:date.text]] == NSOrderedSame)
                {
                    //  NSLog(@"last odometer value %.2f",[odometer.text floatValue]+[lastrecord.odo floatValue]);
                    
                    [self inserttrip:[odometer.text floatValue]+[lastrecord.odo floatValue]];
                    [self updateodometer];
                    
                    //Swapnil BUG_78
                    //[self dateisgreater];
                    //Nikhil_BUG_163 cons value updated separatly if odo is maxOdo
                    commonMethods *common = [[commonMethods alloc]init];
                    [common updateConsumptionMaxOdo];
                    //[self updateconvalue];
                    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                
                //less date
                else if([lastrecord.stringDate compare:[formatter dateFromString:date.text]]==NSOrderedDescending)
                {
                    
                    for (int i=0; i<datavalue.count; i++)
                    {
                        
                        T_Fuelcons *recordprev = [datavalue objectAtIndex:i];
                        
                        //Swapnil BUG_71
                        if([recordprev.stringDate compare:[formatter dateFromString:date.text]]==NSOrderedAscending || [recordprev.stringDate compare:[formatter dateFromString:date.text]] == NSOrderedSame)
                        {
                            T_Fuelcons *recordnext = [datavalue objectAtIndex:i+1];
                            //NSLog(@"Fuel record %@",[formatter stringFromDate:recordnext.stringDate]);
                            
                            //Swapnil BUG_71
                            if([recordnext.stringDate compare:[formatter dateFromString:date.text]]==NSOrderedDescending || [recordprev.stringDate compare:[formatter dateFromString:date.text]] == NSOrderedSame)
                            {
                                //NSLog(@"less value");
                                //NSLog(@"odometer value %.2f",[odometer.text floatValue]+[recordprev.odo floatValue]);
                                [self inserttrip:[odometer.text floatValue]+[recordprev.odo floatValue]];
                                //[self updatedistance];
                                [self updateodometer];
                                
                                //Swapnil BUG_78
                                //[self dateisless];
                                
                                [self updateconvalue];
                                //[self updateodometer];
                                [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
                                [self dismissViewControllerAnimated:YES completion:nil];
                                break;
                            }
                        }
                        
                        else {
                            
                            //Swapnil BUG_71
                            [self firstRecordTripAlert];
                            }
                  
                    }
                    
                }
                BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
                
                if(!proUser){
                    NSInteger gadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"adCount"];
                    gadCount = gadCount + 1;
                    [[NSUserDefaults standardUserDefaults] setInteger:gadCount forKey:@"adCount"];
                }
                
                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                [def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
            }
            else
            {
                [self inserttrip:[odometer.text floatValue]];
                [self isfirstrecord];
                [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
         //   [self checkNetworkForCloudStorage];
            ///Upload data from common methods
//            commonMethods *common = [[commonMethods alloc] init];
//            [common checkNetworkForCloudStorage:@"isLog"];
        }
        
    }
    else
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Enter Date,Odometer and Quantity"
                                              message:@""
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
    
}

#pragma mark Friend Single Sync Methods
-(BOOL)checkforConfirmedFriends{
    
    //TO get confirmed friends
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSString *comparestring = @"confirm";
    NSFetchRequest *friendRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends_Table"];
    NSPredicate *friendPredicate = [NSPredicate predicateWithFormat:@"status == %@",comparestring];
    [friendRequest setPredicate:friendPredicate];
    NSArray *frndData = [contex executeFetchRequest:friendRequest error:&err];
    
    if (frndData.count>0) {
        //NSLog(@"myFriends:- %@",frndData);
        return YES;
    }else{
    
        return NO;
    }
}

//
//-(void)sendUpdatedRecordToFriend:(NSDictionary *)friendDict{
//    
//    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
//    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
//    
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary *parametersDict = [[NSMutableDictionary alloc]init];
//    parametersDict = [friendDict mutableCopy];
//    NSDate *date = [friendDict objectForKey:@"date"];
//    
//    commonMethods *common = [[commonMethods alloc] init];
//    NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:date];
//    int month = [[epochDictionary valueForKey:@"month"] intValue] -1;
//    [parametersDict setObject:[epochDictionary valueForKey:@"day"] forKey:@"day"];
//    [parametersDict setValue:[NSNumber numberWithInt:month] forKey:@"month"];
//    [parametersDict setObject:[epochDictionary valueForKey:@"year"] forKey:@"year"];
//    
//    //NSLog(@"date:- %@",[epochDictionary valueForKey:@"epochTime"]);
//    
//    //Trim after decimals
//    NSString *gotDate = [epochDictionary valueForKey:@"epochTime"];
//    NSString *sendDate = [gotDate substringToIndex:13];
//    //NSLog(@"date:- %@",sendDate);
//    [parametersDict setObject:sendDate forKey:@"date"];
//    //Add filluptype
//    //Changed the object type bcuz it is causing langaue issues
//    //if([[def objectForKey:@"filluptype"] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")])
//    if([[def objectForKey:@"filluptype"] isEqualToString:@"odometer"])
//    {
//        
//        [parametersDict setObject:@"Odometer" forKey:@"OT"];
//        //Changed the object type bcuz it is causing langaue issues
//    }else if([[def objectForKey:@"filluptype"] isEqualToString:@"Trip"]){
//       
//        [parametersDict setObject:@"Trip" forKey:@"OT"];
//        
//    }
//    
//    //NSLog(@"Friend dict to be sent, has arrived here,  woohoo::- %@",parametersDict);
//    
//    if(networkStatus == NotReachable){
//        
//        NSMutableArray *saveArray = [[NSMutableArray alloc] init];
//        saveArray = [def objectForKey:@"pendingFriendRecord"];
//        [saveArray addObject:parametersDict];
//        [def setObject:saveArray forKey:@"pendingFriendRecord"];
//        
//    } else {
//        
//        NSError *err;
//        NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:parametersDict options:NSJSONWritingPrettyPrinted error:&err];
//        
//        [def setBool:NO forKey:@"updateTimeStamp"];
//        [common saveToCloud:postDataArray urlString:kFriendSyncDataScript success:^(NSDictionary *responseDict) {
//            
//            //NSLog(@"ResponseDict is : %@", responseDict);
//            
//            if([[responseDict valueForKey:@"success"]  isEqual: @1]){
//                
//                // NSLog(@"success:- %@",[responseDict valueForKey:@"success"]);
//                
//            }else{
//                
//                AppDelegate *app = [[AppDelegate alloc]init];
//                NSString* alertBody = @"Failed to send data to your friends";
//                [app showNotification:@"":alertBody];
//                
//            }
//            
//        } failure:^(NSError *error) {
//            
//        }];
//    }
//
//}

- (void)firstRecordTripAlert{
    
    //NSString *trp_after_first_fu = @"The first fill up requires you to enter the Odometer value. You will be able to switch to Trip Distance for subsequent fill ups";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"trp_after_first_fu", @"The first fill up requires you to enter the Odometer value. You will be able to switch to Trip Distance for subsequent fill ups") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

//new_7  2018may
-(void)insertrecord: (float) distance
{
    // NSLog(@"distance value %.2f",distance);
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    
    UITextField *qty = (UITextField *)[self.view viewWithTag:3];
    UITextField *date = (UITextField *)[self.view viewWithTag:1];
    UITextField *totalCost = (UITextField *)[self.view viewWithTag:7];
    UITextField *octane = (UITextField *)[self.view viewWithTag:8];
    UITextField *fuel = (UITextField *)[self.view viewWithTag:9];
    UITextField *filling = (UITextField *)[self.view viewWithTag:10];
    UITextView *notes = (UITextView *)[self.view viewWithTag:12];
    //UIImage *image =[UIImage imageNamed:@"add_photo"];
    UIButton *pbutton  = (UIButton *)[self.view viewWithTag:1000];
    UIButton *mbutton  = (UIButton *)[self.view viewWithTag:2000];
    UILabel *priceUnitLabel = (UILabel *)[self.view viewWithTag:13];
    UILabel *totalUnitLabel = (UILabel *)[self.view viewWithTag:14];

    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    NSDate *formatteddate =[formater dateFromString:date.text];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    //TO get vehid
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %i",[comparestring intValue]];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
    
    Veh_Table *vehicleData = [vehData firstObject];
    //till here
    
    NSString *vehid = vehicleData.vehid;
    //NSLog(@"gadiname:- %@",vehid);
    
    T_Fuelcons *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"T_Fuelcons" inManagedObjectContext:contex];
    
    
    NSMutableDictionary *forFriendDict = [[NSMutableDictionary alloc]init];
    if([Def objectForKey:@"UserEmail"]){
        [forFriendDict setObject:[Def objectForKey:@"UserEmail"] forKey:@"email"];
        [forFriendDict setObject:[Def objectForKey:@"UserName"] forKey:@"name"];
    }
    [forFriendDict setObject:@"add" forKey:@"action"];
    
    //Swapnil NEW_6
    int fuelID;
    if([Def objectForKey:@"maxFuelID"] != nil){
        
        fuelID = [[Def objectForKey:@"maxFuelID"] intValue];
       
    } else {
        
        fuelID = 0;
    }
   
    dataval.iD = [NSNumber numberWithInt:fuelID + 1];
    syncRowID = [NSNumber numberWithInt:fuelID + 1];
    //NSLog(@"insertrecord dataval.iD  ::::%@",dataval.iD);
    [Def setObject:dataval.iD forKey:@"maxFuelID"];
    [forFriendDict setObject:dataval.iD forKey:@"id"];
    dataval.odo =@([odometer.text floatValue]);
    if(dataval.odo != nil){
        [forFriendDict setObject:dataval.odo forKey:@"odo"];
    }else{
        [forFriendDict setObject:@"" forKey:@"odo"];
    }
    
    dataval.vehid = comparestring;
    if(vehid != nil){
        [forFriendDict setObject:vehid forKey:@"vehid"];
    }else{
        [forFriendDict setObject:@"" forKey:@"vehid"];
    }
    
    float calculatedQty = [self calculateQty:[qty.text floatValue]];
    dataval.qty = @(calculatedQty);
    if(dataval.qty != nil){
        [forFriendDict setObject:dataval.qty forKey:@"qty"];
    }else{
        [forFriendDict setObject:@"" forKey:@"qty"];
    }
    
    dataval.stringDate= formatteddate;
    if(dataval.stringDate != nil){
        [forFriendDict setObject:dataval.stringDate forKey:@"date"];
    }else{
        [forFriendDict setObject:@"" forKey:@"date"];
    }
    
    dataval.type = @(0);
    if(dataval.type != nil){
        [forFriendDict setObject:dataval.type forKey:@"type"];
    }
    
    dataval.serviceType = @"Fuel Record";
    if(dataval.serviceType != nil){
        [forFriendDict setObject:dataval.serviceType forKey:@"serviceType"];
    }

    NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
    NSString *string = [array lastObject];

    if([priceUnitLabel.text isEqualToString:string] || [totalUnitLabel.text isEqualToString:string]){

        NSLog(@"No need of calculating");
        dataval.cost = @([totalCost.text floatValue]);
    }else{

        NSString *calculatedCost = [self getCalculatedCost:totalCost.text selectedCurrUnit:priceUnitLabel.text];
        dataval.cost = @([calculatedCost floatValue]);
    }


    if(dataval.cost != nil){
        [forFriendDict setObject:dataval.cost forKey:@"cost"];
    }
    dataval.octane = @([octane.text floatValue]);
    if(dataval.octane != nil){
        [forFriendDict setObject:dataval.octane forKey:@"octane"];
    }
    dataval.fuelBrand = fuel.text;
    if(dataval.fuelBrand != nil){
        [forFriendDict setObject:dataval.fuelBrand forKey:@"fuelBrand"];
    }else{
        [forFriendDict setObject:@"" forKey:@"fuelBrand"];
    }
    dataval.fillStation = filling.text;
    if(dataval.fillStation != nil){
        [forFriendDict setObject:dataval.fillStation forKey:@"fillStation"];
    }else{
        [forFriendDict setObject:@"" forKey:@"fillStation"];
    }
    dataval.notes =notes.text;
    if(dataval.notes != nil){
        [forFriendDict setObject:dataval.notes forKey:@"notes"];
    }else{
        [forFriendDict setObject:@"" forKey:@"notes"];
    }
    dataval.dist =@(distance);
    
    if(self.receiptImageArray==nil || self.receiptImageArray.count == 0)
    {
        //Swapnil 25 Apr-2017
        NSFileManager *filemanager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //Swapnil ENH_24
        NSString *documentsDirectory = [paths firstObject];
        
        NSString *imagePath = dataval.receipt;
        NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", imagePath]];
        NSError *error;
        BOOL isSuccess = [filemanager removeItemAtPath:completeImgPath error:&error];
        dataval.receipt =nil;
    }
    else
    {
        //ENH_57 to save multiple receipt
        NSString *wholeImageString = [[NSString alloc]init];
        NSString *finalString = [[NSString alloc]init];
         for(NSString *imageString in self.receiptImageArray){
            
           wholeImageString = [wholeImageString stringByAppendingString:imageString];
           wholeImageString = [wholeImageString stringByAppendingString:@":::"];
             
           }
        //NSLog(@"wholeImageString:- %@",wholeImageString);
        if(wholeImageString.length > 0){
            int lastThree =(int)wholeImageString.length-3;
            finalString = [wholeImageString substringToIndex:lastThree];
        }
        //NSLog(@"finalString:- %@",finalString);
        dataval.receipt = finalString;
        //To show receipt Go Pro alert
        [Def setBool:YES forKey:@"receiptPresent"];
    }
    if(mbutton.selected==YES)
    {
        dataval.mfill=@1;
        if(!dataval.mfill)
        [forFriendDict setObject:dataval.mfill forKey:@"mfill"];
        dataval.cons=NULL;
    }
    else
    {
        dataval.mfill=@0;
        if(!dataval.mfill)
        [forFriendDict setObject:dataval.mfill forKey:@"mfill"];
    }
    
    //Swapnil BUG_55
    if(pbutton.selected == YES)
    {
        dataval.pfill=@1;
        if(!dataval.pfill)
        [forFriendDict setObject:dataval.pfill forKey:@"pfill"];
        dataval.cons=NULL;
    }
    else
    {
        dataval.pfill=@0;
        if(!dataval.pfill)
        [forFriendDict setObject:dataval.pfill forKey:@"pfill"];
    }
    
    //New_11 Maps Kept 0 in case location access is not allowed
    if(dataval.latitude)
    [forFriendDict setObject:dataval.latitude forKey:@"depLat"];
    if(dataval.longitude)
    [forFriendDict setObject:dataval.longitude forKey:@"depLong"];
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    //Swapnil ENH_11
    //check if auto detect locn checkmark is checked, permission to access locn is granted and location services are enabled
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //ForMAps New_11 Maps removed [def objectForKey:@"autoDetectLoc"]  isEqual: @"YES"] &&
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager locationServicesEnabled])){
        
        
        //NSLog(@"saveCurrLatitude:- %@",saveCurLat);
       // NSLog(@"saveCurrLongitude:- %@",saveCurLongitude);
        //Getting fuelstation from location
        //Request current location
        [[LocationServices sharedInstance].locationManager requestLocation];
        
        //Get latest locn in currentLocation
        CLLocation *currentLocation = [LocationServices sharedInstance].latestLoc;
        //NSLog(@"currentLocation : %@", currentLocation);
        
        dataval.latitude = [NSNumber numberWithDouble:currentLocation.coordinate.latitude];
        if(dataval.latitude){
            
            [forFriendDict setObject:dataval.latitude forKey:@"depLat"];
        }
        dataval.longitude = [NSNumber numberWithDouble:currentLocation.coordinate.longitude];
        if(dataval.longitude){
            [forFriendDict setObject:dataval.longitude forKey:@"depLong"];
        }
        //Accessing Loc_Table from DB
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
        
        NSArray *locationArray = [[NSArray alloc] init];
        locationArray = [contex executeFetchRequest:request error:&err];
        //NSLog(@"locArr : %@", locationArray);
        
        //Set flag for locn present or not
        BOOL isPresent = NO;
        commonMethods *common = [[commonMethods alloc]init];
        NSNumberFormatter *lformatter = [common decimalFormatter];
//        [formatter setRoundingMode:NSNumberFormatterRoundFloor];
//        [formatter setMaximumFractionDigits:3];
//        [formatter setPositiveFormat:@"0.###"];
//
        if(![currentLat  isEqual: @0] && ![currentLongitude isEqual:@0]){
            
            //Loop thr' each record in locn table
            for(Loc_Table *location in locationArray){
               
                
                NSString *latString = [lformatter stringFromNumber:location.lat];
                NSString *longiString = [lformatter stringFromNumber:location.longitude];
                location.lat = [NSNumber numberWithDouble:[latString doubleValue]];
                location.longitude = [NSNumber numberWithDouble:[longiString doubleValue]];
                //NSLog(@"####comparing lat long from db from insertRecord: %@, %@", location.lat, location.longitude);
                //NSLog(@"####comparing lat long from location from insertRecord: %@, %@", currentLat,currentLongitude);
              
                //If current lat, long matches with the record's lat, long
                if([currentLat floatValue] == [location.lat floatValue] && [currentLongitude floatValue] == [location.longitude floatValue])
                {
                    //means that lat, long are already present in Locn table
                    isPresent = YES;
                    
                    //then check corresponding address(fill station) and brand are similar to what user has entered
                    if(![location.address isEqualToString:filling.text] || ![location.brand isEqualToString:fuel.text]){
                        
                        //If not, edit address and brand to user entered data
                        location.address = filling.text;
                        location.brand = fuel.text;
                        
                        [paramDict setObject:location.iD forKey:@"rowid"];
                        [paramDict setObject:@"edit" forKey:@"type"];
                    }
                } else {
                    
                    //that lat, long not present in Locn table
                    isPresent = NO;
                }
            }
        }
        
        //NIKHIL BUG_150
        if(isPresent == NO && ![currentLat  isEqual: @0] && ![currentLongitude isEqual:@0] && currentLat)
        {
            
            //Saving new location to Loc_Table
            Loc_Table *locationData = [NSEntityDescription insertNewObjectForEntityForName:@"Loc_Table" inManagedObjectContext:contex];
            
            //Swapnil NEW_6
            int locID;
            if([Def objectForKey:@"maxLocID"] != nil){
                
                locID = [[Def objectForKey:@"maxLocID"] intValue];
            } else {
                
                locID = 0;
            }
            
            locationData.iD = [NSNumber numberWithInt:locID + 1];
            [Def setObject:locationData.iD forKey:@"maxLocID"];
       
            locationData.address = filling.text;
            locationData.brand = fuel.text;
            //NIKHIL BUG_151
            locationData.lat = currentLat;
            //NSLog(@"####location Lat Value after saving to DB in insertRecord::%@",locationData.lat);
            locationData.longitude = currentLat;
            
            
            [paramDict setObject:locationData.iD forKey:@"rowid"];
            [paramDict setObject:@"add" forKey:@"type"];
        }
    }
    
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
        
        //Swapnil NEW_6
        NSString *userEmail = [Def objectForKey:@"UserEmail"];
        
        //If user is signed In, then only do the sync process..
        if(userEmail != nil && userEmail.length > 0){

            if(paramDict != nil && paramDict.count > 0){

                sendLocationToServer = YES;
                locSyncRowID = [paramDict objectForKey:@"rowid"];
                sendLocType = [paramDict objectForKey:@"type"];

            }

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

                [self writeToSyncTableWithRowID:syncRowID tableName:@"LOG_TABLE" andType:@"add" andOS:@"self"];

                if(sendLocationToServer){

                    [self writeToSyncTableWithRowID:locSyncRowID tableName:@"LOC_TABLE" andType:sendLocType andOS:@"self"];
                    sendLocationToServer = NO;
                }
            });

        }
    }
}

-(NSString*)getCalculatedCost:(NSString*)currCost selectedCurrUnit: (NSString*)selectedCurrUnit{

    //Call fixer.io
    NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
    NSString *string = [array lastObject];

    NSString *selectedCurrNoSpace = [selectedCurrUnit stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *APIKey = @"4da4e3066d8e6c626d5d7cfe31871088"; //http://data.fixer.io/api/latest?access_key=4da4e3066d8e6c626d5d7cfe31871088&symbols=INR,USD
    NSString *urlString = [NSString  stringWithFormat:@"http://data.fixer.io/api/latest?access_key=%@&symbols=%@,%@",APIKey,string,selectedCurrNoSpace];
    NSURL *fixerRequestUrl = [NSURL URLWithString:urlString];
    NSData* data = [NSData dataWithContentsOfURL:fixerRequestUrl];

    NSError *error;
    NSMutableDictionary *rateDict = [[NSMutableDictionary alloc] init];
    if(data != nil){
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        //NSLog(@"data : %@", dataDictionary);
        rateDict = [dataDictionary objectForKey:@"rates"];

        NSLog(@"####resultCost::::%@",rateDict);
        double selectedCurrRate = [[rateDict objectForKey:selectedCurrNoSpace] doubleValue];
        double currRate = [[rateDict objectForKey:string] doubleValue];

        double givenCost = [currCost doubleValue];

        double calculatedCost = (currRate/selectedCurrRate)*givenCost;
        NSString *resultString = [NSString stringWithFormat:@"%2.f",calculatedCost];
        return resultString;
    }else{

        return @"";
    }


}

-(float)calculateQty:(float)qty{
    
    if([selectedUnit isEqualToString:@"0"]){
        
        //NSLog(@"Qty: %f",qty);
    
    }else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
    {
        qty = qty/3.79;
    }
    
    else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
    {
        qty = qty/4.55;
    }
    
    else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
    {
        qty = qty*3.79;
    }
    
    else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
    {
        qty = qty*4.55;
    }
    
    else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
    {
        
        qty = qty*1.2;
    }
    
    else if([selectedUnit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
    {
        qty = qty/1.2;
    }
    selectedUnit =@"0";
    return qty;
}

//new_7  2018may
-(void)inserttrip: (float)odo
{
    
    // NSLog(@"distance value %.2f",odo);
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    
    UITextField *qty = (UITextField *)[self.view viewWithTag:3];
    UITextField *date = (UITextField *)[self.view viewWithTag:1];
    //UITextField *price = (UITextField *)[self.view viewWithTag:6];
    
    //Swapnil BUG_92
    UITextField *totalCost = (UITextField *)[self.view viewWithTag:7];
    
    UITextField *octane = (UITextField *)[self.view viewWithTag:8];
    UITextField *fuel = (UITextField *)[self.view viewWithTag:9];
    UITextField *filling = (UITextField *)[self.view viewWithTag:10];
    UITextView *notes = (UITextView *)[self.view viewWithTag:12];
    //UIImage *image =[UIImage imageNamed:@"add_photo"];
    // UIButton *button  = (UIButton *)[self.view viewWithTag:1000];
    UIButton *mbutton  = (UIButton *)[self.view viewWithTag:2000];
    UIButton *pbutton  = (UIButton *)[self.view viewWithTag:1000];
    UILabel *priceUnitLabel = (UILabel *)[self.view viewWithTag:13];
    UILabel *totalUnitLabel = (UILabel *)[self.view viewWithTag:14];
    
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    NSDate *formatteddate =[formater dateFromString:date.text];
    NSMutableDictionary *forFriendDict = [[NSMutableDictionary alloc]init];
    
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    //TO get vehid
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %i",[comparestring intValue]];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
    
    Veh_Table *vehicleData = [vehData firstObject];
    //till here
    
    NSString *vehid = vehicleData.vehid;
    //NSLog(@"gadiname:- %@",vehid);
    
    T_Fuelcons *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"T_Fuelcons" inManagedObjectContext:contex];
    
    //Swapnil NEW_6
    int fuelID;
    if([Def objectForKey:@"maxFuelID"] != nil){
        
        fuelID = [[Def objectForKey:@"maxFuelID"] intValue];
    } else {
        
        fuelID = 0;
    }
    //for syncing data to friend
    if([Def objectForKey:@"UserEmail"]){
        [forFriendDict setObject:[Def objectForKey:@"UserEmail"] forKey:@"email"];
        [forFriendDict setObject:[Def objectForKey:@"UserName"] forKey:@"name"];
    }
    [forFriendDict setObject:@"add" forKey:@"action"];
    dataval.iD = [NSNumber numberWithInt:fuelID + 1];
    syncRowID = [NSNumber numberWithInt:fuelID + 1];
    [forFriendDict setObject:dataval.iD forKey:@"id"];
    [Def setObject:dataval.iD forKey:@"maxFuelID"];
   
    dataval.odo =@(odo);
    if(dataval.odo != nil){
        [forFriendDict setObject:dataval.odo forKey:@"odo"];
    }else{
        [forFriendDict setObject:@"" forKey:@"odo"];
    }
    
   
    dataval.vehid = comparestring;
    if(vehid != nil){
        [forFriendDict setObject:vehid forKey:@"vehid"];
    }else{
        [forFriendDict setObject:@"" forKey:@"vehid"];
    }
    
//    commonMethods *common = [[commonMethods alloc]init];
//    NSNumberFormatter *lformatter = [common decimalFormatter];
//    float calculatedQty = [self calculateQty:[qty.text floatValue]];
//    NSString *qtyValue = [lformatter stringFromNumber: [NSNumber numberWithDouble: calculatedQty]];
//    dataval.qty = @([qtyValue floatValue]);
    
    float calculatedQty = [self calculateQty:[qty.text floatValue]];
    dataval.qty = @(calculatedQty);
    if(dataval.qty != nil){
        [forFriendDict setObject:dataval.qty forKey:@"qty"];
    }else{
        [forFriendDict setObject:@"" forKey:@"qty"];
    }
    
    dataval.stringDate= formatteddate;
    if(dataval.stringDate != nil){
        [forFriendDict setObject:dataval.stringDate forKey:@"date"];
    }else{
        [forFriendDict setObject:@"" forKey:@"date"];
    }
    
    
    dataval.type = @(0);
    if(dataval.type != nil){
        [forFriendDict setObject:dataval.type forKey:@"type"];
    }
    
    dataval.serviceType = @"Fuel Record";
    if(dataval.serviceType != nil){
        [forFriendDict setObject:dataval.serviceType forKey:@"serviceType"];
    }
    //Swapnil BUG_92
    NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
    NSString *string = [array lastObject];

    if([priceUnitLabel.text isEqualToString:string] || [totalUnitLabel.text isEqualToString:string]){

        NSLog(@"No need of calculating");
        dataval.cost = @([totalCost.text floatValue]);
    }else{

        NSString *calculatedCost = [self getCalculatedCost:totalCost.text selectedCurrUnit:priceUnitLabel.text];
        dataval.cost = @([calculatedCost floatValue]);
    }
    //dataval.cost = @([totalCost.text floatValue]);
    if(dataval.cost != nil){
        [forFriendDict setObject:dataval.cost forKey:@"cost"];
    }
    dataval.octane = @([octane.text floatValue]);
    if(dataval.octane != nil){
        [forFriendDict setObject:dataval.octane forKey:@"octane"];
    }
    dataval.fuelBrand = fuel.text;
    if(dataval.fuelBrand != nil){
         [forFriendDict setObject:dataval.fuelBrand forKey:@"fuelBrand"];
    }else{
         [forFriendDict setObject:@"" forKey:@"fuelBrand"];
    }
    dataval.fillStation = filling.text;
    if(dataval.fillStation != nil){
        [forFriendDict setObject:dataval.fillStation forKey:@"fillStation"];
    }else{
        [forFriendDict setObject:@"" forKey:@"fillStation"];
    }
    dataval.notes =notes.text;
    if(dataval.notes != nil){
        [forFriendDict setObject:dataval.notes forKey:@"notes"];
    }else{
        [forFriendDict setObject:@"" forKey:@"notes"];
    }
    dataval.dist =@([odometer.text floatValue]);
    
    if(self.receiptImageArray==nil  || self.receiptImageArray.count == 0)
    {
        //Swapnil 25 Apr-2017
        NSFileManager *filemanager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //Swapnil ENH_24
        NSString *documentsDirectory = [paths firstObject];
        
        NSString *imagePath = dataval.receipt;
        NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", imagePath]];
        NSError *error;
        BOOL isSuccess = [filemanager removeItemAtPath:completeImgPath error:&error];
        dataval.receipt =nil;
    }
    else
    {
        
        //ENH_57 to save multiple receipt
        NSString *wholeImageString = [[NSString alloc]init];
        NSString *finalString = [[NSString alloc]init];
        for(NSString *imageString in self.receiptImageArray){
            
            wholeImageString = [wholeImageString stringByAppendingString:imageString];
            wholeImageString = [wholeImageString stringByAppendingString:@":::"];
            
        }
        //NSLog(@"wholeImageString:- %@",wholeImageString);
        if(wholeImageString.length > 0){
            int lastThree =(int)wholeImageString.length-3;
            finalString = [wholeImageString substringToIndex:lastThree];
        }
        //NSLog(@"finalString:- %@",finalString);
        dataval.receipt = finalString;
        //To show receipt Go Pro alert
        [Def setBool:YES forKey:@"receiptPresent"];
    }
    if(mbutton.selected==YES)
    {
        dataval.mfill=@1;
        [forFriendDict setObject:dataval.mfill forKey:@"mfill"];
        dataval.cons=@0;
    }
    else
    {
        dataval.mfill=@0;
        [forFriendDict setObject:dataval.mfill forKey:@"mfill"];
        
    }
    
    //Swapnil BUG_55
    if(pbutton.selected == YES)
    {
        dataval.pfill=@1;
        [forFriendDict setObject:dataval.pfill forKey:@"pfill"];
        dataval.cons=NULL;
    }
    else
    {
        dataval.pfill=@0;
        [forFriendDict setObject:dataval.pfill forKey:@"pfill"];
    }
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    //Swapnil ENH_11
    //check if auto detect locn checkmark is checked, permission to access locn is granted and location services are enabled
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([[def objectForKey:@"autoDetectLoc"]  isEqual: @"YES"] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager locationServicesEnabled]){
        
        //Accessing Loc_Table from DB
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
        
        NSArray *locationArray = [[NSArray alloc] init];
        locationArray = [contex executeFetchRequest:request error:&err];
        //NSLog(@"locArr : %@", locationArray);
        //NIKHIL BUG_151
        commonMethods *common = [[commonMethods alloc]init];
        NSNumberFormatter *lformatter = [common decimalFormatter];
        //Set flag for locn present or not
        BOOL isPresent = NO;
        
        if(![currentLat  isEqual: @0.0] && ![currentLongitude isEqual:@0.0]){
            
            //Loop thr' each record in locn table
            for(Loc_Table *location in locationArray){
                
                NSString *latString = [lformatter stringFromNumber:location.lat];
                NSString *longiString = [lformatter stringFromNumber:location.longitude];
                location.lat = [NSNumber numberWithDouble:[latString doubleValue]];
                location.longitude = [NSNumber numberWithDouble:[longiString doubleValue]];
                //NSLog(@"####comparing lat long from db : %@, %@", location.lat, location.longitude);
                //NSLog(@"####comparing lat long from location : %@, %@", currentLat,currentLongitude);
                
                //If current lat, long matches with the record's lat, long
                if([currentLat floatValue] == [location.lat floatValue] && [currentLongitude floatValue] == [location.longitude floatValue])
                {
                    //means that lat, long are already present in Locn table
                    isPresent = YES;
                    
                    //then check corresponding address(fill station) and brand are similar to what user has entered
                    if(![location.address isEqualToString:filling.text] || ![location.brand isEqualToString:fuel.text]){
                        
                        //If not, edit address and brand to user entered data
                        location.address = filling.text;
                        location.brand = fuel.text;
                        
                        [paramDict setObject:location.iD forKey:@"rowid"];
                        [paramDict setObject:@"edit" forKey:@"type"];
                    }
                } else {
                    
                    //that lat, long not present in Locn table
                    isPresent = NO;
                }
            }
        }
        
        //NIKHIL BUG_150
        if(isPresent == NO && ![currentLat  isEqual: @0.0] && ![currentLongitude isEqual:@0.0] && currentLat)
        {
            
            //Saving new location to Loc_Table
            Loc_Table *locationData = [NSEntityDescription insertNewObjectForEntityForName:@"Loc_Table" inManagedObjectContext:contex];
            
            //Swapnil NEW_6
            int locID;
            if([Def objectForKey:@"maxLocID"] != nil){
                
                locID = [[Def objectForKey:@"maxLocID"] intValue];
            } else {
                
                locID = 0;
            }
            
            locationData.iD = [NSNumber numberWithInt:locID + 1];
            [Def setObject:locationData.iD forKey:@"maxLocID"];
            
            locationData.address = filling.text;
            locationData.brand = fuel.text;
            //NIKHIL BUG_151
            locationData.lat = currentLat;
           // NSLog(@"####location Lat Value after saving to DB in inserttrip::%@",locationData.lat);
            locationData.longitude = currentLongitude;
            
            [paramDict setObject:locationData.iD forKey:@"rowid"];
            [paramDict setObject:@"add" forKey:@"type"];
        }
    }
    
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
        
        //Swapnil NEW_6
        NSString *userEmail = [Def objectForKey:@"UserEmail"];
        
        //If user is signed In, then only do the sync process..
        if(paramDict != nil && paramDict.count > 0){

            sendLocationToServer = YES;
            locSyncRowID = [paramDict objectForKey:@"rowid"];
            sendLocType = [paramDict objectForKey:@"type"];

        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            if(userEmail != nil && userEmail.length > 0){

                [self writeToSyncTableWithRowID:syncRowID tableName:@"LOG_TABLE" andType:@"add" andOS:@"self"];

                if(sendLocationToServer){

                    [self writeToSyncTableWithRowID:locSyncRowID tableName:@"LOC_TABLE" andType:sendLocType andOS:@"self"];
                    sendLocationToServer = NO;
                }

            }
        });

    }
    
}


-(void)updatedistance

{
    //Swapnil BUG_73
    commonMethods *commMethods = [[commonMethods alloc] init];
    [commMethods updateDistance:0];
    
}


-(void)updateodometer

{
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    
    //swapnil BUG_69
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ and type = 0",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"stringDate"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    for(int i =0;i <datavalue.count;i++)
    {
        T_Fuelcons *currentrecord = [datavalue objectAtIndex:i];
        if(i==0)
        {
            if([currentrecord.odo floatValue]==0)
            {
                currentrecord.odo = currentrecord.dist;
            }
        }
        else
        {
            T_Fuelcons *previousrecord = [datavalue objectAtIndex:i-1];
            currentrecord.odo = @([currentrecord.dist floatValue] + [previousrecord.odo floatValue]);
            //NSLog(@"current odometer %.2f",[currentrecord.odo floatValue]);
        }
        
    }
    
    
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
    }
    
}



-(void)dateisgreater
{
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND type=0",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:YES];
    
    float dist_fact= 1;
    float vol_fact =1;
    
    NSString *dist_unit =[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
    NSString *vol_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
    NSString *con_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
    
    if([con_unit hasPrefix:@"m"] && [dist_unit isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")])
    {
        dist_fact =0.621;
    }
    
    else if(![con_unit hasPrefix:@"m"] && [dist_unit isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
        
    {
        dist_fact = 1.609;
    }
    
    if([con_unit isEqualToString:NSLocalizedString(@"disp_mpg_us", @"mpg (US)")])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.264;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact = 1.201;
        }
    }
    
    else  if([con_unit isEqualToString:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)")])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.22;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 0.833;
        }
    }
    
    else if([con_unit isEqualToString:NSLocalizedString(@"disp_lp100kms", @"L/100km")] || [con_unit isEqualToString:NSLocalizedString(@"disp_kmpl", @"km/L")])    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact= 4.546;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 3.785;
        }
        
    }
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    
    //swapnil
    //[formater setTimeZone:[NSTimeZone localTimeZone]];
    //  NSDate *formatteddate =[formater dateFromString:date.text];
    UIButton *button  = (UIButton *)[self.view viewWithTag:1000];
    NSString *fillupstring;
    if(button.selected==YES)
    {
        fillupstring = @"Partial";
    }
    else
    {
        fillupstring = @"Full";
        
    }
    
    
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    UITextField *date = (UITextField *)[self.view viewWithTag:1];
    
    //BUG_47
    for(int i=1;i<datavalue.count;i++)
    {
        T_Fuelcons *currentrecord = [datavalue objectAtIndex:i];
        
        //Swapnil BUG_55
        if([[formater stringFromDate:currentrecord.stringDate] isEqualToString: date.text]/* && [[currentrecord.odo stringValue] isEqualToString:odometer.text]*/)
        {
            T_Fuelcons *prevrecord = [datavalue objectAtIndex:i-1];
            if([fillupstring isEqualToString:@"Partial"])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(1);
                currentrecord.cons=0;
                
            }
            else  if(![fillupstring isEqualToString:@"Partial"] && [prevrecord.pfill isEqual:@(0)] && ![currentrecord.mfill isEqual:@(1)])
                
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(0);
                currentrecord.cons = [NSNumber numberWithFloat:(([currentrecord.odo floatValue] - [prevrecord.odo floatValue]) * dist_fact)/([currentrecord.qty floatValue] * vol_fact)];
                //NSLog(@"eff %@",currentrecord.cons);
            }
            
            else if(![fillupstring isEqualToString:@"Partial"] && [prevrecord.pfill isEqual:@(1)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill=@(0);
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                   [[CoreDataController sharedInstance] saveMasterContext];
                }
                //NSLog(@"called");
                [self updateconvalue];
            }
            
            
        }
    }
    
    
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
    }
    
}


-(void)isfirstrecord
{
    
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"  ascending:YES];
    
    UIButton *button  = (UIButton *)[self.view viewWithTag:1000];
    NSString *fillupstring;
    if(button.selected==YES)
    {
        fillupstring = @"Partial";
    }
    else
    {
        fillupstring = @"Full";
        
    }
    
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
   // UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    
    float dist_fact= 1;
    float vol_fact =1;
    
    NSString *dist_unit =[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
    NSString *vol_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
    NSString *con_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
    
    if([con_unit hasPrefix:@"m"] && [dist_unit isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")])
    {
        dist_fact =0.621;
    }
    
    else if(![con_unit hasPrefix:@"m"] && [dist_unit isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
        
    {
        dist_fact = 1.609;
    }
    
    if([con_unit isEqualToString:NSLocalizedString(@"disp_mpg_us", @"mpg (US)")])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.264;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact = 1.201;
        }
    }
    
    else  if([con_unit isEqualToString:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)")])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.22;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 0.833;
        }
    }
    
    else if([con_unit isEqualToString:NSLocalizedString(@"disp_lp100kms", @"L/100km")] || [con_unit isEqualToString:NSLocalizedString(@"disp_kmpl", @"km/L")])    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact= 4.546;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 3.785;
        }
        
    }
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    
    UITextField *date = (UITextField *)[self.view viewWithTag:1];
    
    if(datavalue.count==1)
    {
        //Swapnil ENH_24
        T_Fuelcons *firstrecord =[datavalue firstObject];
        
        if([fillupstring isEqualToString:@"Partial"])
        {
            firstrecord.pfill = @(1);
            firstrecord.cons=0;
            
        }
        else if(![fillupstring isEqualToString:@"Partial"])
        {
            firstrecord.pfill = @(0);
            firstrecord.cons=0;
            
        }
    }
    
    else
    {
        
        for(int i=0;i<datavalue.count;i++)
        {
            T_Fuelcons *currentrecord = [datavalue objectAtIndex:i];
            
            //Swapnil BUG_55
            if([[formater stringFromDate:currentrecord.stringDate] isEqualToString: date.text]/* && [[currentrecord.odo stringValue] isEqualToString:odometer.text]*/)
            {
                if([fillupstring isEqualToString:@"Partial"])
                {
                    //Swapnil BUG_55
                    //currentrecord.pfill = @(1);
                    currentrecord.cons = @([currentrecord.dist floatValue]*dist_fact / [currentrecord.qty floatValue]*vol_fact);
                }
                else if(![fillupstring isEqualToString:@"Partial"])
                {
                    //Swapnil BUG_55
                    //currentrecord.pfill = @(0);
                    currentrecord.cons = @([currentrecord.dist floatValue]*dist_fact / [currentrecord.qty floatValue]*vol_fact);
                    
                }
                
                
            }
        }
        
    }
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
    }
    
}


-(void)dateisless
{
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND type=0",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"stringDate"
                                                                   ascending:YES];
    
    UIButton *button  = (UIButton *)[self.view viewWithTag:1000];
    NSString *fillupstring;
    if(button.selected==YES)
    {
        fillupstring = @"Partial";
    }
    else
    {
        fillupstring = @"Full";
        
    }
    
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    
    
    float dist_fact= 1;
    float vol_fact =1;
    
    NSString *dist_unit =[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
    NSString *vol_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
    NSString *con_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
    
    if([con_unit hasPrefix:@"m"] && [dist_unit isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")])
    {
        dist_fact =0.621;
    }
    
    else if(![con_unit hasPrefix:@"m"] && [dist_unit isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
        
    {
        dist_fact = 1.609;
    }
    
    if([con_unit isEqualToString:NSLocalizedString(@"disp_mpg_us", @"mpg (US)")])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.264;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact = 1.201;
        }
    }
    
    else  if([con_unit isEqualToString:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)")])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.22;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 0.833;
        }
    }
    
    else if([con_unit isEqualToString:NSLocalizedString(@"disp_lp100kms", @"L/100km")] || [con_unit isEqualToString:NSLocalizedString(@"disp_kmpl", @"km/L")])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)")])
        {
            vol_fact= 4.546;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 3.785;
        }
        
    }
    
    
    UITextField *date = (UITextField *)[self.view viewWithTag:1];
    for(int i=0;i<datavalue.count;i++)
    {
        T_Fuelcons *currentrecord = [datavalue objectAtIndex:i];
        
        //Swapnil BUG_55
        if([[formater stringFromDate:currentrecord.stringDate] isEqualToString: date.text]/*&& [[currentrecord.odo stringValue] isEqualToString:odometer.text]*/)
        {
            T_Fuelcons *prevrecord = [datavalue objectAtIndex:i-1];
            
            T_Fuelcons *nextrecord = [datavalue objectAtIndex:i+1];
            nextrecord.dist = @([nextrecord.odo floatValue]-[currentrecord.odo floatValue]);
            
            
            if([fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(0)] && [prevrecord.pfill isEqual:@(0)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(1);
                currentrecord.cons=nextrecord.cons;
                
            }
            
            else if([fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(0)] && [prevrecord.pfill isEqual:@(1)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(1);
                currentrecord.cons=nextrecord.cons;
            }
            
            else if([fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(1)] && [prevrecord.pfill isEqual:@(0)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(1);
                currentrecord.cons=nextrecord.cons;
            }
            
            else if([fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(1)] && [prevrecord.pfill isEqual:@(1)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(1);
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    [[CoreDataController sharedInstance] saveMasterContext];
                }
                
                [self updateconvalue];
                
                // currentrecord.cons=nextrecord.cons;
            }
            
            
            
            else if (![fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(0)] && [prevrecord.pfill isEqual:@(0)] && ![currentrecord.mfill isEqual:@(1)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(0);
                currentrecord.cons = [NSNumber numberWithFloat:([currentrecord.odo floatValue] - [prevrecord.odo floatValue])*dist_fact/([currentrecord.qty floatValue])*vol_fact];
                nextrecord.cons = [NSNumber numberWithFloat:([nextrecord.odo floatValue] - [currentrecord.odo floatValue])*dist_fact/([nextrecord.qty floatValue])*vol_fact];
                
            }
            
            
            else if (![fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(0)] && [prevrecord.pfill isEqual:@(1)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(0);
                // currentrecord.cons = [NSNumber numberWithFloat:([currentrecord.odo floatValue] - [prevrecord.odo floatValue])/([currentrecord.qty floatValue])];
                // currentrecord.cons=nextrecord.cons;
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    [[CoreDataController sharedInstance] saveMasterContext];
                }
                
                [self updateconvalue];
            }
            
            
            else if (![fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(1)] && [prevrecord.pfill isEqual:@(0)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(0);
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    [[CoreDataController sharedInstance] saveMasterContext];
                }
                
                [self updateconvalue];
            }
            
            
            else if (![fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(1)] && [prevrecord.pfill isEqual:@(1)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(0);
                currentrecord.cons = [NSNumber numberWithFloat:([currentrecord.odo floatValue] - [prevrecord.odo floatValue])*dist_fact/([currentrecord.qty floatValue]*vol_fact)];
                nextrecord.cons = [NSNumber numberWithFloat:([nextrecord.odo floatValue] - [currentrecord.odo floatValue])*dist_fact/([nextrecord.qty floatValue]*vol_fact)];
                
            }
            
            
            
            
        }
    }
    
    
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
    }
    
}






-(void)Tripisless
{
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:YES];
    
    UIButton *button  = (UIButton *)[self.view viewWithTag:1000];
    NSString *fillupstring;
    if(button.selected==YES)
    {
        fillupstring = @"Partial";
    }
    else
    {
        fillupstring = @"Full";
        
    }
    
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    
    float dist_fact= 1;
    float vol_fact =1;
    
    NSString *dist_unit =[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
    NSString *vol_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
    NSString *con_unit = [[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
    
    if([con_unit hasPrefix:@"m"] && [dist_unit isEqualToString:NSLocalizedString(@"disp_kilometers", @"Kilometers")])
    {
        dist_fact =0.621;
    }
    
    else if(![con_unit hasPrefix:@"m"] && [dist_unit isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
        
    {
        dist_fact = 1.609;
    }
    
    if([con_unit isEqualToString:NSLocalizedString(@"disp_mpg_us", @"mpg (US)")])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.264;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact = 1.201;
        }
    }
    
    else  if([con_unit isEqualToString:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)")])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
        {
            vol_fact=0.22;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 0.833;
        }
    }
    
    else if([con_unit isEqualToString:NSLocalizedString(@"disp_lp100kms", @"L/100km")] || [con_unit isEqualToString:NSLocalizedString(@"disp_kmpl", @"km/L")])
    {
        if([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_uk", @"Gallon (UK)")])
        {
            vol_fact= 4.546;
        }
        else if ([vol_unit isEqualToString:NSLocalizedString(@"disp_gal_us", @"Gallon (US)")])
        {
            vol_fact = 3.785;
        }
        
    }
    
    
    UITextField *date = (UITextField *)[self.view viewWithTag:1];
    for(int i=0;i<datavalue.count;i++)
    {
        T_Fuelcons *currentrecord = [datavalue objectAtIndex:i];
        
        //Swapnil BUG_55
        if([[formater stringFromDate:currentrecord.stringDate] isEqualToString: date.text] /*&& [[currentrecord.odo stringValue] isEqualToString:odometer.text]*/)
        {
            T_Fuelcons *prevrecord = [datavalue objectAtIndex:i-1];
            T_Fuelcons *nextrecord = [datavalue objectAtIndex:i+1];
            nextrecord.odo = @([currentrecord.odo floatValue]+[nextrecord.dist floatValue]);
            if([fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(0)] && [prevrecord.pfill isEqual:@(0)] )
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(1);
                currentrecord.cons=nextrecord.cons;
                
            }
            
            else if([fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(0)] && [prevrecord.pfill isEqual:@(1)] )
            {
                //Swapnil BUG_55
                // currentrecord.pfill = @(1);
                currentrecord.cons=nextrecord.cons;
            }
            
            else if([fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(1)] && [prevrecord.pfill isEqual:@(0)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(1);
                currentrecord.cons=nextrecord.cons;
            }
            
            else if([fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(1)] && [prevrecord.pfill isEqual:@(1)])
            {
                //Swapnil BUG_55
                // currentrecord.pfill = @(1);
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    [[CoreDataController sharedInstance] saveMasterContext];
                }
                
                [self updateconvalue];
                
                // currentrecord.cons=nextrecord.cons;
            }
            
            
            
            else if (![fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(0)] && [prevrecord.pfill isEqual:@(0)]&& [currentrecord.mfill isEqual:@(0)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(0);
                currentrecord.cons = [NSNumber numberWithFloat:([currentrecord.odo floatValue] - [prevrecord.odo floatValue])*dist_fact/([currentrecord.qty floatValue]*vol_fact)];
                nextrecord.cons = [NSNumber numberWithFloat:([nextrecord.odo floatValue] - [currentrecord.odo floatValue])*dist_fact/([nextrecord.qty floatValue]*vol_fact)];
                
            }
            
            
            else if (![fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(0)] && [prevrecord.pfill isEqual:@(1)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(0);
                
                // currentrecord.cons = [NSNumber numberWithFloat:([currentrecord.odo floatValue] - [prevrecord.odo floatValue])/([currentrecord.qty floatValue])];
                // currentrecord.cons=nextrecord.cons;
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    [[CoreDataController sharedInstance] saveMasterContext];
                }
                
                [self updateconvalue];
            }
            
            
            else if (![fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(1)] && [prevrecord.pfill isEqual:@(0)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(0);
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    [[CoreDataController sharedInstance] saveMasterContext];
                }
                
                [self updateconvalue];
            }
            
            
            else if (![fillupstring isEqualToString:@"Partial"]&& [nextrecord.pfill isEqual:@(1)] && [prevrecord.pfill isEqual:@(1)]&& [currentrecord.mfill isEqual:@(0)])
            {
                //Swapnil BUG_55
                //currentrecord.pfill = @(0);
                currentrecord.cons = [NSNumber numberWithFloat:(([currentrecord.odo floatValue] - [prevrecord.odo floatValue])*dist_fact)/([currentrecord.qty floatValue]*vol_fact)];
                nextrecord.cons = [NSNumber numberWithFloat:(([nextrecord.odo floatValue] - [currentrecord.odo floatValue])*dist_fact)/([nextrecord.qty floatValue]*vol_fact)];
                
            }
        }
    }
    
    
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
    }
    
}


-(void)updateconvalue
{
    //Swapnil BUG_73
    commonMethods *commMethods = [[commonMethods alloc] init];
    [commMethods updateConsumption:0];
}

-(void)getOdoServices {

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND (type==1 OR type==2)",comparestring];
    
    [requset setPredicate:predicate];
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    
    
    NSMutableArray *serviceArray = [[NSMutableArray alloc]init];
    for(Services_Table *fuelrecord in datavalue)
    {
        //NSLog(@"odometer.text floatValue : %f", [odometer.text floatValue]);
        //NSLog(@"[fuelrecord.dueMiles floatValue]: %f , [fuelrecord.lastOdo floatValue] floatValue : %f", [fuelrecord.dueMiles floatValue], [fuelrecord.lastOdo floatValue]);
        
        if([odometer.text floatValue]>=([fuelrecord.dueMiles floatValue]+ [fuelrecord.lastOdo floatValue]) && [fuelrecord.dueMiles floatValue]!=0) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setValue:fuelrecord.vehid forKey:@"vehid"];
            [dictionary setValue:[formater stringFromDate:fuelrecord.lastDate] forKey:@"lastdate"];
            [dictionary setValue:fuelrecord.serviceName forKey:@"name"];
            [dictionary setValue:fuelrecord.recurring  forKey:@"recurring"];
            [dictionary setValue:fuelrecord.type forKey:@"type"];
            [dictionary setValue:fuelrecord.dueDays forKey:@"duedays"];
            [dictionary setValue:fuelrecord.dueMiles forKey:@"duemiles"];
            //   NSLog(@"service dictionary: %@", dictionary);
            [serviceArray addObject:dictionary];
            
            NSString* jrnKey = [[[dictionary objectForKey:@"name"] stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];
            [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];
            
            [[JRNLocalNotificationCenter defaultCenter] postNotificationOn:[NSDate dateWithTimeIntervalSinceNow:1] forKey:jrnKey alertBody:[NSString stringWithFormat:@"%@ %@ %@",[dictionary objectForKey:@"name"], NSLocalizedString(@"noti_msg_veh", @"Overdue for"),[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]] alertAction:@"Open" soundName:nil launchImage:nil userInfo:@{@"time":[NSString stringWithFormat:@"%@ Overdue for %@",[dictionary objectForKey:@"name"],[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]]} badgeCount:1 repeatInterval:NO category:nil];
            
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"showPage"];
            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"reminders", @"Reminder")
//                                                            message:[NSString stringWithFormat:@"%@ %@ %@",[dictionary objectForKey:@"name"], NSLocalizedString(@"noti_msg_veh", @"Overdue for"),[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]]
//                                                           delegate:self cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];

//            UIAlertController *alertController = [UIAlertController
//                                                  alertControllerWithTitle:NSLocalizedString(@"reminders", @"reminder")
//                                                  message:[NSString stringWithFormat: @"%@ %@ %@",[dictionary objectForKey:@"name"], NSLocalizedString(@"noti_msg_veh", @"Overdue for"),[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]]
//                                                  preferredStyle:UIAlertControllerStyleAlert];
//
//            UIAlertAction *okAction = [UIAlertAction
//                                       actionWithTitle:NSLocalizedString(@"ok", @"OK action")
//                                       style:UIAlertActionStyleDefault
//                                       handler:^(UIAlertAction *action)
//                                       {
//
//                                       }];
//            [alertController addAction:okAction];
//            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        //fuelrecord.dueMiles = @(0);
    }
    if ([contex hasChanges])
    {
        BOOL saved = [contex save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
    }
}

//Swapnil NEW_6
#pragma mark CLOUD SYNC METHODS


//Save rowID, tableName, and type in phones Sync table
- (void)writeToSyncTableWithRowID: (NSNumber *)rowID tableName: (NSString *)tableName andType: (NSString *)type andOS:(NSString *)originalSource{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    Sync_Table *syncData = [NSEntityDescription insertNewObjectForEntityForName:@"Sync_Table" inManagedObjectContext:context];
    
    syncData.rowID = rowID;
    syncData.tableName = tableName;
    syncData.type = type;
    syncData.processing = @0;
    syncData.originalSource = originalSource;
    
    if ([context hasChanges])
    {
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        [[CoreDataController sharedInstance] saveMasterContext];
        //Upload data from common methods
        //TODO: Ask Piyush how to deal with this
        commonMethods *common = [[commonMethods alloc] init];
        [common checkNetworkForCloudStorage:@"isLog"];

    }
}

- (void)checkNetworkForCloudStorage{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable){
        
        [CheckReachability.sharedManager startNetworkMonitoring];
    } else {
        
        [self performSelectorInBackground:@selector(fetchDataFromSyncTable) withObject:nil];
    }
}

//Loop through the Phone Sync table, fetch table name, type (add, edit, del) and rowID of record
- (void)fetchDataFromSyncTable{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'LOG_TABLE' OR tableName == 'LOC_TABLE'"];
    [request setPredicate:predicate];
    NSArray *dataArray = [context executeFetchRequest:request error:&error];
    
    for(Sync_Table *syncData in dataArray){
        
        NSString *type = syncData.type;
        //NSInteger rowID = [syncData.rowID integerValue];
        if(syncData.rowID == nil){

            NSError *err;
            if(syncData != nil){

                [context deleteObject:syncData];
            }

            if ([context hasChanges])
            {
                BOOL saved = [context save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
                [[CoreDataController sharedInstance] saveBackgroundContext];
                [[CoreDataController sharedInstance] saveMasterContext];
            }
        }else{

            [self setParametersWithType:type andRowID:syncData.rowID andTableName:syncData.tableName];
        }
    }
}

//Loop thr' the specified tableName and get record for specified rowID
- (void)setParametersWithType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    
    if([tableName isEqualToString:@"LOG_TABLE"]){
        
        NSError *error;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
        NSPredicate *iDPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
        [request setPredicate:iDPredicate];
        
        NSArray *fetchedData = [contex executeFetchRequest:request error:&error];
        
        T_Fuelcons *logData = [fetchedData firstObject];
        
        NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [logData.vehid intValue]];
        [vehRequest setPredicate:vehPredicate];
        
        NSArray *vehData = [[contex executeFetchRequest:vehRequest error:&error] mutableCopy];
        
        Veh_Table *vehicleData = [vehData firstObject];
        
        commonMethods *common = [[commonMethods alloc] init];
        NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:logData.stringDate];
        
        
        NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        
        
        if([def objectForKey:@"UserEmail"] != nil){
            [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"email"];
        }
        [parametersDictionary setObject:@"phone" forKey:@"source"];
        
        if(type != nil){
            [parametersDictionary setObject:type forKey:@"type"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"type"];
        }

        //Added new parameter for friend stuff
        [parametersDictionary setObject:@"self" forKey:@"originalSource"];
        
        if(rowID != nil){
            [parametersDictionary setObject:rowID forKey:@"_id"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"_id"];
        }
        
        if([def objectForKey:@"UserDeviceId"] != nil){
            [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"androidId"];
        }
        [parametersDictionary setObject:[epochDictionary valueForKey:@"day"] forKey:@"day"];
        [parametersDictionary setObject:[epochDictionary valueForKey:@"month"] forKey:@"month"];
        [parametersDictionary setObject:[epochDictionary valueForKey:@"year"] forKey:@"year"];
        [parametersDictionary setObject:[epochDictionary valueForKey:@"epochTime"] forKey:@"date"];
        
        if(logData.type != nil){
            [parametersDictionary setObject:logData.type forKey:@"rec_type"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"rec_type"];
        }
        
        if(vehicleData.vehid != nil){
            [parametersDictionary setObject:vehicleData.vehid forKey:@"vehid"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"vehid"];
        }
        
        if(logData.odo != nil){
            [parametersDictionary setObject:logData.odo forKey:@"odo"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"odo"];
        }
        
        if(logData.qty != nil){
            [parametersDictionary setObject:logData.qty forKey:@"qty"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"qty"];
        }
        
        if(logData.pfill != nil){
            [parametersDictionary setObject:logData.pfill forKey:@"pfill"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"pfill"];
        }
        
        if(logData.mfill != nil){
            [parametersDictionary setObject:logData.mfill forKey:@"mfill"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"mfill"];
        }
        
        if(logData.cost != nil){
            [parametersDictionary setObject:logData.cost forKey:@"cost"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"cost"];
        }
        
        //NSLog(@"distance : %@", logData.dist);
        //NSLog(@"consump : %@", logData.cons);
        
        if(logData.dist != nil){
            [parametersDictionary setObject:logData.dist forKey:@"dist"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"dist"];
        }
        
        if(logData.cons != nil){
            [parametersDictionary setObject:logData.cons forKey:@"cons"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"cons"];
        }
        //BUG_157 NIKHIL keyName octane changed to ocatne
        if(logData.octane != nil){
            [parametersDictionary setObject:logData.octane forKey:@"octane"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"octane"];
        }
        
        if(logData.fuelBrand != nil){
            [parametersDictionary setObject:logData.fuelBrand forKey:@"fuelBrand"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"fuelBrand"];
        }
        
        if(logData.fillStation != nil){
            [parametersDictionary setObject:logData.fillStation forKey:@"fillStation"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"fillStation"];
        }
        
        if(logData.notes != nil){
            [parametersDictionary setObject:logData.notes forKey:@"notes"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"notes"];
        }
        
        if(logData.serviceType != nil){
            [parametersDictionary setObject:logData.serviceType forKey:@"serviceType"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"serviceType"];
        }
        
        //New_11 added properties to sync
        
        if(logData.longitude != nil){
            
            [parametersDictionary setObject:logData.longitude forKey:@"depLong"];
        }
        if(logData.latitude != nil){
            
            [parametersDictionary setObject:logData.latitude forKey:@"depLat"];
        }
        
        //ENH_54 Start here for making single syncfree4june2018
        BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
        if(logData.receipt != nil && logData.receipt.length > 0 && proUser){
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths firstObject];
            NSString *imagePath = logData.receipt;
            NSArray *separatedArray = [imagePath componentsSeparatedByString:@":::"];
            NSString *imageString;
            NSMutableDictionary *receiptDict = [[NSMutableDictionary alloc]init];
            for(int i=0;i<separatedArray.count;i++){
                
                NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", [separatedArray objectAtIndex:i]]];
            
                UIImage *receiptImage = [UIImage imageWithContentsOfFile:completeImgPath];
            
                NSData *imageData = UIImagePNGRepresentation(receiptImage);
            
                float imgSizeInMB = [imageData length] / 1024.0f / 1024.0f;
            
                
            
                //If images are > than 1.5 MB, compress them and then send to server
                if(imgSizeInMB > 1.5){
                
                    UIImage *smallImg = [[commonMethods class] imageWithImage:receiptImage scaledToSize:CGSizeMake(300.0, 300.0)];
                    NSData *compressedImg = UIImagePNGRepresentation(smallImg);
                    imageString = [compressedImg base64EncodedStringWithOptions:0];
                    //NSLog(@"compressed img of size : %ld", [compressedImg length]);
                
                } else {
                
                    //NSLog(@"full img of size : %ld", [imageData length]);
                
                    imageString = [imageData base64EncodedStringWithOptions:0];
                }
                NSString *receiptName = [separatedArray objectAtIndex:i];
                [receiptDict setObject:imageString forKey:[NSString stringWithFormat:@"%@",receiptName]];
              }
                NSString *colonString = [NSString stringWithFormat:@"%@:::",logData.receipt];
                [parametersDictionary setObject:colonString forKey:@"receipt"];
             //   if(separatedArray.count>1){
                    [parametersDictionary setObject:receiptDict forKey:@"img_file"];
//                }else{
//
//                    [parametersDictionary setObject:imageString forKey:@"img_file"];
//                }
             } else {
            
                [parametersDictionary setObject:@"" forKey:@"receipt"];
                [parametersDictionary setObject:@"" forKey:@"img_file"];
             }
        
          //NSLog(@"Log params dict : %@", parametersDictionary);
        
        NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&error];
        [def setBool:YES forKey:@"updateTimeStamp"];
        //Pass paramters dictionary and URL of script to get response
        [common saveToCloud:postData urlString:kLogDataScript success:^(NSDictionary *responseDict) {
           // NSLog(@"responseDict LOG : %@", responseDict);
            
            if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
                
                [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
            }
        } failure:^(NSError *error) {
           // NSLog(@"%@", error.localizedDescription);
        }];
        //   }];
        
    } else if ([tableName isEqualToString:@"LOC_TABLE"]){
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSError *locErr;
        NSFetchRequest *locRequest = [[NSFetchRequest alloc] initWithEntityName:@"Loc_Table"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
        [locRequest setPredicate:predicate];
        
        NSArray *locArray = [contex executeFetchRequest:locRequest error:&locErr];
        
        Loc_Table *locationData = [locArray firstObject];
        
        NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
        
        if([def objectForKey:@"UserDeviceId"] != nil){
            [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"androidId"];
        }
        
        if([def objectForKey:@"UserEmail"] != nil){
            [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"email"];
        }
        
        if(type != nil){
            [parametersDictionary setObject:type forKey:@"type"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"type"];
        }
        
        if(rowID != nil){
            [parametersDictionary setObject:rowID forKey:@"_id"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"_id"];
        }
        
        if([locationData.lat floatValue] != 0.0){
            [parametersDictionary setObject:locationData.lat forKey:@"lat"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"lat"];
        }
        
        if([locationData.longitude floatValue] != 0.0){
            [parametersDictionary setObject:locationData.longitude forKey:@"long"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"long"];
        }
        
        if(locationData.address != nil){
            [parametersDictionary setObject:locationData.address forKey:@"address"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"address"];
        }
        
        if(locationData.brand != nil){
            [parametersDictionary setObject:locationData.brand forKey:@"brand"];
        } else {
            [parametersDictionary setObject:@"" forKey:@"brand"];
        }
        
        //NSLog(@"Log params dict : %@", parametersDictionary);
        
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&error];
        [def setBool:YES forKey:@"updateTimeStamp"];
        commonMethods *common = [[commonMethods alloc] init];
        //Pass paramters dictionary and URL of script to get response
        [common saveToCloud:postData urlString:kLocationScript success:^(NSDictionary *responseDict) {
            //NSLog(@"responseDict LOG : %@", responseDict);
            
            if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
                
                [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
            }
        } failure:^(NSError *error) {
            //NSLog(@"%@", error.localizedDescription);
        }];
        
    }
}



#pragma mark pageViewController
//Swapnil 7 Mar-17

- (void)createPageVC{
    
    if(![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"fillupLaunch"]]){
        
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"fillupLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        navigationOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        navigationOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        
        [self.navigationController.view addSubview:navigationOverlay];
        
        //NSString *fill_up_custom_msg = @"Customize this screen to add new fields, remove fields, attach receipts, etc";
        self.pageTitles = @[NSLocalizedString(@"fill_up_custom_msg", @"Customize this screen to add new fields, remove fields, attach receipts, etc")];
        self.imagesArray = @[@"help_arrow2.png"];
        //Create page view controller
        
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FillupPageViewController"];
        self.pageViewController.dataSource = self;
        FillupPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:nil];
        
        //change size of page view controller
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 48);
        [self addChildViewController:self.pageViewController];
        [self.view addSubview:self.pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
        
        UITapGestureRecognizer *tapToDissmiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmissAction)];
        [self.pageViewController.view addGestureRecognizer:tapToDissmiss];
    }
    
}

#pragma mark - PAGEVIEWCONTROLLER Delegate methods

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    NSUInteger index = ((FillupPageContentViewController *) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound)){
        
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    NSUInteger index = ((FillupPageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound){
        return nil;
    }
    
    index++;
    
    if (index == [self.pageTitles count]){
        
        //NSLog(@"%lu", [self.pageTitles count]);
        
        
        
        return nil;
    }
    
    
    return [self viewControllerAtIndex:index];
}

- (void)dissmissAction{
    
    [self.pageViewController.view removeFromSuperview];
    [self.pageViewController removeFromParentViewController];
    [navigationOverlay removeFromSuperview];
}

-(FillupPageContentViewController *)viewControllerAtIndex:(NSUInteger)index{
    
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        
        
        return nil;
    }
    
    FillupPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FillupPageContentViewController"];
    pageContentViewController.labelText = self.pageTitles[index];
    pageContentViewController.imageText = self.imagesArray[index];
    pageContentViewController.pageIndex = index;
    return pageContentViewController;
    
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    
    return 0;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    
    return 0;
}

@end
