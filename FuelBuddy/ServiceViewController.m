//
//  ServiceViewController.m
//  FuelBuddy
//
//  Created by Surabhi on 16/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "ServiceViewController.h"
#import "AppDelegate.h"
#import "Veh_Table.h"
#import "ServiceTypeViewController.h"
#import "T_Fuelcons.h"
#import "Services_Table.h"
#import "UIImage+ResizeImage.h"
#import "JRNLocalNotificationCenter.h"
#import "LogViewController.h"
#import "commonMethods.h"
#import "Sync_Table.h"
#import "Reachability.h"
#import "WebServiceURL's.h"
#import <Crashlytics/Crashlytics.h>
#import "SerReceiptViewController.h"
#import "SerReceiptCollectionViewCell.h"
#import "GoProViewController.h"
#import "LocationServices.h"
#import "CheckReachability.h"
//Added for service centre rating
//#import <GooglePlaces/GooglePlaces.h>
//#import "PlacesTableViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import <GooglePlaces/GMSAutocompleteFetcher.h>
#import <GoogleMapsBase/GoogleMapsBase.h>

@interface ServiceViewController ()
{
    float prevOdo;
    //NIKHIL BUG_125
    CGFloat oldX;
    CGFloat oldY;
    NSString* recOrder;
    UIScrollView *scrollview;
    UITextField *currentField;
    CGPoint buttonOrigin;
    NSNumber *saveCurLat;
    NSNumber *saveCurLong;
    NSString *autocompleteQuery;
    CLLocationManager *locationManager;
    GMSCoordinateBounds *bounds;
    GMSAutocompleteSessionToken *token;
    GMSAutocompleteFilter *_filter;
    //GMSPlacesClient *placesClient;
    //NSMutableArray *placesNameArray;
   // NSMutableArray *placesAddressArray;
    //NSMutableArray *placesIDsArray;
    //NSMutableDictionary *feedBackDataDict;
    //For feedback view
    //FeedBackView *feedBackView;
    
}
//NIKHIL BUG_131 //added property
@property int selPickerRow;

@end

//Swapnil 15 Mar-17
//static GADMasterViewController *shared;
@implementation ServiceViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odovalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"odofilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datevalue"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"datefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"notefilter"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"recordfilter"];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    [self fetchdata];
    // Do any additional setup after loading the view.
    
    self.servicearray=[[NSMutableArray alloc]init];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"selectservice"];
    // NSLog(@"array service %@",self.servicearray);
    
//    NSString *tc_tv = @"Total Cost";
//    NSString *notes_tv = @"Notes";
//    NSString *attach_receipt = @"Attach receipt";
//    NSString *tot_services = @"Services";
//    NSString *tv_service_center = @"Service Center";
    
    self.textplace=[[NSMutableArray alloc]initWithObjects:
                    @"Select",
                    NSLocalizedString(@"date", @"Date"),
                    NSLocalizedString(@"odometer", @"Odometer"),
                    NSLocalizedString(@"tot_services", @"Services"),
                    NSLocalizedString(@"tv_service_center", @"Service Center"),
                    NSLocalizedString(@"tc_tv", @"total cost"),
                    NSLocalizedString(@"notes_tv", @"Notes"),
                    NSLocalizedString(@"attach_receipt", @"attach receipt"), nil];
    
    //[self fetchservice];
    //[self addtext];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]!=nil)
    {
        //Editdata *e = [[Editdata alloc]init];
        
        
        self.details = [[[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]mutableCopy];
    }
    [[NSUserDefaults standardUserDefaults]setObject:@"yes" forKey:@"reloadtext"];
    //ENH_57
    self.receiptImageArray = [[NSMutableArray alloc]init];
   // [self fetchCurrentLocation];

    //[self getLocation];
    //token = [[GMSAutocompleteSessionToken alloc] init];
   // _filter = [[GMSAutocompleteFilter alloc] init];
   // _filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;

   // placesClient = [[GMSPlacesClient alloc] init];

   // placesNameArray = [[NSMutableArray alloc] init];
   // placesAddressArray = [[NSMutableArray alloc] init];
   // placesIDsArray = [[NSMutableArray alloc] init];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(feedBackGivenDismissView)
//                                                 name:@"feedBackViewDismissed"
//                                               object:nil];
}

-(void) getLocation{

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{

    [self fetchprevcenters];
    //NIKHIL BUG_125
    //To scroll contentview when keyboard appears
   
    [self registerForKeyboardNotifications];
   
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"reloadtext"]isEqualToString:@"yes"])
    {
        
        [self addtext];
        
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]!=nil)
        {
            //Editdata *e = [[Editdata alloc]init];
     
            //self.details = [[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"];
            // NSLog(@"edit details %@",self.details);
            UITextField *text1 = [self.view viewWithTag:1];
            UITextField *text2 = [self.view viewWithTag:2];
            UITextField *text3 = [self.view viewWithTag:3];
            UITextField *text5 = [self.view viewWithTag:5];
            UITextField *text4 = [self.view viewWithTag:4];
            UITextView *text6 = [self.view viewWithTag:12];
            
            
            // UILabel *label1 = [self.view viewWithTag:20];
            UILabel *label2 = [self.view viewWithTag:40];
            UILabel *label3 = [self.view viewWithTag:60];
            UILabel *label5 = [self.view viewWithTag:100];
            UILabel *label4 = [self.view viewWithTag:80];
            
      
            NSDateFormatter *f=[[NSDateFormatter alloc] init];
            [f setDateFormat:@"dd-MMM-yyyy"];
            NSDate *date = [f dateFromString:[self.details objectForKey:@"date"]];
            
            text1.text=[f stringFromDate:date];
            text2.text = [[self.details objectForKey:@"odo"]stringValue];
            if([[self.details objectForKey:@"cost"]floatValue]!=0)
            {
                text5.text = [NSString stringWithFormat:@"%.2f",[[self.details objectForKey:@"cost"]floatValue]];
                
            }
            
            self.servicearray = [[NSMutableArray alloc] initWithArray: [[self.details objectForKey:@"service"]componentsSeparatedByString:@","]];
            [[NSUserDefaults standardUserDefaults]setObject:self.servicearray forKey:@"selectservice"];
            
            text3.text = [self.details objectForKey:@"service"];
            text4.text = [self.details objectForKey:@"filling"];
            //text9.text = [self.details objectForKey:@"filling"];
            text6.text = [self.details objectForKey:@"notes"];
            
            
            //        if(text1.text.length != 0)
            //        {
            //            [self labelanimatetoshow:label1];
            //        }
            
            if(text2.text.length != 0)
            {
                [self paddingTextFields:text2];
                [self labelanimatetoshow:label2];
            }
            
            if(text3.text.length != 0)
            {
                [self labelanimatetoshow:label3];
            }
            
            if(text5.text.length != 0)
            {
                [self paddingTextFields:text5];
                [self labelanimatetoshow:label5];
            }
            
            if(text4.text.length != 0)
            {
                [self paddingTextFields:text4];
                [self labelanimatetoshow:label4];
            }
            
            
//            if(text6.text.length != 0)
//            {
//                [self labelanimatetoshow:label6];
//            }
            NSString *emptyString = @"";
            if([self.details objectForKey:@"receipt"] !=nil && ![[self.details objectForKey:@"receipt"] isEqualToString:emptyString])
            {
                
                NSString *imageString = [self.details objectForKey:@"receipt"];
                NSArray *separatedPaths = [imageString componentsSeparatedByString:@":::"];
                [self.receiptImageArray addObjectsFromArray:separatedPaths];
                //  NSLog(@"self.receiptImageArray:- %@",self.receiptImageArray);
                [self.serviceCollectionView reloadData];
            }
            
        }
        
        
        
    }
//    NSString *add_service = @"Add Service";
//    NSString *edit_service = @"Edit Service";
    
    self.navigationItem.title=[NSLocalizedString(@"add_service", @"Add Service") capitalizedString];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]!=nil)
    {self.navigationItem.title=[NSLocalizedString(@"edit_service", @"Edit service") capitalizedString];}
        
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"selectservice"] != nil)
    {
        
        self.servicearray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectservice"]mutableCopy];
    }
    
    UITextField *Service = (UITextField *)[self.view viewWithTag:3];
    UILabel *label = (UILabel *)[self.view viewWithTag:60];
    Service.userInteractionEnabled = NO;
    if(self.servicearray.count!=0)
    {
        Service.text = [self.servicearray componentsJoinedByString:@","];
        [self paddingTextFields:Service];
        [self labelanimatetoshow:label];
        // NSLog(@"service text %@",Service.text);
    }
    
    if(self.servicearray.count == 0){
        Service.text = @"";
        [self labelanimatetohide:label];
        UIView *padView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        Service.leftView = padView;
        Service.leftViewMode = UITextFieldViewModeAlways;
    }
    
    [self.serviceCollectionView reloadData];

}



-(void)viewDidAppear:(BOOL)animated
{
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.saveButton];
    self.navigationItem.rightBarButtonItem=[barButtonItem initWithTitle:NSLocalizedString(@"save", @"Save") style:UIBarButtonItemStylePlain target:self action:@selector(saveservices)];
    self.saveButton.userInteractionEnabled = true;

    UITextField *text3 = [self.view viewWithTag:3];
    UITextField *text2 = [self.view viewWithTag:2];
    UITextField *text5 = [self.view viewWithTag:5];
    UITextField *text4 = [self.view viewWithTag:4];

    
    UILabel *label3 = [self.view viewWithTag:60];
    
    if(text3.text.length == 0){
        label3.hidden = YES;
    }
    if(text2.text.length != 0){
        [self paddingTextFields:text2];
    }
    if(text4.text.length != 0){
        [self paddingTextFields:text4];
    }
    if(text5.text.length != 0){
        [self paddingTextFields:text5];
    }

   // feedBackDataDict = [[NSMutableDictionary alloc] init];
}
//NIKHIL BUG_125 added below method
-(void)viewWillDisappear:(BOOL)animated
{
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
    
}

-(void)fetchprevcenters{

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];

    // NSLog(@"compare %@",comparestring);
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    // NSLog(@"compare string %@",comparestring);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND type=1",comparestring];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setPredicate:predicate];
    [requset setSortDescriptors:sortDescriptors];


    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    self.centerArray=[[NSMutableArray alloc]init];

    for(T_Fuelcons *fuel in datavalue)
    {
        if(![self.centerArray containsObject:fuel.fillStation] && fuel.fillStation!=nil)
        {
            [self.centerArray addObject:fuel.fillStation];
        }

    }

}


-(void)fetchCurrentLocation{
    
    //Request current location
    [[LocationServices sharedInstance].locationManager requestLocation];
    
    //Get latest locn in currentLocation
    CLLocation *currentLocation = [LocationServices sharedInstance].latestLoc;
    
    saveCurLat = [NSNumber numberWithDouble: currentLocation.coordinate.latitude];
    saveCurLong = [NSNumber numberWithDouble: currentLocation.coordinate.longitude];

}

//ENH_57
#pragma mark - UICollectionView Delegate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
        return self.receiptImageArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SerReceiptCollectionViewCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
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
    //    UIImage *image = [UIImage imageNamed:@"add_receipt"];
    //    if(image.size.width < image.size.height){
    return CGSizeMake(60, 80);
    //    }else{
    //       return CGSizeMake(70, 50);
    //    }
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
        
        //ENH_57 expandImage
        SerReceiptViewController *receiptVC = [self.storyboard instantiateViewControllerWithIdentifier:@"receiptViewContoller"];
        receiptVC.receiptDelegate = self;
        receiptVC.receiptsArray = self.receiptImageArray;
        receiptVC.index = (int)indexPath.row;
        receiptVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:receiptVC animated:YES];
        
        
    }
    
    
}

-(void)sendDataToA:(NSMutableArray *)sendArray
{
    //NSLog(@"alelaArray:- %@",sendArray);
    NSArray *copyArray = [[NSArray alloc] initWithArray:sendArray];
    [self.receiptImageArray removeAllObjects];
    [self.receiptImageArray addObjectsFromArray:copyArray];
 /*
    //ENH_57 to save multiple receipt
    if(self.receiptImageArray.count == 0){
        [self.details setValue:nil forKey:@"receipt"];
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
        [self.details setObject:finalString forKey:@"receipt"];
        [self.serviceCollectionView reloadData];
    } */
}

//Added to ask user to GoPro 30may2018 nikhil
- (void)goProAlertBox{
    
    NSString *title = @"Only one receipt allowed in Free version, Go Pro?";
    NSString *message = @"";
    
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

//-(void)feedBackGivenDismissView{
//
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(void)backbuttonclick
{
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    
    UITextField *date = (UITextField *)[self.view viewWithTag:1];
    
    UITextField *service = (UITextField *) [self.view viewWithTag:3];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSObject * object = [prefs objectForKey:@"editdetails"];
    if(object != nil){
        //Edit
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (odometer.text.length > 0 && service.text.length > 0 && date.text.length > 0)
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
                                         [self saveservices];
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

//
//-(void)deleteimage
//
//{
//    //Swapnil 25 Apr-2017
//    NSFileManager *filemanager = [NSFileManager defaultManager];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//
//    //Swapnil ENH_24
//    NSString *documentsDirectory = [paths firstObject];
//
//    NSString *imagePath = self.imagepath;
//    NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", imagePath]];
//    NSError *error;
//    //NSLog(@"complete path = %@", completeImgPath);
//    [filemanager removeItemAtPath:completeImgPath error:&error];
//    [self.details setValue:nil forKey:@"receipt"];
//
//    _receipt.image=[UIImage imageWithContentsOfFile:imagePath];
//    _deleteimg.image=nil;
//    _deleteview.hidden = YES;
//}


-(void)addtext
{
    AppDelegate *app = [AppDelegate sharedAppDelegate];
    self.result=app.result;
    
    scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0,60, app.result.width,app.result.height)];
    
    scrollview.showsVerticalScrollIndicator=YES;
    scrollview.scrollEnabled=YES;
    scrollview.userInteractionEnabled=YES;
    scrollview.contentSize = CGSizeMake(app.result.width,app.result.height+220);
    scrollview.tag=-3;
    [self.view addSubview:scrollview];
    UIView *bgview = [[UIView alloc]init];
    bgview.frame = CGRectMake(0, 0, app.result.width, app.result.height+220);
    bgview.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    bgview.tag=-2;
    [scrollview addSubview:bgview];
    
    
    int y=0;
    for(int i= 0; i<self.textplace.count;i++)
    {
        
        if(![[self.textplace objectAtIndex:i]isEqualToString:@""])
        {
            UITextField *text = [[UITextField alloc]init];
            //NIKHIL BUG_130 aaded notes textview
            UITextView *notesTextView = [[UITextView alloc]init];
            
            text.frame = CGRectMake(10,y,self.result.width-30,80);//NIKHIL ENH_42 //frame height 51 to 70
           // text.backgroundColor = [UIColor redColor];
            text.tag=i;
            text.textColor=[UIColor whiteColor];
            text.font =[UIFont systemFontOfSize:13];
            
            notesTextView.textColor=[UIColor whiteColor];
            notesTextView.font =[UIFont systemFontOfSize:13];

            
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"odometer", @"Odometer")])
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
                text.frame = CGRectMake(10,y+15,self.result.width-30,70);//NIKHIL ENH_42 //y to y20 frame height 51 to 70
                //NIKHIL ENH_42 9 //underlined odometer
                UILabel *odoLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, text.frame.origin.y+45, text.frame.size.width-100, 0.65)];
                odoLineLabel.backgroundColor = [UIColor lightGrayColor];
                [bgview addSubview:odoLineLabel];
                //till here
            }
            
            
            
            if([[self.textplace objectAtIndex:i]isEqualToString:@"Select"])
            {
                UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,60, 20)];
                text.leftView = paddingView;
                text.leftViewMode = UITextFieldViewModeAlways;
                text.enabled=NO;
                
                if([[self.textplace objectAtIndex:i] isEqualToString:@"Select"])
                {
                    if([[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]!=nil)
                    {
                        text.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
                    }
                    else
                    {
                        text.text = @"";
                    }
                    text.frame = CGRectMake(0,y,app.result.width,51);
                    
                    text.tag=-9;
                    
                }
                
                
            }
            
            
            
            text.placeholder = [self.textplace objectAtIndex:i];
            text.delegate=self;
            //NIKHIL BUG_130 delegate = self
            notesTextView.delegate = self;
            //text.textAlignment=NSTextAlignmentCenter;
            [self textfieldsetting:text];
            [bgview addSubview:text];
            y=y+50;
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
                odo.frame = CGRectMake(text.frame.size.width-100, 25, 50, 20);//NIKHIL ENH_42 //y 15 to 25, width-40to-100
                odo.textColor = [UIColor grayColor];
                odo.font = [UIFont systemFontOfSize:13];
                
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
            
            
            
            if([[self.textplace objectAtIndex:i] isEqualToString:NSLocalizedString(@"tc_tv", @"Total Cost")])
            {
                UILabel *odo = [[ UILabel alloc]init];
                odo.frame = CGRectMake(text.frame.size.width-100, 25, 50, 20);//NIKHIL ENH_42 //y 15 to 25
                odo.textColor = [UIColor grayColor];
                odo.font = [UIFont systemFontOfSize:13];
                NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:@"curr_unit"] componentsSeparatedByString:@"-"];
                NSString *string = [array lastObject];
                odo.text = string;
                [text addSubview:odo];
                text.keyboardType =UIKeyboardTypeDecimalPad;
                
                
                UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
                numberToolbar.barStyle = UIBarStyleDefault;
                numberToolbar.backgroundColor =[UIColor whiteColor];
                numberToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                       [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                                       nil];
                
                [numberToolbar sizeToFit];
                text.inputAccessoryView = numberToolbar;
                text.frame = CGRectMake(10,y+30,self.result.width-30,70);//NIKHIL ENH_42 //y to y+20 frame height 51 to 70
                //NIKHIL ENH_42 //underlined total
                UILabel *odoLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, text.frame.origin.y+45, text.frame.size.width-100, 0.65)];
                odoLineLabel.backgroundColor = [UIColor lightGrayColor];
                [bgview addSubview:odoLineLabel];
                //till here
            }
            
            
            
            //            if([[self.textplace objectAtIndex:i] isEqualToString:@"Odometer"])
            //            {
            //                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"filluptype"]isEqualToString:@"Trip"])
            //                {
            //                    text.placeholder=@"Trip";
            //                    label.text =@"Trip";
            //                }
            //            }
            
            
            if([[self.textplace objectAtIndex:i] isEqualToString:@"Select"])
            {
                text.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
                CGSize stringsize = [text.text sizeWithAttributes:@{NSFontAttributeName:text.font}];
                dropdown = [[UIButton alloc]init];
                dropdown.frame=CGRectMake(stringsize.width+60, text.frame.origin.y+7, 40, 40);
                [dropdown setImage:[UIImage imageNamed:@"dowpdown_white"] forState:UIControlStateNormal];
                [dropdown addTarget:self action:@selector(openselectpicker) forControlEvents:UIControlEventTouchUpInside];
                [text addSubview:dropdown];
                UIButton *bgbutton = [[UIButton alloc]init];
                bgbutton.frame =CGRectMake(text.frame.origin.x, text.frame.origin.y+5, text.frame.size.width, text.frame.size.height);
                bgbutton.titleLabel.text=@"";
                bgbutton.backgroundColor =[UIColor clearColor];
                bgbutton.tag = -6;
                [bgbutton addTarget:self action:@selector(openselectpicker) forControlEvents:UIControlEventTouchUpInside];
                [bgview addSubview:bgbutton];
                
                
                _vehimage = [[UIImageView alloc]init];
                _vehimage.frame = CGRectMake(5,1, 45, 45);//NIKHIL ENH_42 //y0 to 1
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
            
                NSDateFormatter *f=[[NSDateFormatter alloc] init];
                [f setDateFormat:@"dd-MMM-yyyy"];
                NSString *date=[f stringFromDate:[NSDate date]];
                text.text=date;
                UIButton *bgbutton = [[UIButton alloc]init];
                bgbutton.frame =CGRectMake(text.frame.origin.x, text.frame.origin.y+5, text.frame.size.width, text.frame.size.height);
                
//                [bgbutton setTitle:@"Date" forState:UIControlStateNormal];
//                [bgbutton.titleLabel setFont:[UIFont systemFontOfSize:10]];
//                [bgbutton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                
                //NIKHIL ENH_42 //Added dateLabel
                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,55, 50, 40)];
                dateLabel.text = @"Date";
                dateLabel.textColor = [UIColor lightGrayColor];
                dateLabel.font = [UIFont systemFontOfSize:10];
                //till here
                
                bgbutton.tag=-5;
                bgbutton.backgroundColor =[UIColor clearColor];
                [bgbutton addTarget:self action:@selector(openpicker:) forControlEvents:UIControlEventTouchUpInside];
                
                //NIKHIL ENH_42 //Adding date image
                _date = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"date"]];
                _date.frame = CGRectMake(text.frame.origin.x+90, text.frame.origin.y+32, 12, 12);
                _date.contentMode = UIViewContentModeScaleAspectFill;
                _date.clipsToBounds = YES;
                [bgview addSubview:_date];
                _date.userInteractionEnabled = YES;
                //till here
                [bgview addSubview:dateLabel];
                [bgview addSubview:bgbutton];
                
            }
            
            if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"attach_receipt", @"Attach receipt") ])
            {
                //NIKHIL ENH_42 //frame added to receipt
                text.frame = CGRectMake(10,y+70,self.result.width-30,70);
                [text setUserInteractionEnabled:false];
                UIButton *bgbutton = [[UIButton alloc]init];
                bgbutton.frame =CGRectMake(text.frame.origin.x, text.frame.origin.y+11, text.frame.size.width, text.frame.size.height);
                bgbutton.titleLabel.text=@"";
                [bgbutton.titleLabel setFont:[UIFont systemFontOfSize:10]];
                bgbutton.backgroundColor =[UIColor clearColor];
                //[bgbutton addTarget:self action:@selector(pictureclick) forControlEvents:UIControlEventTouchUpInside];
                
                //NIKHIL BUG_137 // changed the value of reload text to NO for edited record
                [[NSUserDefaults standardUserDefaults]setObject:@"no" forKey:@"reloadtext"];
               /*
                UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(_result.width-220, 0, 40, 40)];
                [button setImage:[UIImage imageNamed:@"attach"] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(pictureclick) forControlEvents:UIControlEventTouchUpInside];
                [bgview addSubview:bgbutton];
                [bgbutton addSubview:button];
                
                yaxis = y+20;
                */
                
                UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
                _serviceCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(text.frame.origin.x, y+120,text.frame.size.width,200) collectionViewLayout:layout];
                [_serviceCollectionView setDataSource:self];
                [_serviceCollectionView setDelegate:self];
                
                [_serviceCollectionView registerClass:[SerReceiptCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
                [_serviceCollectionView setBackgroundColor:[UIColor clearColor]];
                
                [bgview addSubview:_serviceCollectionView];
                
               /*
                _receipt = [[UIImageView alloc]init];
                // _imageframe = (40, y+20, 50, 50);
                _receipt.frame =CGRectMake(text.frame.origin.x, y+120,text.frame.size.width,200);
                _receipt.tag=-1;
                //_receipt.hidden=YES;
                // _receipt.image=[UIImage imageNamed:@"add_photo"];
                _receipt.contentMode = UIViewContentModeScaleAspectFill;
                _receipt.clipsToBounds = YES;
                [bgview addSubview:_receipt];
                _receipt.userInteractionEnabled=YES;
                _deleteview = [[UIView alloc]init];
                _deleteview.frame = CGRectMake(250, 0, 40, 40);
                _deleteview.backgroundColor=[UIColor blackColor];
                _deleteview.alpha =0.6;
                [self.receipt addSubview: _deleteview];
                _deleteview.userInteractionEnabled=YES;
                _deleteimg = [[UIImageView alloc]init];
                _deleteimg.frame = CGRectMake(10,10, 20, 20);
                _deleteview.hidden=YES;
                _deleteimg.userInteractionEnabled=YES;
                UITapGestureRecognizer *Tap =
                [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteimage)];
                [_deleteimg addGestureRecognizer:Tap];
                [_deleteview addSubview:_deleteimg];
                
                */
            }
            
            
            if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"tot_services", @"Services")])
            {
                text.frame = CGRectMake(10,y-10,self.result.width-30,70);//NIKHIL ENH_42 //frame height 51 to 70
                UIButton *bgbutton = [[UIButton alloc]init];
                bgbutton.frame =CGRectMake(text.frame.origin.x, text.frame.origin.y+5, text.frame.size.width, text.frame.size.height);
                bgbutton.titleLabel.text=@"";
                [bgbutton.titleLabel setFont:[UIFont systemFontOfSize:10]];
                bgbutton.backgroundColor =[UIColor clearColor];
                [bgbutton addTarget:self action:@selector(serviceclick) forControlEvents:UIControlEventTouchUpInside];
                
                UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(_result.width-145, 10, 40, 40)];//NIKHIL ENH_42 //shifted > to left
                [button setImage:[UIImage imageNamed:@"chevron"] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(serviceclick) forControlEvents:UIControlEventTouchUpInside];
                
                [bgview addSubview:bgbutton];
                [bgbutton addSubview:button];

            }
            //added if for service centre frame
            if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"tv_service_center", @"Service center")])
            {
                text.frame = CGRectMake(10,y+10,self.result.width-30,70);//NIKHIL ENH_42 //y to y+20,frame height 51 to 70
                //NIKHIL ENH_42 //underlined service center
                UILabel *odoLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, text.frame.origin.y+45, text.frame.size.width-100, 0.65)];
                odoLineLabel.backgroundColor = [UIColor lightGrayColor];
                [bgview addSubview:odoLineLabel];

                // adding tableView View to show centers
//                _placesTableView = [[UITableView alloc] initWithFrame:CGRectMake(text.frame.origin.x+20, text.frame.origin.y-10, self.view.frame.size.width-40, 300) style:UITableViewStylePlain];
//                _placesTableView.delegate = self;
//                _placesTableView.dataSource = self;
//                _placesTableView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
//               // _placesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//                _placesTableView.rowHeight = 50;
//                //set footer for tableview saying powered by google
//                [self.view addSubview:_placesTableView];
//                _placesTableView.hidden = true;


               // till here
            }
            //added if for notes frame
            if([[self.textplace objectAtIndex:i]isEqualToString:NSLocalizedString(@"notes_tv", @"Notes")])
            {
               // text.frame = CGRectMake(10,y+50,self.result.width-30,70);//NIKHIL ENH_43 //y to y+20,frameheight 51 to 70
                
                
                    //NIKHIL BUG_130 added notes text view
                    notesTextView.frame = CGRectMake(10,y+84,self.result.width-30,40);
                    notesTextView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
                    text.userInteractionEnabled = false;
                    label.font =[UIFont systemFontOfSize:10];
                    text.frame = CGRectMake(10,y+60,self.result.width-30,35);
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

//-(void)addFeedBackView{
//
//    feedBackView = [[FeedBackView alloc] init];
//    feedBackView.frame = self.view.bounds;
//    feedBackView.contentMode = UIViewContentModeScaleAspectFit;
//    feedBackView.cmntsTextView.delegate = self;
//    feedBackView.cmntsTextView.tag = 100; //to dismiss keyboard and move view up
//    feedBackView.centerNameLabel.text = [feedBackDataDict objectForKey:@"name"];
//    feedBackView.centerAddressLabel.text = [feedBackDataDict objectForKey:@"address"];
//    feedBackView.feedBackDataDict = feedBackDataDict;
//
//
//    [self.view addSubview:feedBackView];
//}

-(void)serviceclick
{
    ServiceTypeViewController *service = (ServiceTypeViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"servicetype"];
    service.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:service animated:YES];
}

-(void)doneWithNumberPad
{
    UITextField *odo = (UITextField *) [self.view viewWithTag:2];
    UITextField *total = (UITextField *) [self.view viewWithTag:5];
    
    
    [odo resignFirstResponder];
    [total resignFirstResponder];
}


-(void)textfieldsetting: (UITextField *)textfield
{
    //NIKHIL ENH_42 //removed borders

    //[textfield setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    NSMutableAttributedString *placeholderAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:textfield.attributedPlaceholder];
    [placeholderAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [placeholderAttributedString length])];
    textfield.attributedPlaceholder = placeholderAttributedString;
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
    
    //NSString *date_hint = @"Set Date";
    str=NSLocalizedString(@"date_hint", @"Set Date");
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
    
    if([self.pickerval isEqualToString:NSLocalizedString(@"date", @"Date")])
    {
        [self.pic removeFromSuperview];
        [self.picker removeFromSuperview];
        [self.setbutton removeFromSuperview];
        NSDateFormatter *f=[[NSDateFormatter alloc] init];
        [f setDateFormat:@"dd-MMM-yyyy"];
        NSString *date=[f stringFromDate:_pic.date];
        UITextField *textfield = (UITextField *)[self.view viewWithTag:1];
        textfield.text = date;
    }
    
    else if([self.pickerval isEqualToString:@"Select"])
    {
        [self.pic removeFromSuperview];
        [self.picker removeFromSuperview];
        [self.setbutton removeFromSuperview];
        NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
        
        if([def boolForKey:@"editPageOpen"]){
            
            [def setObject:[def objectForKey:@"fillupid"] forKey:@"oldFillupid"];
            
        }
        
        NSDictionary *dictionary = [[NSDictionary alloc]init];
        dictionary = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
        //NSLog(@"id value for vehid %@",[dictionary objectForKey:@"Id"]);
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

    }

}


//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(alertView.tag!=1)
//    {
//        [self donelabel];
//    }
//
//}




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
       // controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
   // UIImage *newimage = [[UIImage alloc]init];
    
    NSString *imageURLString = [[NSString alloc]init];

    UIImage *compressedImage = [[UIImage alloc] init];//[self scaleImage:image toSize:CGSizeMake(320.0,480.0)];
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        imageURLString = @"PNG";
        
    }else{
        
        imageURLString   = [NSString stringWithFormat:@"%@", [info valueForKey: UIImagePickerControllerReferenceURL]];
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
        
    }else {
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0);
//        long imagesize = [imageData length]/1024;
//
//        if(imagesize <600){
//            newimage = [image imageWithImage:image scaledToSize:CGSizeMake(image.size.width/2, image.size.height/2)];
//            imageData = UIImageJPEGRepresentation(newimage, 0);
//        }
//        else if(imagesize>600 && imagesize <1000){
//            newimage = [image imageWithImage:image scaledToSize:CGSizeMake(image.size.width/3, image.size.height/3)];
//            imageData = UIImageJPEGRepresentation(newimage, 0);
//        }
//        else if (imagesize>1000 && imagesize <3000){
//            newimage = [image imageWithImage:image scaledToSize:CGSizeMake(image.size.width/4, image.size.height/4)];
//            imageData = UIImageJPEGRepresentation(newimage, 0);
//        }
//
//        else if (imagesize>3000){
//            newimage = [image imageWithImage:image scaledToSize:CGSizeMake(image.size.width/6, image.size.height/6)];
//            imageData = UIImageJPEGRepresentation(newimage, 0);
//        }
//
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
    [self.serviceCollectionView reloadData];
}

-(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}


-(void)openselectpicker
{
    if(self.vehiclearray.count>0)
    {
        [self picker:@"Select Vehicle"];
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
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_setbutton addTarget:self action:@selector(donelabel) forControlEvents:UIControlEventTouchUpInside];
    [topview addSubview:_setbutton];
    
}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag==-8)
    {
        return  self.vehiclearray.count;
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

-(void)saveservices
{
    self.saveButton.userInteractionEnabled = false;
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"editdetails"]==nil)
    {
        [self saveToLocalDatabaseNew];
    }
    else
    {
        [self editServices];
    }
    
   // [self updateservice];
    
}

-(void)saveToLocalDatabaseNew
{
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    UITextField *date = (UITextField *)[self.view viewWithTag:1];
    UITextField *service = (UITextField *) [self.view viewWithTag:3];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
   
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    //TChanged the object type bcuz it is causing langaue issues
    if([Def objectForKey:@"filluptype"]==nil)
    {
        [Def setObject:@"odometer" forKey:@"filluptype"];
    }
    //NSLog(@"service %@",service.text);
    
    //Swapnil BUG_77
    if(odometer.text.length!=0 && date.text.length!=0 && ![service.text isEqualToString:@""] && [odometer.text floatValue] != 0)
    {
        
        //Check if odometer is valid, Calc PrevOdo and Order of Record
        if ([self checkOdo:[odometer.text floatValue] ForDate:[formatter dateFromString:date.text]])
        {
            
            if ([recOrder isEqualToString:@"MAX"])
            {
                [self insertrecord:([odometer.text floatValue]-prevOdo)];
//                [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
//                [self getOdoServices];
                [self dismissViewControllerAnimated:YES completion:nil];
//                Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
//                NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
//
//                if(networkStatus == NotReachable){
//                    [self dismissViewControllerAnimated:YES completion:nil];
//                }
            }
            else if ([recOrder isEqualToString:@"MIN"])
            {
                [self insertrecord:0];
//                [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
//                [self getOdoServices];
                [self dismissViewControllerAnimated:YES completion:nil];
//                Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
//                NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
//
//                if(networkStatus == NotReachable){
//                    [self dismissViewControllerAnimated:YES completion:nil];
//                }
            }
            else if ([recOrder isEqualToString:@"BETWEEN"])
            {
                [self insertrecord:([odometer.text floatValue]-prevOdo)];
//                 [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
//                [self getOdoServices];
                [self dismissViewControllerAnimated:YES completion:nil];
//                Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
//                NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
//
//                if(networkStatus == NotReachable){
//                    [self dismissViewControllerAnimated:YES completion:nil];
//                }
            }
            
            //Swapnil Fabric events
            NSString *appInstallDate = [Def objectForKey:@"installDate"];
            NSInteger serviceCountEvent = [Def integerForKey:@"serviceCountEvent"] + 1;
            [Def setInteger:serviceCountEvent forKey:@"serviceCountEvent"];
            NSString *serviceCnt = [NSString stringWithFormat:@"%ld", (long)serviceCountEvent];
            
            NSString *completeServiceEvent = [NSString stringWithFormat:@"%@; %@", appInstallDate, serviceCnt];
            [Answers logCustomEventWithName:@"Service Event"
                           customAttributes:@{@"Services": completeServiceEvent}];
            
            BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];
            
            if(!proUser){
                NSInteger gadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"adCount"];
                gadCount = gadCount + 1;
                [[NSUserDefaults standardUserDefaults] setInteger:gadCount forKey:@"adCount"];
            }
            
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
            
        }//Swapnil BUG_76
        else {
            [self showAlert:NSLocalizedString(@"incorrect_odo", @"Incorrect Odometer value for Date") message:@""];
        }
        
    }
    
     else
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Enter Odometer and Services"
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


//-(void)sendUpdatedRecordToFriend:(NSDictionary *)friendDict{
//
//    //NSLog(@"friendDict:- %@",friendDict);
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
//    [parametersDict setObject:@"Odometer" forKey:@"OT"];
//
//    //Additional keys with 0 or ""
//    [parametersDict setObject:@"0" forKey:@"qty"];
//    [parametersDict setObject:@"0" forKey:@"pfill"];
//    [parametersDict setObject:@"0" forKey:@"octane"];
//    [parametersDict setObject:@"" forKey:@"fuelBrand"];
//    [parametersDict setObject:@"0" forKey:@"mfill"];
//
//    //NSLog(@"Friend dict to be sent, has arrived here,  woohoo::- %@",parametersDict);
//    if(networkStatus == NotReachable){
//
//        NSMutableArray *saveArray = [[NSMutableArray alloc] init];
//        saveArray = [def objectForKey:@"pendingFriendRecord"];
//        [saveArray addObject:parametersDict];
//        [def setObject:saveArray forKey:@"pendingFriendRecord"];
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
//                //NSLog(@"success:- %@",[responseDict valueForKey:@"success"]);
//
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

//new_7  2018may
-(void)editServices
{
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    //BUG_177 for carChange jhol
    NSString *oldComapreString = [NSString stringWithFormat:@"%@",[Def objectForKey:@"oldFillupid"]];
    
    NSMutableDictionary *forFriendDict = [[NSMutableDictionary alloc]init];
    NSString* oldOdo =[self.details objectForKey:@"odo"];
    [forFriendDict setObject:oldOdo forKey:@"oldOdo"];
    NSString* oldSerType =[self.details objectForKey:@"service"];
    [forFriendDict setObject:oldSerType forKey:@"oldServiceType"];
    
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ and type = 1 and odo = %@ and serviceType = %@",oldComapreString, oldOdo, oldSerType];
    [requset setPredicate:predicate];
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    T_Fuelcons *updRecord = [datavalue firstObject];
    
    //TO get vehid
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %i",[comparestring intValue]];
    [vehRequest setPredicate:vehPredicate];
    NSArray *vehData = [contex executeFetchRequest:vehRequest error:&err];
    
    Veh_Table *vehicleData = [vehData firstObject];
    
    NSString *vehid = vehicleData.vehid;
    
    if([Def objectForKey:@"UserEmail"]){
        [forFriendDict setObject:[Def objectForKey:@"UserEmail"] forKey:@"email"];
        [forFriendDict setObject:[Def objectForKey:@"UserName"] forKey:@"name"];
    }
    [forFriendDict setObject:@"update" forKey:@"action"];
    if(updRecord.iD != nil){
        [forFriendDict setObject:updRecord.iD forKey:@"id"];
    }
    
    
    NSDateFormatter *f=[[NSDateFormatter alloc] init];
    [f setDateFormat:@"dd-MMM-yyyy"];
    
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    UITextField *date = (UITextField *)[self.view viewWithTag:1];
    UITextField *price = (UITextField *)[self.view viewWithTag:5];
    UITextField *filling = (UITextField *)[self.view viewWithTag:4];
    UITextView *notes = (UITextView *)[self.view viewWithTag:12];
    
    //if Odo or Date has been changed, Check if Odo is valid
    
    if ([self checkOdo:[odometer.text floatValue] ForDate: [f dateFromString: date.text]])
    {
        //Save values in the database
        
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd/MM/yyyy"];
        NSDate *formatteddate =[formater dateFromString:date.text];
        
        updRecord.odo = @([odometer.text floatValue]);
        [forFriendDict setObject:@([odometer.text floatValue]) forKey:@"odo"];
        updRecord.vehid = comparestring;
        [forFriendDict setObject:comparestring forKey:@"vehid"];
        updRecord.stringDate= formatteddate;
        [forFriendDict setObject:formatteddate forKey:@"date"];
        updRecord.type = @(1);
        [forFriendDict setObject:@(1) forKey:@"type"];
        updRecord.serviceType = [self.servicearray componentsJoinedByString:@","];
        [forFriendDict setObject:[self.servicearray componentsJoinedByString:@","] forKey:@"serviceType"];
        updRecord.cost = @([price.text floatValue]);
        [forFriendDict setObject:@([price.text floatValue]) forKey:@"cost"];
        updRecord.fillStation = filling.text;
        [forFriendDict setObject:filling.text forKey:@"fillStation"];
        
        updRecord.notes = notes.text;
        [forFriendDict setObject:notes.text forKey:@"notes"];
        
        //updRecord.dist =@([odometer.text floatValue]-prevOdo);
        //BUG_166
        NSString *emptyString = @"";
        if(self.receiptImageArray==nil && ![updRecord.receipt isEqualToString:emptyString])
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
            updRecord.receipt = nil;
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
            }
            
        }
        
        if([contex hasChanges]){
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
                
                [self writeToSyncTableWithRowID:updRecord.iD tableName:@"LOG_TABLE" andType:@"edit" andOS:@"self"];
                //Commented sync with friend "testing"
//                BOOL friendPresent = [self checkforConfirmedFriends];
//
//                if(friendPresent){
//
//                    [self performSelectorInBackground:@selector(sendUpdatedRecordToFriend:) withObject:forFriendDict];
//                }

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

        
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
        [self insertservice: 1];
        [self getOdoServices];

        [self dismissViewControllerAnimated:YES completion:nil];
        [Def setBool:NO forKey:@"editPageOpen"];
        [Def setObject:[Def objectForKey:@"fillupid"] forKey:@"oldFillupid"];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"incorrect_odo", @"Incorrect Odometer value for Date")
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
//new_7  2018may
-(void)insertrecord: (float) distance
{
    // NSLog(@"distance value %.2f",distance);
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    
    
    UITextField *date = (UITextField *)[self.view viewWithTag:1];
    UITextField *price = (UITextField *)[self.view viewWithTag:5];
    UITextField *filling = (UITextField *)[self.view viewWithTag:4];
    UITextView *notes = (UITextView *)[self.view viewWithTag:12];

    // UIButton *button  = (UIButton *)[self.view viewWithTag:1000];
    
    
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
    //[feedBackDataDict setObject:dataval.iD forKey:@"rowID"];
    [Def setObject:dataval.iD forKey:@"maxFuelID"];
    [forFriendDict setObject:dataval.iD forKey:@"id"];
    //NSLog(@"dataval.iD::::%@",dataval.iD);
    dataval.odo =@([odometer.text floatValue]);
    [forFriendDict setObject:dataval.odo forKey:@"odo"];
    dataval.vehid = comparestring;
    [forFriendDict setObject:vehid forKey:@"vehid"];
    dataval.stringDate= formatteddate;
    [forFriendDict setObject:dataval.stringDate forKey:@"date"];
    //[feedBackDataDict setObject:dataval.stringDate forKey:@"date"];
    dataval.type = @(1);
    [forFriendDict setObject:dataval.type forKey:@"type"];
    dataval.serviceType = [self.servicearray componentsJoinedByString:@","];
    [forFriendDict setObject:dataval.serviceType forKey:@"serviceType"];
    //[feedBackDataDict setObject:dataval.serviceType forKey:@"services"];
    dataval.cost = @([price.text floatValue]);
    [forFriendDict setObject:dataval.cost forKey:@"cost"];
   // [feedBackDataDict setObject:dataval.cost forKey:@"cost"];
    dataval.fillStation = filling.text;
    if(dataval.fillStation != nil){
        [forFriendDict setObject:dataval.fillStation forKey:@"fillStation"];
    }else{
        [forFriendDict setObject:@"" forKey:@"fillStation"];
    }
    
    //dataval.dist =@(distance);
    dataval.notes = notes.text;
    if(dataval.notes != nil){
        [forFriendDict setObject:dataval.notes forKey:@"notes"];
    }else{
        [forFriendDict setObject:@"" forKey:@"notes"];
    }
    
    if(self.receiptImageArray==nil)
    {
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
    }
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager locationServicesEnabled])){
        
        //Getting fuelstation from location
        //NSLog(@"saveCurrLatitude:- %@",saveCurLat);
        //NSLog(@"saveCurrLongitude:- %@",saveCurLong);
        //Request current location
        [[LocationServices sharedInstance].locationManager requestLocation];
        
        //Get latest locn in currentLocation
        CLLocation *currentLocation = [LocationServices sharedInstance].latestLoc;
        NSLog(@"currentLocation : %@", currentLocation);

        if(saveCurLat != nil || saveCurLat != 0){

            dataval.latitude = saveCurLat;
            dataval.longitude = saveCurLong;
        }else{

            dataval.latitude = [NSNumber numberWithDouble:currentLocation.coordinate.latitude];
            dataval.longitude = [NSNumber numberWithDouble:currentLocation.coordinate.longitude];
        }

        if(dataval.latitude){
            
            [forFriendDict setObject:dataval.latitude forKey:@"depLat"];
        }

        if(dataval.longitude){
            [forFriendDict setObject:dataval.longitude forKey:@"depLong"];
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
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editdetails"];
        [self insertservice: 1];
        [self getOdoServices];

        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

        if(networkStatus == NotReachable){

           // [CheckReachability.sharedManager startNetworkMonitoring];
        }else{
           // [self addFeedBackView];
        }

        //Swapnil NEW_6
        NSString *userEmail = [Def objectForKey:@"UserEmail"];
        
        //If user is signed In, then only do the sync process..
        if(userEmail != nil && userEmail.length > 0){
        
            [self writeToSyncTableWithRowID:dataval.iD tableName:@"LOG_TABLE" andType:@"add" andOS:@"self"];
//            //Commented sync with friend "testing"
//            BOOL friendPresent = [self checkforConfirmedFriends];
//
//            if(friendPresent){
//
//                 [self performSelectorInBackground:@selector(sendUpdatedRecordToFriend:) withObject:forFriendDict];
//            }
        }
    }


    //[self fetchservice];

}

//statusForUpdateService = 1, when it comes from normal service add
//statusForUpdateService = 0, when it comes from sync
-(void)insertservice: (int)statusForUpdateService
{
    // NSLog(@"distance value %.2f",distance);
    
    NSManagedObjectContext *contex;
    if(statusForUpdateService == 1){
    
        contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    } else {
        contex = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    }
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
    
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];

    NSManagedObjectContext *contex1 = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSError *err1;
    NSPredicate *p1=[NSPredicate predicateWithFormat:@"vehid == %@ AND (type==1 OR type==2)",comparestring];
    [requset1 setPredicate:p1];
   
    NSArray *data1=[contex1 executeFetchRequest:requset1 error:&err1];
    
    NSMutableArray *recordadded =[[NSMutableArray alloc]init];
    
    for(Services_Table *service in data1)
    {
        [recordadded addObject:service.serviceName];
    }
    for(T_Fuelcons *fuel in datavalue)
    {
        
        //  NSLog(@"fuel record.... %@",fuel.serviceType);
        if(![fuel.serviceType isEqualToString:@"Fuel Record"])
        {
            NSArray *addedservice = [[NSArray alloc]init];
            
            addedservice =[fuel.serviceType componentsSeparatedByString:@","];
            // NSLog(@"addedservice %@",addedservice);
            for(int i =0 ;i<addedservice.count;i++)
            {
                
                if(data1.count>0)
                {
                    
                    for(int j =0 ;j <data1.count;j++)
                    {
                        
                        Services_Table *fuelrecord = [data1 objectAtIndex:j];
                        //  NSLog(@"Service record %@",fuelrecord.serviceName);
                        //NSLog(@"added fuel record %@",[addedservice objectAtIndex:i]);
                        if(![fuelrecord.serviceName isEqualToString:[addedservice objectAtIndex:i]] && ![recordadded containsObject:[addedservice objectAtIndex:i]])
                        {
                            // NSLog(@"Service record.... %@",fuelrecord.serviceName);
                            // NSLog(@"added service.... %@",[addedservice objectAtIndex:i]);
                            [recordadded addObject:[addedservice objectAtIndex:i]];
                            // NSLog(@"recorded array not equal %@",recordadded);
                            Services_Table *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:contex];
                            
                            dataval.vehid = comparestring;
                            dataval.serviceName = [addedservice objectAtIndex:i];
                            NSLog(@"ServiceViewController line number 2300:- %@",fuel.stringDate);
                            dataval.lastDate = fuel.stringDate;
                            
                            
                                if ([contex1 hasChanges])
                                {
                                    BOOL saved = [contex1 save:&err1];
                                    if (!saved) {
                                        // do some real error handling
                                        //CLSLog(@“Could not save Data due to %@“, error);
                                    }
                                    [[CoreDataController sharedInstance] saveMasterContext];
                                    
                                }
                            
                        }
                        
                        
                        else if ([fuelrecord.serviceName isEqualToString:[addedservice objectAtIndex:i]])
                            
                        {
                            // NSLog(@"same data");
                            
                            [recordadded addObject:[addedservice objectAtIndex:i]];
                            // NSLog(@"recorded array equal %@",recordadded);
                            //fuelrecord.lastDate = fuel.stringDate;
                            
                            if ([contex1 hasChanges])
                            {
                                BOOL saved = [contex1 save:&err1];
                                if (!saved) {
                                    // do some real error handling
                                    //CLSLog(@“Could not save Data due to %@“, error);
                                }
                                [[CoreDataController sharedInstance] saveMasterContext];
                                
                            }
                            
                            
                        }
                        
                    }
                }
                else
                {
                    Services_Table *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:contex];
                    
                    [recordadded addObject:[addedservice objectAtIndex:i]];
                    // NSLog(@"recorded array insert %@",recordadded);
                    dataval.vehid = comparestring;
                    dataval.serviceName = [addedservice objectAtIndex:i];
                    dataval.lastDate = fuel.stringDate;
                    
                    if ([contex1 hasChanges])
                    {
                        BOOL saved = [contex1 save:&err1];
                        if (!saved) {
                            // do some real error handling
                            //CLSLog(@“Could not save Data due to %@“, error);
                        }
                        [[CoreDataController sharedInstance] saveMasterContext];
                        
                    }
                    
                }
                
            }
        }
    }
    
    if(statusForUpdateService == 1){
    
        [self updateservice];
    }
    
}
/*
#pragma mark - UITableView Delegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if(placesNameArray.count>6){

        return 6;
    }else{

        return placesNameArray.count;
    }

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"CenterCell";
    PlacesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PlacesTableViewCell" owner:self options:nil] objectAtIndex:0];
    }

    if(placesNameArray.count>0){

        cell.name.attributedText = placesNameArray[indexPath.row];
        cell.address.attributedText = placesAddressArray[indexPath.row];

    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UITextField *serCenterField = [self.view viewWithTag:4];
    NSAttributedString* someString = placesNameArray[indexPath.row];
    serCenterField.text = someString.string;

    NSString *placeID = placesIDsArray[indexPath.row];

    [self getLatLongFromPlaceID:placeID];
    //NSLog(@"placesIDsArray:- %@",placesIDsArray);

    _placesTableView.hidden = true;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UILabel *googleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, footerView.frame.size.width-50, footerView.frame.size.height)];
    googleLabel.textAlignment = NSTextAlignmentRight;
    googleLabel.font = [UIFont italicSystemFontOfSize:12];
    googleLabel.textColor = UIColor.whiteColor;
    googleLabel.numberOfLines = 1;
    googleLabel.text = @"Powered by Google";
    [footerView addSubview:googleLabel];

    return footerView;
}

-(void)getLatLongFromPlaceID:(NSString *)placeID{

   // NSString *placeID = @"ChIJV4k8_9UodTERU5KXbkYpSYs";

    [placesClient lookUpPlaceID:placeID callback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            //NSLog(@"Place Details error %@", [error localizedDescription]);
            return;
        }

        if (place != nil) {
           // NSLog(@"Place name %@", place.name);
            //NSLog(@"Place address %@", place.formattedAddress);
           // NSLog(@"Place placeID %@", place.placeID);
           // NSLog(@"Place coordinate.latitude %f", place.coordinate.latitude);
           // NSLog(@"Place coordinate.longitude %f", place.coordinate.longitude);
           // NSLog(@"Place phoneNumber %@", place.phoneNumber);
           // NSLog(@"Place website %@", place.website);

            saveCurLat = [NSNumber numberWithDouble: place.coordinate.latitude];
            saveCurLong = [NSNumber numberWithDouble: place.coordinate.longitude];
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];


            if([def objectForKey:@"UserEmail"] != nil){
                [feedBackDataDict setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
            } else {
                [feedBackDataDict setObject:@"dummy@simplyauto.app" forKey:@"email"];
            }

            if(place.name){

                [feedBackDataDict setObject:place.name forKey:@"name"];
            }

            if(place.formattedAddress){

                [feedBackDataDict setObject:place.formattedAddress forKey:@"address"];
            }

            if(place.coordinate.latitude){

                if(place.coordinate.longitude){

                    [feedBackDataDict setObject:saveCurLat forKey:@"lat"];
                    [feedBackDataDict setObject:saveCurLong forKey:@"long"];
                }
            }

            if(place.phoneNumber){

                [feedBackDataDict setObject:place.phoneNumber forKey:@"phone_num"];
            }

            if(place.website){

                [feedBackDataDict setObject:place.website.absoluteString forKey:@"website"];
            }

        } else {
           // NSLog(@"No place details for %@", placeID);
        }
    }];
}
*/
#pragma mark - UITextField Delegate methods
//NIKHIL BUG_125 //added below method
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    double latitude = [[NSString stringWithFormat:@"%.2f", coordinate.latitude] doubleValue];
    double longitude = [[NSString stringWithFormat:@"%.2f", coordinate.longitude] doubleValue];
    double offSet = 0.01;

    double latMax = latitude + offSet;
    double latMin = latitude - offSet;
    double longMax = longitude + offSet;
    double longMin = longitude - offSet;

    CLLocationCoordinate2D initialLocation = CLLocationCoordinate2DMake(latMax, longMax);
    CLLocationCoordinate2D endLocation = CLLocationCoordinate2DMake(latMin, longMin);

    //GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:initialLocation coordinate:endLocation];
    bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:initialLocation coordinate:endLocation];

    currentField = textField;
    buttonOrigin = currentField.frame.origin;
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if(textField.tag==5 || textField.tag==4)
    {
        AppDelegate *App = [AppDelegate sharedAppDelegate];
        if(App.result.width > 480)
        {
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-160, self.view.frame.size.width, self.view.frame.size.height)];
        }
        else
        {
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-140, self.view.frame.size.width, self.view.frame.size.height)];
        }
        
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
    
    if(textField.tag==4)
    {

       // [self.view addSubview:_placesTableView];
        autocompleteQuery = [[NSString alloc] init];
        if(textField.text.length>0){

            autocompleteQuery = textField.text;
        }

        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        [self paddingTextFields:textField];
        UILabel *label = (UILabel *)[textField viewWithTag:80];
        [self labelanimatetoshow:label];
        textField.placeholder=@"";
        
    }
    
    if(textField.tag==5)
    {
        [self paddingTextFields:textField];
        UILabel *label = (UILabel *)[textField viewWithTag:100];
        [self labelanimatetoshow:label];
        textField.placeholder=@"";
        
    }
    
    
}

- (void) paddingTextFields: (UITextField *)textField{
    
    UIView *padding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4.8, 20)];
    textField.leftView = padding;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {

    autocompletearray =[[NSMutableArray alloc]init];
    [autocompletearray removeAllObjects];
    for(NSString *curString in self.centerArray) {
        NSRange substringRange = [[NSString stringWithFormat:@"%@",curString]rangeOfString:substring];
        if (substringRange.location == 0) {
            autocompletable.hidden=NO;
            [autocompletearray addObject:curString];
        }
    }
    [autocompletable reloadData];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //NSLog(@"placesNameArray:- %@",placesNameArray);
   // NSLog(@"placesAddressArray:- %@",placesAddressArray);
   // NSLog(@"placesIDsArray:- %@",placesIDsArray);
    [autocompletable removeFromSuperview];

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
        if(textField.text.length==0)
        {
            UILabel *label = (UILabel *)[textField viewWithTag:40];
            [self labelanimatetohide:label];
            
            textField.placeholder=NSLocalizedString(@"odometer", @"Odometer");
        }
        else {
            if([textField.text containsString:@","]){
                NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
                textField.text = Stringval;
            }
            
        }
        
    }
    
    if(textField.tag==4)
    {

        [self paddingTextFields:textField];
//        NSString *tv_service_center = @"Service Center";
//        NSString *comma_err = @"cannot accept commas";
        if(textField.text.length==0)
        {
            UILabel *label = (UILabel *)[textField viewWithTag:80];
            [self labelanimatetohide:label];
            textField.placeholder=NSLocalizedString(@"tv_service_center", @"Service center");
        }
        
        if([textField.text containsString:@","]){
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:
                                               [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"tv_service_center", @"Service Center"),
                                                NSLocalizedString(@"comma_err", @"cannot accept commas")]
                                                message:nil
                                                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@" "];
            textField.text = Stringval;
        }
        autocompleteQuery = @"";
       // _placesTableView.hidden = true;
    }
    
    if(textField.tag==5)
    {
        [self paddingTextFields:textField];
        if(textField.text.length==0)
        {
            UILabel *label = (UILabel *)[textField viewWithTag:100];
            [self labelanimatetohide:label];
            
            //NSString *tc_tv = @"Total Cost";
            textField.placeholder=NSLocalizedString(@"tc_tv", @"Total cost");
        }
        
        else{
            
            if([textField.text containsString:@","]){
                NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
                textField.text = Stringval;
            }
            textField.text = [NSString stringWithFormat:@"%.2f",[textField.text floatValue]];
        }
    }
   
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if(textField.tag==2) {
        
        if([textField.text containsString:@","]){
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
            textField.text = Stringval;
        }
    }
    
    if(textField.tag==5) {
        
        if([textField.text containsString:@","]){
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
            textField.text = Stringval;
        }
    }

    
    if(textField.tag == 4) {

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
        //Commented for a while to test autocomplete but should remove commas while saving so this is needed
        if([textField.text containsString:@","]){

//            NSString *tv_service_center = @"Service Center";
//            NSString *comma_err = @"cannot accept commas";
//            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"tv_service_center", @"Service Center") ,
//                                                                                           NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//
//            }];
//            [alertControl addAction:ok];
//            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }

//        if(string.length==0){
//
//            if(autocompleteQuery.length>0){
//
//                autocompleteQuery = [autocompleteQuery substringToIndex:[autocompleteQuery length]-1];
//               // NSLog(@"autocompleteQuery:- %@",autocompleteQuery);
//            }
//        }else{
//
//            autocompleteQuery = [autocompleteQuery stringByAppendingString:string];
//           // NSLog(@"autocompleteQuery:- %@",autocompleteQuery);
//        }

//
//        [placesClient findAutocompletePredictionsFromQuery:autocompleteQuery bounds:bounds boundsMode:kGMSAutocompleteBoundsModeBias filter:_filter sessionToken:token callback:^(NSArray<GMSAutocompletePrediction *> * _Nullable results, NSError * _Nullable error) {
//
//            if (error != nil) {
//                NSLog(@"An error occurred %@", [error localizedDescription]);
//                return;
//            }
//            if (results != nil) {
//                //NSLog(@"results:- %@",results);
//                [placesNameArray removeAllObjects];
//                [placesAddressArray removeAllObjects];
//                [placesIDsArray removeAllObjects];
//
//                if(results.count>0){
//
//                    for (GMSAutocompletePrediction *result in results) {
//
//                        //NSLog(@"Result primaryText:-%@ secondaryText:-%@ and PlaceID %@", result.attributedPrimaryText,result.attributedSecondaryText, result.placeID);
//
//                        UIFont *regularFont = [UIFont systemFontOfSize:12];
//                        UIFont *boldFont = [UIFont boldSystemFontOfSize:12];
//
//                        NSMutableAttributedString *bolded = [result.attributedPrimaryText mutableCopy];
//                        [bolded enumerateAttribute:kGMSAutocompleteMatchAttribute
//                                           inRange:NSMakeRange(0, bolded.length)
//                                           options:0
//                                        usingBlock:^(id value, NSRange range, BOOL *stop) {
//                                            UIFont *font = (value == nil) ? regularFont : boldFont;
//                                            [bolded addAttribute:NSFontAttributeName value:font range:range];
//                                        }];
//
//                        NSAttributedString *resultString;
//                        resultString = bolded;
//                        //NSLog(@"resultString:- %@",resultString);
//
//                        [placesNameArray addObject:resultString];
//                        if(result.attributedSecondaryText != nil){
//
//                            [placesAddressArray addObject:result.attributedSecondaryText];
//                        }
//
//                        if(result.placeID != nil){
//
//                            [placesIDsArray addObject:result.placeID];
//                        }
//                        //NSLog(@"placesNameArray:- %@",placesNameArray);
//                        //NSLog(@"placesAddressArray:- %@",placesAddressArray);
//                        //NSLog(@"placesIDsArray:- %@",placesIDsArray);
//                        CGFloat height = _placesTableView.rowHeight;
//                        height *= placesNameArray.count;
//
//                        CGRect tableFrame = _placesTableView.frame;
//                        tableFrame.size.height = height;
//                        _placesTableView.frame = tableFrame;
//                        // [self.view bringSubviewToFront:_placesTableView];
//                        _placesTableView.hidden = false;
//                        [_placesTableView reloadData];
//                    }
//                }else{
//
//                    _placesTableView.hidden = true;
//                }
//
//            }
//        }];
    }
    return YES;
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
        UITextField *fuel = (UITextField *) [self.view viewWithTag:4];

        fuel.text = [NSString stringWithFormat:@"%@",[autocompletearray objectAtIndex:indexPath.row]];
        [autocompletable removeFromSuperview];
    }

}


//NIKHIL BUG_130 added notes textView delegate methods
#pragma mark - UITextView Delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
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
    [self.view setFrame:CGRectMake(self.view.frame.origin.x,0, self.view.frame.size.width, self.view.frame.size.height)];
    
    if(textView.text.length==0)
    {
        UILabel *label = (UILabel *)[textView viewWithTag:220];
        [self labelanimatetohide:label];
        
        //NSString *notes_tv = @"Notes";
        //textView.placeholder=NSLocalizedString(@"notes_tv", @"Notes");
    }
    
    if([textView.text containsString:@","] && textView.tag != 100){
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"comma_enter_err", @"Notes cannot accept commas and new lines") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [alertControl addAction:ok];
        [self presentViewController:alertControl animated:YES completion:nil];
        NSString *Stringval = [textView.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        textView.text = Stringval;
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

    if(currentField.tag == 4){

        visibleRect.size.height -= (keyboardSize.height + 140);
    }else{

        visibleRect.size.height -= (keyboardSize.height + 50);
    }

    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
        
        
        [scrollview setContentOffset:scrollPoint animated:YES];

    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    //[self.scrollView setContentOffset:CGPointZero animated:YES];
    [scrollview setContentOffset: CGPointMake(oldX, oldY+ 1) animated:YES];
    
}

-(void)labelanimatetoshow: (UIView *)view

{

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

-(void)getOdoServices {
    
   // [self fetchservice];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    UITextField *serviceDate = (UITextField *)[self.view viewWithTag:1];
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
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setValue:fuelrecord.serviceName forKey:@"name"];

        if([odometer.text floatValue]>=([fuelrecord.dueMiles floatValue]+ [fuelrecord.lastOdo floatValue]) && [fuelrecord.dueMiles floatValue]!=0) {

            [dictionary setValue:fuelrecord.vehid forKey:@"vehid"];
            [dictionary setValue:[formater stringFromDate:fuelrecord.lastDate] forKey:@"lastdate"];
            [dictionary setValue:fuelrecord.recurring  forKey:@"recurring"];
            [dictionary setValue:fuelrecord.type forKey:@"type"];
            [dictionary setValue:fuelrecord.dueDays forKey:@"duedays"];
            [dictionary setValue:fuelrecord.dueMiles forKey:@"duemiles"];
            [serviceArray addObject:dictionary];
            
            NSString* jrnKey = [[[dictionary objectForKey:@"name"] stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

            [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];

            //TODO check if correct
//            if(fuelrecord.recurring){
//
//
//            }
            [[JRNLocalNotificationCenter defaultCenter] postNotificationOn:[NSDate dateWithTimeIntervalSinceNow:1] forKey:jrnKey alertBody:[NSString stringWithFormat:@"%@ %@ %@",[dictionary objectForKey:@"name"], NSLocalizedString(@"noti_msg_veh", @"Overdue for"),[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]] alertAction:@"Open" soundName:nil launchImage:nil userInfo:@{@"time":[NSString stringWithFormat:@"%@ Overdue for %@",[dictionary objectForKey:@"name"],[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]]} badgeCount:1 repeatInterval:NO category:nil];

            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"showPage"];

        }
//          //TODO check if correct
//        if(fuelrecord.recurring){
//
//
//
//        }
        int dueDays = [fuelrecord.dueDays intValue];

        if(dueDays > 0){

            NSString* jrnKey = [[[dictionary objectForKey:@"name"] stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

            [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];

            NSDateComponents *dateComponents = [NSDateComponents new];
            dateComponents.day = [fuelrecord.dueDays integerValue];
            NSDate *dueDate = [[NSCalendar currentCalendar]dateByAddingComponents:dateComponents
                                                                           toDate: fuelrecord.lastDate
                                                                          options:0];

            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
            NSDateComponents *timeComponents = [calendar components:( NSCalendarUnitYear |  NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond )
                                                           fromDate:dueDate];
            [timeComponents setHour:7];
            [timeComponents setMinute:00];
            [timeComponents setSecond:0];
            //TODO: resolve this crash if many users are affected
            NSDate *dtFinal = [calendar dateFromComponents:timeComponents];

            if (dtFinal != nil && ![dtFinal isKindOfClass:[NSNull class]]){

                NSString* alertBody = [NSString stringWithFormat:@"%@ %@ %@",fuelrecord.serviceName, NSLocalizedString(@"noti_msg_veh", @"Overdue for"), [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

                [[JRNLocalNotificationCenter defaultCenter] postNotificationOn:dtFinal                                                            forKey:jrnKey alertBody:[NSString stringWithFormat:@"Pull or swipe to interact. %@", alertBody]
                                                                   alertAction:@"Open"
                                                                     soundName:nil
                                                                   launchImage:nil
                                                                      userInfo:@{@"DueDate": dtFinal}
                                                                    badgeCount:0
                                                                repeatInterval:NSCalendarUnitDay
                                                                      category:@"DayReminder"];

                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"showPage"];
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

-(void)updateservice
{
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    UITextField *Service = (UITextField *)[self.view viewWithTag:3];
    UITextField *odometer = (UITextField *)[self.view viewWithTag:2];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *odoNum = [f numberFromString:odometer.text];
    
    UITextField *date = (UITextField *)[self.view viewWithTag:1];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    
    NSArray* selServices = [Service.text componentsSeparatedByString:@","];

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid == %@ AND type==1",comparestring];
    [requset setPredicate:predicate];
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    for ( Services_Table *service in datavalue)
    {
        
        for (NSString* selServiceName in selServices ) {
            if([service.serviceName isEqualToString:selServiceName])
            {
                if([service.recurring  isEqual: @(0)]){

                    service.lastOdo = @(0);
                    service.dueMiles = @(0);
                    service.lastDate = [[NSDate alloc] init];
                    service.dueDays = @(0);
                }else{

                    service.lastOdo = odoNum;
                    service.lastDate =  [formater dateFromString:date.text];
                    NSLog(@"ServiceViewController line number 3223:- %@",[formater dateFromString:date.text]);
                }
                
                if ([contex hasChanges])
                {
                    BOOL saved = [contex save:&err];
                    if (!saved) {
                        // do some real error handling
                        //CLSLog(@“Could not save Data due to %@“, error);
                    }
                    [[CoreDataController sharedInstance] saveMasterContext];
                    
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    [def setInteger :[def integerForKey:@"appopenstatus"]+1 forKey:@"appopenstatus"];
                    
                }
            }
        }

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
    
    if([context hasChanges]){
        
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
        //[self performSelectorInBackground:@selector(checkNetworkForCloudStorage) withObject:nil];
       // [self checkNetworkForCloudStorage];
        //Upload data from common methods
        commonMethods *common = [[commonMethods alloc] init];
        [common checkNetworkForCloudStorage:@"isLog"];
        [[CoreDataController sharedInstance] saveMasterContext];
    }
}


- (void)checkNetworkForCloudStorage{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable){
    
       [CheckReachability.sharedManager startNetworkMonitoring];
    } else {
        
      //  [self performSelectorInBackground:@selector(fetchDataFromSyncTable) withObject:nil];
    }
}

//Loop through the Sync table, fetch table name, type (add, edit, del) and rowID of record
- (void)fetchDataFromSyncTable{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sync_Table"];
    NSArray *dataArray = [context executeFetchRequest:request error:&err];
    
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
 
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] backgroundManagedObjectContext];
    
    NSError *err;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *iDPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [rowID intValue]];
    [request setPredicate:iDPredicate];
    
    NSArray *fetchedData = [context executeFetchRequest:request error:&err];
    
    T_Fuelcons *logData = [fetchedData firstObject];
    
    
    NSFetchRequest *vehRequest = [[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSPredicate *vehPredicate = [NSPredicate predicateWithFormat:@"iD == %d", [logData.vehid intValue]];
    [vehRequest setPredicate:vehPredicate];
    
    NSArray *vehData = [context executeFetchRequest:vehRequest error:&err];
    
    Veh_Table *vehicleData = [vehData firstObject];
    
    commonMethods *common = [[commonMethods alloc] init];
    NSDictionary *epochDictionary = [common getDayMonthYrFromStringDate:logData.stringDate];
    
    
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
    
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
    
    [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    
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
    
    //Start here for making single syncfree4june2018
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
        
            UIImage *receipt = [UIImage imageWithContentsOfFile:completeImgPath];
            NSData *imageData = UIImagePNGRepresentation(receipt);
        
            float imgSizeInMB = [imageData length] / 1024.0f / 1024.0f;
        
            //If images are > than 1.5 MB, compress them and then send to server
            if(imgSizeInMB > 1.5){
            
                UIImage *smallImg = [[commonMethods class] imageWithImage:receipt scaledToSize:CGSizeMake(300.0, 300.0)];
                NSData *compressedImg = UIImagePNGRepresentation(smallImg);
                imageString = [compressedImg base64EncodedStringWithOptions:0];
            
             } else {
            
               imageString = [imageData base64EncodedStringWithOptions:0];
             }
        
            NSString *receiptName = [separatedArray objectAtIndex:i];
            [receiptDict setObject:imageString forKey:[NSString stringWithFormat:@"%@",receiptName]];
      }
    
        NSString *colonString = [NSString stringWithFormat:@"%@:::",logData.receipt];
        [parametersDictionary setObject:colonString forKey:@"receipt"];
        [parametersDictionary setObject:receiptDict forKey:@"img_file"];
    } else {
        
        [parametersDictionary setObject:@"" forKey:@"img_file"];
        [parametersDictionary setObject:@"" forKey:@"receipt"];
    }

    [def setBool:YES forKey:@"updateTimeStamp"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
    //Pass paramters dictionary and URL of script to get response
    [common saveToCloud:postData urlString:kLogDataScript success:^(NSDictionary *responseDict) {
      //  NSLog(@"responseDict LOG : %@", responseDict);
        
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
            
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
        }
    } failure:^(NSError *error) {
      //  NSLog(@"%@", error.localizedDescription);
    }];
}

@end
