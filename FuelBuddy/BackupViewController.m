// Current
//  BackupViewController.m
//  FuelBuddy
//
//  Created by surabhi on 17/02/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "BackupViewController.h"
#import "AppDelegate.h"
#import "T_Fuelcons.h"
#import "Veh_Table.h"
#import "T_Trip.h"
#import "Services_Table.h"
#import "GoProViewController.h"
#import "commonMethods.h"
#import "ResyncVC.h"

@interface BackupViewController ()
{
    NSString* restoreErrorFile;
    NSString* restoreErrorDesc;
    GTLRDrive_File *vehFile;
    GTLRDrive_File *fuelFile;
    GTLRDrive_File *serviceFile;
    GTLRDrive_File *tripFile;
    GTLRDrive_File *fuelBuddyFolder;
    GTLRDrive_File *receiptFolder;
    int fuelid ;
    NSDateFormatter *f;
    BOOL success;
    BOOL hasCalledBackUpReceipt;
}

@end
//@"Fuel Buddy"
static NSString *const kKeychainItemName = @"API Project";
//static NSString *const kClientID = @"278805612208-l1npae39m88qfufvpl319lofe05i8bbj.apps.googleusercontent.com";

static NSString *const kClientID = @"336428349177-hud26k15ouvlv7hlsjh72v49pndlhoid.apps.googleusercontent.com";
//NSString *scopes = @"https://www.googleapis.com/auth/drive"; //

//Swapnil 15 Mar-17
//static GADMasterViewController *shared;
@implementation BackupViewController

@synthesize service = _service;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //GID SignIn
    
    [GIDSignIn sharedInstance].presentingViewController = self;
    [GIDSignIn sharedInstance].delegate = self;
    //
    NSArray* scopes = [NSArray arrayWithObjects:@"https://www.googleapis.com/auth/drive",
                       @"https://www.googleapis.com/auth/drive.file", nil];
                      // @"https://www.googleapis.com/auth/drive.appdata",
                      //@"https://www.googleapis.com/auth/drive.metadata",
                      // @"https://www.googleapis.com/auth/drive.readonly",
                      // @"https://www.googleapis.com/auth/drive.metadata.readonly",
                      // @"https://www.googleapis.com/auth/drive.photos.readonly", nil];
    [GIDSignIn sharedInstance].scopes = scopes;
    
    self.service = [[GTLRDriveService alloc] init];
    
    
    restoreErrorDesc = [[NSString alloc] init];
    restoreErrorFile = [[NSString alloc] init];
    // Do any additional setup after loading the view.
    
    self.dataarray =[[NSMutableArray alloc]initWithObjects:
                     NSLocalizedString(@"export", @"Manual Backup"),
                     NSLocalizedString(@"imp", @"Manual Restore"),nil];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title= NSLocalizedString(@"exim_btn", @"Google Drive Backup");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    
    
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    self.tableview.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.tableview.tableFooterView = [UIView new];
    self.tableview.separatorColor =[UIColor darkGrayColor];
    
    f = [[NSDateFormatter alloc] init];
    [f setDateStyle:NSDateFormatterLongStyle];
    
    [f setDateFormat:@"dd-MMM-yyyy hh:mm aa"];
    [f setAMSymbol:@"AM"];
    [f setPMSymbol:@"PM"];
    
    //[self exportTripCSV];

   // [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    
    UIButton *check = [(UIButton*)self.view viewWithTag:10];
    check.selected = NO;
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

-(void)viewWillDisappear:(BOOL)animated
{

    //[GIDSignIn sharedInstance].scopes = nil;
    [[GIDSignIn sharedInstance] signOut];


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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor =[UIColor whiteColor];
    cell.backgroundColor =[UIColor clearColor];
    cell.textLabel.text = [self.dataarray objectAtIndex:indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
        
    {
        
        
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if (networkStatus == NotReachable) {
            
            
            
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
            

        }
        else {
            self.flagstatus = @"Backup";
            
                        //[self presentViewController:alertController animated:YES completion:nil];
            //[self showcustomalert]; "backup_descval" = "Backup all your data to Google Drive";
            [self showcustomalert: NSLocalizedString(@"backup", @"Backup") :NSLocalizedString(@"backup_descval", @"Backup all your data to Google Drive"):NSLocalizedString(@"backup_receipts", @"Include receipt images in backup")];
        }
        
        //[self Drivesetting];
    }
    
    if(indexPath.row == 1)
    {
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if (networkStatus == NotReachable) {
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
        }
        else {
            self.flagstatus = @"Restore";
                //"restore_descval" = "Restore all your data to Google Drive"
            [self showcustomalert:NSLocalizedString(@"restore", @"Restore") :NSLocalizedString(@"restore_descval", @"Restore all your data to Google Drive") :NSLocalizedString(@"restore_receipts",@"Restore Receipts from Google Drive?")];
        }
        //[self Drivesetting];
        
    }
}

-(void)Drivesetting
{
   // [GIDSignIn sharedInstance].clientID = @"170537000552-d7rt38rd04l7clkm2a0jt7k27acv38ni.apps.googleusercontent.com";
    
    [GIDSignIn sharedInstance].clientID = kClientID;
    
   
    [[GIDSignIn sharedInstance] signIn];
 }


// Handle completion of the authorization process, and update the Drive API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [self showAlert:NSLocalizedString(@"google_ac_err", @"Authentication Error") message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        //[self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (error == nil) {
        [self isAuthorizedWithAuthentication];
    }
}

//Back up Auth
- (void)isAuthorizedWithAuthentication {
   // [[self driveService] setAuthorizer:auth];
    
    
    AppDelegate *app = [AppDelegate sharedAppDelegate];
    
    if(app.result.width == 320)
    {
        _loadingView = [[UIView alloc]initWithFrame:CGRectMake(120, 200, 80, 80)];
    }
    else
    {
        _loadingView = [[UIView alloc]initWithFrame:CGRectMake(150, 200, 80, 80)];
    }
    _loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    _loadingView.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(_loadingView.frame.size.width / 2.0, 35);
    
    [activityView startAnimating];
    activityView.tag = 100;
    [_loadingView addSubview:activityView];
    
    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, 80, 30)];
    lblLoading.text = @"Backup...";
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:13];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    
    
    [self.view addSubview:_loadingView];
    if([self.flagstatus isEqualToString:@"Backup"])
    {
        lblLoading.text = @"Backing up...";
        [_loadingView addSubview:lblLoading];
        [self loadDriveFiles];
    }
    else if ([self.flagstatus isEqualToString:@"Restore"])
    {
        lblLoading.text = @"Restoring...";
        [_loadingView addSubview:lblLoading];
        [self loadDrivefolder];
    }
    
}




- (GTLRDriveService *)driveService {
    static GTLRDriveService *service = nil;
    
    if (!service) {
        service = [[GTLRDriveService alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    }
    return service;
}

// Helper for showing an alert
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


#pragma mark ---- Backup ----
//Check if folder exists
- (void)loadDriveFiles {
    
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.fields = @"nextPageToken, files(id, name,mimeType)";
    query.q = [NSString stringWithFormat:@"'%@' IN parents and trashed = false", @"root"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"folderid"];

    //query.pageSize = 10;
    
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(processResultWithTicket:finishedWithObject:error:)];

    
}
// Process the response and display output
- (void)processResultWithTicket:(GTLRServiceTicket *)ticket
             finishedWithObject:(GTLRDrive_FileList *)result
                          error:(NSError *)error {
    if (error == nil) {
        
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        
        if(result.files.count !=0)
        {
            if (self.driveFiles == nil) {
                self.driveFiles = [[NSMutableArray alloc] init];
            }
            [self.driveFiles removeAllObjects];
            [self.driveFiles addObjectsFromArray:result.files];
            //GTLDriveFile *file = [self.driveFiles objectAtIndex:0];
            for(GTLRDrive_File *fileval in self.driveFiles)
            {
                if( [fileval.name isEqualToString:@"Simply Auto"] && [fileval.mimeType isEqualToString:@"application/vnd.google-apps.folder"])
                {
                    //NSLog(@"file title %@",fileval.title);
                    //NSLog(@"drive file %@",fileval.identifier);
                    [def setObject:fileval.identifier forKey:@"folderid"];
                }
                
                if( [fileval.name isEqualToString:@"Simply Auto Receipts"] && [fileval.mimeType isEqualToString:@"application/vnd.google-apps.folder"])
                {
                    //NSLog(@"file title %@",fileval.title);
                    //NSLog(@"drive file %@",fileval.identifier);
                    [def setObject:fileval.identifier forKey:@"receiptid"];
                }
                
            }
            //Create or Check availability of the folder
            [self checkOrCreateFolder:[def objectForKey:@"folderid"] WithfolderName:@"Simply Auto"];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"] && receiptbackuprestore == YES)
            {
                
                BOOL setNil = [def boolForKey:@"createdSimplyAutoReceipts"];
                if(!setNil){
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"receiptid"];
                    [def setBool:YES forKey:@"createdSimplyAutoReceipts"];
                }
                NSString *recptId = [def objectForKey:@"receiptid"];
                [self checkOrCreateFolder:recptId WithfolderName:@"Simply Auto Receipts"];
            }
        }
        
       
    }
    
    else {
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendFormat:@"Error getting presentation data: %@\n", error.localizedDescription];
        [self showAlert:@"Error" message:message];
    }
}

//Create folder
- (void)checkOrCreateFolder:(NSString*)folderId
            WithfolderName:(NSString*)folderName
{
    
    GTLRDrive_File *folder = [GTLRDrive_File object];
    folder.name = folderName;
    folder.mimeType = @"application/vnd.google-apps.folder";
  
    if(folderId == nil)
    //Folder does not exist.
    {
        GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:folder uploadParameters:nil];
        [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                             GTLRDrive_File *updatedFile,
                                                             NSError *error) {
            if (error == nil) {
              //  NSLog(@"Created folder");
              
                
                [self prepareVehicleFile];
                [self prepareFillUpsFile];
                [self prepareServiceFile];
                [self prepareTripFile];
                [self uploadAllfiles];
                
            } else {
             //   NSLog(@"An error occurred: %@", error);
                [self.loadingView removeFromSuperview];
            }
        }];
    }
    
    else
    {
        //NSLog(@"Folder exists");
        
        [self prepareVehicleFile];
        [self prepareFillUpsFile];
        [self prepareServiceFile];
        [self prepareTripFile];
        [self uploadAllfiles];
        
        
    }
    
}


////Create Vehicle CSV
-(void) prepareVehicleFile
{
    NSString* str= [self exportvehCSV];
    
    // Writing
    
    //Swapnil ENH_24
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Vehicles.csv"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSError *error;
    
    if (fileExists)    //Does file exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])   //Delete it
        {
         //   NSLog(@"Delete file error: %@", error);
        }
    }
    
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    
}

//Get vehicle data for CSV
- (NSString *)exportvehCSV
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
    
    //Swapnil ENH_30
    NSString *firstrow = @"Row ID,Make,Model,Fuel Type,Year,Lic#,Vin,Insurance#,Notes,Picture Path,Vehicle ID,Other Specs";
    [results addObject:firstrow];
    int vehid =0;
    for(Veh_Table *veh in vehicle)
    {
        vehid++;
        //NSString *picture = @"";
        //NSString *vehicleid = [NSString stringWithFormat:@"%@ %@",veh.make,veh.model];
        //NSLog(@"vehid id......%@.....",veh.vehid);
        //Swapnil ENH_30
        [results addObject:[NSString stringWithFormat:@"%d,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",vehid,veh.make,veh.model,veh.fuel_type,veh.year,veh.lic,veh.vin,veh.insuranceNo,veh.notes,veh.picture,veh.vehid,veh.customSpecs]];
    }
    
    //NSLog(@"firstRow = %@", results);
    
    NSString *resultString = [results componentsJoinedByString:@"\n"];
    resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    //NSLog(@"result value %@",vehid)
    return resultString;
}


//Create Fuel_Log CSV
-(void) prepareFillUpsFile
{
    NSString* str= [self exportfillupCSV];
    
    // Writing
    
    //Swapnil ENH_24
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Fuel_Log.csv"];
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
    
    
}

//Get fillup data csv
- (NSString *)exportfillupCSV
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];
    
    NSArray *fuel=[contex executeFetchRequest:requset error:&err];
    
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
    
    NSString *firstrow = @"Row ID (For System Use),Vehicle ID,Odometer,Qty,Partial Tank,Missed Previous Fill up,Total Cost,Distance Travelled,Eff,Octane,Fuel Brand,Filling Station,Notes,Day,Month,Year,Receipt Path,Latitude,Longitude,Record Type,Record Desc";
    [results addObject:firstrow];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    
    //Swapnil NEW_6
    //fuelid = 0;
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
        
        //Swapnil NEW_6
        //fuelid = fuelid +1;
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
        
        [results addObject:[NSString stringWithFormat:@"%d,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",[fuelrecord.iD intValue], vehid, fuelrecord.odo, fuelrecord.qty,[fuelrecord.pfill stringValue],[fuelrecord.mfill stringValue],[fuelrecord.cost stringValue],[fuelrecord.dist stringValue],fuelrecord.cons,[fuelrecord.octane stringValue],fuelrecord.fuelBrand,fuelrecord.fillStation,fuelrecord.notes,day,month,year,fuelrecord.receipt,fuelrecord.latitude,fuelrecord.longitude,[fuelrecord.type stringValue],fuelrecord.serviceType]];
    }
    
    NSString *resultString = [results componentsJoinedByString:@"\n"];
    resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    return resultString;
}

//Create Service CSV
-(void) prepareServiceFile
{
    NSString* str= [self exportserviceCSV];
    
    // Writing
    
    //Swapnil ENH_24
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Services.csv"];
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
    
    
    
}


//Get service data for csv
-(NSString *) exportserviceCSV
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
   
    //BUG_48
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
   // [requset setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];
    
    
    NSArray *servicearray=[contex executeFetchRequest:requset error:&err];
    
    
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
    NSString *firstrow = @"Row ID,Vehicle ID,Record Type,Service Name,Recurring,Due Miles,Due Days,Last Odo,Last Date";
    [results addObject:firstrow];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
    
    //Swapnil NEW_6
    //int serviceid=0;
    
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
        
        //Swapnil NEW_6
        //serviceid = serviceid +1;
        
        NSString *lastdate = [formater stringFromDate:service.lastDate];
        // NSLog(@"lastdate is %@", lastdate);
        
        
        NSTimeInterval unixTimeStamp = 0;
        
        if (!(lastdate == nil || [lastdate isEqualToString:@"01/01/1970"]))
        {
            
            NSDate *date = [formater dateFromString:lastdate];
            unixTimeStamp = [date timeIntervalSince1970] * 1000;
            
        }
        //  NSLog(@"timestamp is %f", unixTimeStamp);
        
        [results addObject:[NSString stringWithFormat:@"%d,%@,%@,%@,%@,%@,%@,%@,%f",[service.iD intValue],vehid,service.type,service.serviceName,service.recurring,service.dueMiles,service.dueDays,service.lastOdo,unixTimeStamp]];
    }
    
    NSString *resultString = [results componentsJoinedByString:@"\n"];
    //   NSLog(@"resultString is : %@", resultString);
    resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    //NSLog(@"result for service %@",resultString);
    return resultString;
}


//Create Trip CSV
-(void) prepareTripFile
{
    NSString* str= [self exportTripCSV];
    
    // Writing
    
    //Swapnil ENH_24
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Trip_Log.csv"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSError *error;
    
    if (fileExists)    //Does file exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])   //Delete it
        {
           // NSLog(@"Delete file error: %@", error);
        }
    }
    
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    
    
}

//Get Trip data for csv
-(NSString *) exportTripCSV
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    //[requset setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];
    
    
    
    NSArray *tripArray=[contex executeFetchRequest:requset error:&err];
    
    
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
    NSString *firstrow = @"Row ID,Vehicle ID,Departure Odo,Arrival Odo,Departure Loc,Arrival Loc,Departure Day,Departure Month,Departure Year,Departure Hour,Departure Min,Arrival Day, Arrival Month, Arrival Year, Arrival Hour, Arrival Min, Parking,Toll,Tax Ded,Notes,Departure Latitude,Departure Longitude,Arrival Latitiude,Arrival Longitude,Trip Type"; //21-25
    [results addObject:firstrow];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd/MM/yyyy"];
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
        
       //NSString *firstrow = @"Row ID,Vehicle ID,Departure Odo,Arrival Odo,Departure Loc,Arrival Loc,Departure Day,Departure Month,Departure Year,Departure Hour,Departure Min,Arrival Day, Arrival Month, Arrival Year, Arrival Hour, Arrival Min, Parking,Toll,Tax Ded,Notes,Departure Latitude,Departure Longitude,Arrival Latitiude,Arrival Longitude,Trip Type"; //21-25
        
        [results addObject:[NSString stringWithFormat:@"%d,%@,%f,%f,%@,%@,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%@,%@,%@,%@,%@,%@,%@,%@,%@",[tripRec.iD intValue],vehid,[tripRec.depOdo floatValue],[tripRec.arrOdo floatValue],tripRec.depLocn, tripRec.arrLocn,(long)depDay,(long)depMonth,(long)depYear,(long)depHour,(long)depMin,(long)arrDay,(long)arrMonth,(long)arrYear,(long)arrHour,(long)arrMin,tripRec.parkingAmt,tripRec.tollAmt,tripRec.taxDedn, tripRec.notes,tripRec.depLatitude,tripRec.depLongitude,tripRec.arrLatitude,tripRec.arrLongitude, tripRec.tripType ]];
    }
    
    NSString *resultString = [results componentsJoinedByString:@"\n"];
    // NSLog(@"resultString is : %@", resultString);
    resultString =  [resultString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    //NSLog(@"result for Trip %@",resultString);
    return resultString;
}


//Remove start
//Get folder id if exist
-(void)uploadAllfiles
{
    
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.fields = @"nextPageToken, files(id, name,mimeType)";
    query.q = [NSString stringWithFormat:@"'%@' IN parents and trashed = false", @"root"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"folderid"];
    //query.pageSize = 10;
    
    
    [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRDrive_FileList *response,
                                                         NSError *error) {
        
        if (error == nil) {
            if (self.driveFiles == nil) {
                self.driveFiles = [[NSMutableArray alloc] init];
            }
            [self.driveFiles removeAllObjects];
            [self.driveFiles addObjectsFromArray:response.files];
            for(GTLRDrive_File *folder in self.driveFiles)
            {
                if([folder.name isEqualToString:@"Simply Auto"] && [folder.mimeType isEqualToString:@"application/vnd.google-apps.folder"])
                {
                    [[NSUserDefaults standardUserDefaults]setObject:folder.identifier forKey:@"folderid"];
                  
                    //[self checkforexistingvehiclefile:folder];
                    
                    //Loop through the folder to get all file identifiers;
                    
                    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
                    query.fields = @"nextPageToken, files(id, name)";
                    query.q = [NSString stringWithFormat:@"'%@' IN parents and trashed = false",folder.identifier];
                    
                    [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                                         GTLRDrive_FileList *response,
                                                                         NSError *error) {
                        if (error == nil) {
                            [self.driveFiles removeAllObjects];
                            
                            [self.driveFiles addObjectsFromArray:response.files];
                            for(GTLRDrive_File *file1 in self.driveFiles)
                            {
                                if([file1.name isEqualToString:@"Vehicles.csv"])
                                {
                                    self.vehid = file1.identifier;
                                }
                                else if([file1.name isEqualToString:@"Fuel_Log.csv"])
                                {
                                    self.fuelid = file1.identifier;
                                }
                                else if([file1.name isEqualToString:@"Trip_Log.csv"])
                                {
                                    self.tripid = file1.identifier;
                                }
                                else if([file1.name isEqualToString:@"Services.csv"])
                                {
                                    self.serviceid = file1.identifier;
                                }
                            }
                            
                           // Upload Vehicle File
                            [self uploadToGDriveFolder:folder fileId:_vehid fileName:@"Vehicles.csv"];
                            self.vehid= nil;
                            
                            if (success) {
                                // Upload Fuel Fill ups File
                                [self uploadToGDriveFolder:folder fileId:_fuelid fileName:@"Fuel_Log.csv"];
                                self.fuelid= nil;
                                
                                if (success) {
                                    // Upload Trip File
                                    [self uploadToGDriveFolder:folder fileId:_tripid fileName:@"Trip_Log.csv"];
                                    self.tripid=nil;
                                    
                                    if (success) {
                                        // Upload service File
                                        [self uploadToGDriveFolder:folder fileId:_serviceid fileName:@"Services.csv"];
                                        self.serviceid=nil;
                                        
                                        if (success) {
                                            if(!receiptbackuprestore){
                                                [self showAlert:NSLocalizedString(@"exp_success_noti_msg", @"Files successfully backed up on Google Drive") message:@""];
                                                [self.loadingView removeFromSuperview];
                                            }
                                        }
                                        else
                                        {    //New_8 changesDone
                                            [self showAlert:NSLocalizedString(@"services_err_title", @"Error Backing up Services file")  message:@"Please contact support-ios@simplyauto.app"];
                                            [self.loadingView removeFromSuperview];
                                        }
                                    }
                                    else
                                    {    //New_8 changesDone
                                        [self showAlert:@"Error Backing up Trip Log file" message:@"Please contact support-ios@simplyauto.app"];
                                        [self.loadingView removeFromSuperview];
                                    }
                                }
                                else
                                {    //New_8 changesDone
                                    [self showAlert:NSLocalizedString(@"fuel_log_err_title", @"Error Backing up Fuel Log file") message:@"Please contact support-ios@simplyauto.app"];
                                    [self.loadingView removeFromSuperview];
                                }
                            }
                            else
                            {    //New_8 changesDone
                            [self showAlert:NSLocalizedString(@"vehicle_err_title", @"Error Backing up Vehicle file")  message:@"Please contact support-ios@simplyauto.app"];
                            [self.loadingView removeFromSuperview];

                            }
               
                    }
                        else
                        {
                          //  NSLog(@"error val %@",error);
                        }
                        
                    }];
                  
                }
                else if([folder.name isEqualToString:@"Simply Auto Receipts"] && [folder.mimeType isEqualToString:@"application/vnd.google-apps.folder"] && !hasCalledBackUpReceipt)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:folder.identifier forKey:@"receiptid"];
                    
                    // Upload Receipts
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"] && receiptbackuprestore == YES)
                    {
                        //ENH_57
                        [self backupReceiptOrg:folder];
                        hasCalledBackUpReceipt = YES;
                    }
                    
                }
            }
            
        } else {
            [self showAlert:error.localizedDescription message:@""];
          //  NSLog(@"An error occurred: %@", error);
            [self.loadingView removeFromSuperview];
            
        }
    }];
    
    [self.loadingView removeFromSuperview];

    
}
////Create/Update Vehicle CSV




-(void)uploadToGDriveFolder: (GTLRDrive_File*)folder
                         fileId:(NSString*)fileId
                           fileName:(NSString*)fileName
{
    success = YES;
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName];
    GTLRDrive_File *uploadFile = [GTLRDrive_File object];
    uploadFile.name = fileName;
    uploadFile.mimeType = @"text/csv";
    
    GTLRUploadParameters *uploadParameters = [GTLRUploadParameters uploadParametersWithData:[NSData dataWithContentsOfFile:filePath]
                                                                                   MIMEType:@"text/csv"];
    
    uploadParameters.shouldUploadWithSingleRequest = TRUE;
    
    
    if(fileId!=nil)
    {
        //File exists in the folder
        
        GTLRDriveQuery_FilesUpdate   *query = [GTLRDriveQuery_FilesUpdate queryWithObject:uploadFile fileId:fileId uploadParameters:uploadParameters];
        
        query.addParents = folder.identifier;
        // query.removeParents = [file.parents componentsJoinedByString:@", "];
        query.fields = @"id, parents";
        
        [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                             GTLRDrive_File *file,
                                                             NSError *error) {
            if (error == nil) {
                
                success = YES;
                
            
            } else {
                success = NO;
              //  NSLog(@"An error occurred: %@", error);
               
                
            }
        }];
        
    }
    else
    {
        //File doesnt exist, Create new file
        
        uploadFile.parents = [NSArray arrayWithObject:folder.identifier];
        GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:uploadFile
                                                                       uploadParameters:uploadParameters];
        
        [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                             GTLRDrive_File *file,
                                                             NSError *error) {
            
            if (error == nil) {
                success = YES;
                
                
            } else {
                
                success = NO;
             //   NSLog(@"An error occurred: %@", error);
                
                
                    }
                }];
                
                
            }
            
    
}

-(void)backupReceiptOrg : (GTLRDrive_File*)folder {

    
    __block long recordvalue=0;
    
    
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.fields = @"nextPageToken, files(id, name)";
    query.q = [NSString stringWithFormat:@"'%@' IN parents and trashed = false",folder.identifier];
    
    [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRDrive_FileList *response,
                                                         NSError *error)
    {
        if (error == nil) {
            [self.driveFiles removeAllObjects];
            
            [self.driveFiles addObjectsFromArray:response.files];
            
           // NSArray* fileNames = [NSArray arrayWithObjects: [self.driveFiles valueForKey:@"name"], nil];
            
            NSArray* uniqueValues = [self.driveFiles valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@",@"name"]];
            
            //NIKHIL BUG_146
            NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
            NSError *err;
            NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"receipt != nil"];
            [requset setPredicate:predicate];
            NSArray *fuel=[contex executeFetchRequest:requset error:&err];
            
            if (fuel.count==0) {
                [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"receiptid"];
                [self showAlert:@"No receipts to backup" message:@""];
            }else{
            
            
                for(T_Fuelcons *record in fuel){
                    
                    NSString *emptyString = @"";
                    if(![record.receipt isEqualToString:emptyString]){
                       
                
                      NSString *wholeImageString = [[NSString alloc]init];
                      wholeImageString = record.receipt;
                      NSArray *separatedArray = [wholeImageString componentsSeparatedByString:@":::"];
                      for(int i=0;i<separatedArray.count;i++){
                       
                            NSString *path = [separatedArray objectAtIndex:i];
//                            if(path.length > 0){
//                                finalString = [path substringFromIndex:87];
//                            }
                      
                        //Add files that do not already exist on the server
                        if (![uniqueValues containsObject:path])
                        {
                        
                           NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        
                           //Swapnil ENH_24
                           NSString *documentsDirectory = [paths firstObject];
                        
                           // NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                           NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:path];
                        
                           UIImage *image= [[UIImage alloc]init];
                           image= [UIImage imageWithContentsOfFile:imagePath];
                    
                           GTLRDrive_File *file = [GTLRDrive_File object];
                           //NSLog(@"record.receipt:- %@",path);
                           file.name = path;
                           file.mimeType = @"image/png";
                           NSData *data = UIImagePNGRepresentation(image);
                    
                           GTLRUploadParameters *uploadParameters = [GTLRUploadParameters uploadParametersWithData:data MIMEType:file.mimeType];
                           uploadParameters.shouldUploadWithSingleRequest = TRUE;
                    
                           //File doesnt exist, Create new file
                        
                           file.parents = [NSArray arrayWithObject:folder.identifier];
                           GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:file
                                                                                uploadParameters:uploadParameters];
                        
                           [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                                             GTLRDrive_File *file,
                                                                             NSError *error) {
                            if (error == nil)
                            {
                                recordvalue = recordvalue +1;
                                if(recordvalue == fuel.count)
                                {
                                    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"receiptid"];
                                    //ENH_57
                                    [self showAlert:@"" message:@"Files successfully backed up on Google Drive with Receipts"];
                                }
                       
                                
                             }
                            else
                            {   //New_8 changesDone
                               // NSLog(@"An error occurred: %@", error);
                                [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"receiptid"];
                                [self showAlert:NSLocalizedString(@"receipt_upload_failed", @"Error backing up Receipts. Please contact support-ios@simplyauto.app")  message:error.localizedDescription];
                            }
                         }];
                        
                      }
                     }
                   }
                }
              }
            }
            
        
    }];
    
    
}

#pragma mark ---- Restore ----
- (void)loadDrivefolder {
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.fields = @"nextPageToken, files(id, name,mimeType)";
    query.q = [NSString stringWithFormat:@"'%@' IN parents and trashed = false", @"root"];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"folderid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRDrive_FileList *result,
                                                         NSError *error) {
        
        if (error == nil) {
            
            if(result.files.count !=0)
            {
                if (self.driveFiles == nil) {
                    self.driveFiles = [[NSMutableArray alloc] init];
                }
                [self.driveFiles removeAllObjects];
                [self.driveFiles addObjectsFromArray:result.files];
                //GTLDriveFile *file = [self.driveFiles objectAtIndex:0];
                BOOL simplyAutoPresent = NO;
                BOOL simplyAutoReceiptPresent = NO;
                for(GTLRDrive_File *fileval in self.driveFiles)
                {
                    //TODO keep fuel buddy for some time//as user could restore first
                    if( [fileval.name isEqualToString:@"Simply Auto"] && [fileval.mimeType isEqualToString:@"application/vnd.google-apps.folder"])
                    {
                        fuelBuddyFolder = fileval;
                        
                        [[NSUserDefaults standardUserDefaults]setObject:fileval.identifier forKey:@"folderid"];
                        //Nupur
                        //[self vehiclefiletorestore:fileval];
                        [self restoreFile:@"Vehicles.csv" inFolder:fuelBuddyFolder];
                        simplyAutoPresent = YES;
                        
                    }else if(!simplyAutoPresent && [fileval.name isEqualToString:@"Fuel Buddy"] && [fileval.mimeType isEqualToString:@"application/vnd.google-apps.folder"])
                    {
                        fuelBuddyFolder = fileval;
                        
                        [[NSUserDefaults standardUserDefaults]setObject:fileval.identifier forKey:@"folderid"];
                        //Nupur
                        //[self vehiclefiletorestore:fileval];
                        [self restoreFile:@"Vehicles.csv" inFolder:fuelBuddyFolder];
                    }
                    
                    if( [fileval.name isEqualToString:@"Simply Auto Receipts"] && [fileval.mimeType isEqualToString:@"application/vnd.google-apps.folder"])
                    {
                        //NSLog(@"file title %@",fileval.title);
                        //NSLog(@"drive file %@",fileval.identifier);
                        receiptFolder=fileval;
                        [[NSUserDefaults standardUserDefaults]setObject:fileval.identifier forKey:@"receiptid"];
                        simplyAutoReceiptPresent = YES;
                        
                    }else if(!simplyAutoReceiptPresent && [fileval.name isEqualToString:@"Fuel Buddy Receipts"] && [fileval.mimeType isEqualToString:@"application/vnd.google-apps.folder"])
                    {
                        //NSLog(@"file title %@",fileval.title);
                        //NSLog(@"drive file %@",fileval.identifier);
                        receiptFolder=fileval;
                       // [[NSUserDefaults standardUserDefaults]setObject:fileval.identifier forKey:@"receiptid"];
                    }

                }
                
                
            } else {
                
                // TODO make a more valid message
                [self showAlert:@"No Data Found" message:@""];
            }
            
        }}];
    
}

-(void)restoreFile:(NSString*)fileName
          inFolder:(GTLRDrive_File*)folder
{
    //restoreErrorFile = @"Vehicles.csv";

    
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.fields = @"nextPageToken, files(id, name,mimeType)";
    query.q = [NSString stringWithFormat:@"'%@' IN parents and trashed = false",folder.identifier];
    
    [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRDrive_FileList *result,
                                                         NSError *error) {
        if (error == nil)
        {
            [self.driveFiles removeAllObjects];

            [self.driveFiles addObjectsFromArray:result.files];

            for(GTLRDrive_File *file1 in self.driveFiles)
            {
                 if([file1.name isEqualToString:@"Vehicles"]||[file1.name isEqualToString:@"Vehicles.csv"])
                     vehFile = file1;
                else if ([file1.name isEqualToString:@"Fuel_Log"]||[file1.name isEqualToString:@"Fuel_Log.csv"])
                    fuelFile = file1;
                else if ([file1.name isEqualToString:@"Services"]||[file1.name isEqualToString:@"Services.csv"])
                    serviceFile = file1;
                else if ([file1.name isEqualToString:@"Trip_Log"]||[file1.name isEqualToString:@"Trip_Log.csv"])
                    tripFile = file1;

            }


            if (vehFile == nil || fuelFile == nil || serviceFile==nil) {
                [self showAlert:@"Some files are not found for restore" message:@"Please make sure you have the backup file present in the 'Google Drive->Simply Auto' folder"];
                [self.loadingView removeFromSuperview];

            }

            //Download files (Nested)
            [self downloadFile:vehFile];
            
       }
        else {
           // NSLog(@"An error occurred: %@", error);
            [self showAlert:NSLocalizedString(@"imp_err_msg", @"Error occured while restoring files")  message:error.localizedDescription];
            [self.loadingView removeFromSuperview];
            }
    }];

}



-(void)downloadFile:(GTLRDrive_File*)inputFile
{
    success = YES;
    GTLRQuery *query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:inputFile.identifier];
    
    [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRDataObject *file,
                                                         NSError *error) {
        if (error == nil) {
           // NSLog(@"Downloaded %lu bytes", (unsigned long)file.data.length);
            
            //Swapnil ENH_24
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            
            NSString *filePath = [documentsPath stringByAppendingPathComponent:inputFile.name];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            NSError *error;
            
            if (fileExists)    //Does file exist?
            {
                if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])   //Delete it
                {
                  //  NSLog(@"Delete file error: %@", error);
                }
            }
            
            [file.data writeToFile:filePath atomically:YES];
            
            if ([inputFile.name isEqualToString:@"Vehicles.csv"])
            {
                [self readvehicledata:filePath];
            }
            if ([inputFile.name isEqualToString:@"Fuel_Log.csv"])
            {
                [self readfueldata:filePath];
            }
            if ([inputFile.name isEqualToString:@"Services.csv"])
            {
                [self readservicedata:filePath];
            }
            if ([inputFile.name isEqualToString:@"Trip_Log.csv"])
            {
                [self readTripData:filePath];
            }
       
        }
        else {
            
           // NSLog(@"Trip File not found / downloaded: %@", error);
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"] && receiptbackuprestore == YES)
            {
                
                NSString *fileid = [[NSUserDefaults standardUserDefaults]objectForKey:@"receiptid"];
                if(fileid.length>0)
                {
                    [self restoreReceipt:fileid];
                }
                
                
            }
            else {
                [self showAlert:NSLocalizedString(@"restore_success", @"Restore successful")  message:@"All files were successfully restored"];
                
                NSString *userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
                
                if(userEmail != nil && userEmail.length > 0){
                    
                    [self performSelectorInBackground:@selector(uploadDataToServer) withObject:nil];
                }

                [self.loadingView removeFromSuperview];
                
            }

        
        }
        
    }];


}



////Restore receipt
//
-(void)restoreReceipt:(NSString*)folderId {
    
    
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.fields = @"nextPageToken, files(id, name,mimeType)";
    query.q = [NSString stringWithFormat:@"'%@' IN parents and trashed = false", folderId];
  
    
  __block long recordcount = 0;
    [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRDrive_FileList *result,
                                                         NSError *error) {
        
        if (error == nil) {
            
            if(result.files.count !=0)
            {
                if (self.driveFiles == nil) {
                    self.driveFiles = [[NSMutableArray alloc] init];
                }
                [self.driveFiles removeAllObjects];
                [self.driveFiles addObjectsFromArray:result.files];
                //GTLDriveFile *file = [self.driveFiles objectAtIndex:0];
                for(GTLRDrive_File *fileval in self.driveFiles)
                {
                    GTLRQuery *query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:fileval.identifier];
                    
                    [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                                         GTLRDataObject *file,
                                                                         NSError *error) {
                    if (error == nil) {
                        
                        //Swapnil ENH_24
                            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                            
                            NSString *filePath = [documentsPath stringByAppendingPathComponent:fileval.name];
                            //NSLog(@"fileval %@",filePath);
                        
                            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                            NSError *error;
                            
                            if (fileExists)    //Does file exist?
                            {
                                if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])   //Delete it
                                {
                                   // NSLog(@"Delete file error: %@", error);
                                }
                            }
                            recordcount = recordcount + 1;
                            [file.data writeToFile:filePath atomically:YES];
                        
                            if(recordcount == self.driveFiles.count)
                            {
                                [self.loadingView removeFromSuperview];
                                [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"receiptid"];
                                [self showAlert:@"Restore of file with receipts successful" message:@""];
                            }
                            // });
                            
                            
                        } else {
                          //  NSLog(@"An error occurred: %@", error);
                        }
                    }];
 
                }
                
            }
            else
            {
               // NSLog(@"error %@",error);
            }
            }}];
    
    
}

-(void)readvehicledata:(NSString*)path
{
    
    success = YES;
  
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    //NSLog(@"filedata %@",content);
    NSArray *datavalue = [[NSArray alloc]init];
    datavalue = [content componentsSeparatedByString:@"\n"];
    NSLog(@"data to save %@",datavalue);

   
        NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
        NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSError *err;
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                        ascending:YES];
        
        NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
        [requset setSortDescriptors:sortDescriptors1];
        
        
        NSArray *data=[contex executeFetchRequest:requset error:&err];
        
        for (NSManagedObject *product in data) {
            [contex deleteObject:product];
            
        }
//        NSError *error = nil;
//        if (![contex save:&error]) {
//            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
//        }
        @try {

            for(int i=1;i<datavalue.count;i++)
        {
            NSString *recordvalue = [datavalue objectAtIndex:i];
            NSArray *mainArray = [[NSArray alloc]init];
            mainArray = [recordvalue componentsSeparatedByString:@","];
            NSMutableArray *recordarray = [[NSMutableArray alloc] initWithArray:mainArray];
            
            NSString *firstString = [datavalue firstObject];
            
            if(![firstString containsString:@"Fuel Type"]){
                
                [recordarray insertObject:@"Fuel Type" atIndex:3];
            }
            
            //NSLog(@"values of record array %@ at index %d",recordarray,i);
            Veh_Table *data=[NSEntityDescription insertNewObjectForEntityForName:@"Veh_Table" inManagedObjectContext:contex];
            
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            
            //Swapnil ENH_24
            data.iD = [NSNumber numberWithInt:[[recordarray firstObject] intValue]];
            
            [def setObject:data.iD forKey:@"idvalue"];
            data.make = [recordarray objectAtIndex:1];
            data.model = [recordarray objectAtIndex:2];
            data.fuel_type = [recordarray objectAtIndex:3];
            data.lic = [recordarray objectAtIndex:5];
            data.vin = [recordarray objectAtIndex:6];
            data.year = [recordarray objectAtIndex:4];
            data.insuranceNo = [recordarray objectAtIndex:7];
            data.notes = [recordarray objectAtIndex:8];
            data.vehid = [NSString stringWithFormat:@"%@ %@",[recordarray objectAtIndex:1],[recordarray objectAtIndex:2]];
            data.vehid = [recordarray objectAtIndex:10];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"] && receiptbackuprestore == YES)
            {
                //ENH_57 save the string directly
                NSString *pathString = [recordarray objectAtIndex:9];
                //NSLog(@"pathString:- %@",pathString);
                data.picture = pathString;
            }
            
            //Swapnil ENH_30
            NSMutableArray *custSpecArr = [[NSMutableArray alloc] init];
            for(int i = 10; i < recordarray.count; i++){
                [custSpecArr addObject:[recordarray objectAtIndex:i]];
            }
            //NSLog(@"restore arr = %@", custSpecArr);
            NSString *customSpec = [custSpecArr componentsJoinedByString:@","];
            
            data.customSpecs = customSpec;
 
            NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
            Veh_Table *firstrecord = [datavalue firstObject];
            Veh_Table *lastrecord = [datavalue lastObject];
            
            [def setObject:[NSString stringWithFormat:@"%ld",(long)[lastrecord.iD integerValue]] forKey:@"idvalue"];
            //BUG_172 Changed from firstrecord to lastrecord
            [def setObject:lastrecord.vehid forKey:@"vehname"];
            [def setObject:[NSString stringWithFormat:@"%ld",(long)[firstrecord.iD integerValue]] forKey:@"fillupid"];
        }
            
        } @catch (NSException *exception) {
            if (exception.name == NSRangeException) {
                NSLog(@"Caught an NSRangeException");
                
            } else {
                NSLog(@"Ignored a %@ exception", exception);
                @throw;
            }
            
            if ([contex hasChanges])
            {
                [contex rollback];
                NSLog(@"Rolled back changes.");
            }
            success = NO;

            //New_8 changesDone
            [self showAlert:@"" message:NSLocalizedString(@"imp_err_msg", @"Failed to restore file. Please contact support at support-ios@simplyauto.app.")];
            [self.loadingView removeFromSuperview];
            
            
        } @finally {
            NSLog(@"Executing finally block");
            if ([contex hasChanges])
            {
                BOOL saved = [contex save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
                NSLog(@"Context saved");
                [[CoreDataController sharedInstance] saveMasterContext];
                
            }
            [self downloadFile:fuelFile];
           
        }

    
}


-(void)readfueldata:(NSString*)path
{
    NSString* actionMessage;
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    //NSLog(@"filedata %@",content);
    NSArray *datavalue = [[NSArray alloc]init];
    datavalue = [content componentsSeparatedByString:@"\n"];
    NSLog(@"filedata %@",datavalue);
    
        NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
        NSError *err;
        NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                       ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [requset setSortDescriptors:sortDescriptors];
        
        NSArray *fuel=[contex executeFetchRequest:requset error:&err];
        for (NSManagedObject *product in fuel) {
            [contex deleteObject:product];
            
        }

        
        NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                        ascending:YES];
        NSError *err1;
        NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
        [requset1 setSortDescriptors:sortDescriptors1];
        
        NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
        
        //NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd/MM/yyyy"];
    
        int recordNo = 0;
        @try {
            actionMessage = @"Reading Fuel Data";
           // int maxFuelID = 0;
            for(int i=1;i<datavalue.count;i++)
            {
                recordNo = i;
                NSString *recordvalue = [datavalue objectAtIndex:i];
                NSArray *mainArray = [[NSArray alloc]init];
                mainArray = [recordvalue componentsSeparatedByString:@","];
                
                NSMutableArray *recordarray = [[NSMutableArray alloc] initWithArray:mainArray];
                
                //For old records as they have extra semicolon from google places
                if(recordarray.count == 20){
                    
                    [recordarray removeObjectAtIndex:13];
                }
                //New_11 Maps addidtion of Lat long
                //Row ID 0-2,Vehicle ID 1-Default Car,Odometer 2-104065,Qty 3-11.897,Partial Tank 4-0,Missed Fill Up 5-0,Total Cost 6-22,Distance Travelled 7-304,Eff 8-25.55266,Octane 9-0,Fuel Brand 10-Kroger Fuel Center,Filling Station 11-3035 Richmond Road,Notes 12-Lexington,Day 13- ,Month 14-02,Year 15-01,Receipt Path 16-2019,Latitude 17- ,Longitude 18-0,Record Type 19-Fuel Record,Record Desc 20
                //NSLog(@"recordarray.count:= %lu",recordarray.count);
                if(recordarray.count==19){
                    
                    [recordarray insertObject:@"0" atIndex:17];
                    [recordarray insertObject:@"0" atIndex:18];
                    
                }
                
                T_Fuelcons *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"T_Fuelcons" inManagedObjectContext:contex];
                NSString *datestring = [NSString stringWithFormat:@"%@/%@/%@",[recordarray objectAtIndex:13],[recordarray objectAtIndex:14],[recordarray objectAtIndex:15]];
                // NSLog(@"date string value %@",datestring);
                NSString *vehidvalue;
                for(Veh_Table *vehdata in vehicle)
                {
                    if([[recordarray objectAtIndex:1] isEqual:vehdata.vehid])
                    {
                        vehidvalue = [vehdata.iD stringValue];
                        break;
                    }
                }
                
                //Get all  comma separated services
                
                NSString* services = [recordarray objectAtIndex:20] ;
                
                if (recordarray.count > 21) {
                    
                    services = [services stringByAppendingString:@","];
                    
                    for (int j = 21; j < recordarray.count; j++) {
                        
                        NSString *trimmedString = [[recordarray objectAtIndex:j] stringByTrimmingCharactersInSet:
                                                   [NSCharacterSet whitespaceCharacterSet]];
                        
                        services = [services stringByAppendingString:[trimmedString stringByAppendingString:@","]];
                        
                    }
                    services = [services substringToIndex:[services length] - 1];
      
                }
                
            //    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                dataval.iD = @([[recordarray objectAtIndex:0] intValue]);
                
            //    int compareTemp = [dataval.iD intValue];
            //    if(compareTemp > maxFuelID){
            //        maxFuelID = compareTemp;
            //    }
                
            //    [def setInteger:maxFuelID forKey:@"maxFuelID"];
                //NSLog(@"maxFuelID = %@",[def objectForKey:@"maxFuelID"]);
                dataval.odo =@([[recordarray objectAtIndex:2] floatValue]);
                dataval.vehid = vehidvalue;
                dataval.qty = @([[recordarray objectAtIndex:3] floatValue]);
                dataval.stringDate= [formater dateFromString:datestring];
                dataval.type = @([[recordarray objectAtIndex:19]integerValue]);
                dataval.serviceType = services;
                dataval.cost = @([[recordarray objectAtIndex:6] floatValue]);
                dataval.octane = @([[recordarray objectAtIndex:9] floatValue]);
                dataval.fuelBrand = [recordarray objectAtIndex:10];
                dataval.fillStation = [recordarray objectAtIndex:11];
                dataval.longitude = [NSNumber numberWithDouble:[[recordarray objectAtIndex:18] doubleValue]];
                dataval.latitude = [NSNumber numberWithDouble:[[recordarray objectAtIndex:17] doubleValue]];
                dataval.notes =[recordarray objectAtIndex:12];
                dataval.dist =@([[recordarray objectAtIndex:7]floatValue]);
                dataval.pfill = @([[recordarray objectAtIndex:4]integerValue]);
                dataval.mfill = @([[recordarray objectAtIndex:5]integerValue]);
                dataval.cons = @([[recordarray objectAtIndex:8]floatValue]);
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"] && receiptbackuprestore == YES)
                {
                    //ENH_57 save the string directly
                    NSString *pathString = [recordarray objectAtIndex:16];
                    //NSLog(@"pathString:- %@",pathString);
                    dataval.receipt = pathString;
                }
                
            }
            
        } @catch (NSException *exception) {
            if (exception.name == NSRangeException) {
                NSLog(@"Caught an NSRangeException");
                
            } else {
                NSLog(@"Ignored a %@ exception", exception);
                @throw;
            }
            
            if ([contex hasChanges])
            {
                NSLog(@"context rollbacked due to exception.name:-%@",exception.name);
                [contex rollback];
                
            }
            success = NO;

            
        } @finally {
            NSLog(@"Executing finally block");
            if ([contex hasChanges])
            {
                BOOL saved = [contex save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
                NSLog(@"Context saved");
                [[CoreDataController sharedInstance] saveMasterContext];
            }
            //Nikhil BUG_72
            commonMethods *commMethod = [[commonMethods alloc] init];
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            for(Veh_Table *veh in vehicle){
                [def setObject:veh.iD forKey:@"fillupid"];
                [commMethod updateDistance:0];
                [commMethod updateConsumption:0];
            }
            [self downloadFile:serviceFile];

        }

}


-(void)readservicedata:(NSString*)path
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    // NSLog(@"filedata %@",content);
    NSArray *datavalue = [[NSArray alloc]init];
    //NSLog(@"string value %@",content);
    datavalue = [content componentsSeparatedByString:@"\n"];
    NSLog(@"string value %@",datavalue);
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
        NSError *err;
        NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
       // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
       // [requset setPredicate:predicate];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                       ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [requset setSortDescriptors:sortDescriptors];
        
        
        NSArray *fuel=[contex executeFetchRequest:requset error:&err];
        for (NSManagedObject *product in fuel) {
            [contex deleteObject:product];
            
        }

        
        NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                        ascending:YES];
        NSError *err1;
        NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
        [requset1 setSortDescriptors:sortDescriptors1];
        
        NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
        
        
        
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd/MM/yyyy"];
        
        //NSLog(@"datavalue count %lu",(unsigned long)datavalue.count);
        //NSLog(@"datavalue array %@",datavalue);
      
        @try
        {
        for(int i=1;i<datavalue.count;i++)
        {
            NSString *recordvalue = [datavalue objectAtIndex:i];
            NSArray *recordarray = [[NSArray alloc]init];
            recordarray = [recordvalue componentsSeparatedByString:@","];
            // NSLog(@"values of record array %@ at index %d",recordarray,i);
            Services_Table *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:contex];
            NSString *vehidvalue;
            
            for(Veh_Table *vehdata in vehicle)
            {
                               //NSLog(@"value of record 1 %@",[recordarray objectAtIndex:1]);
                              //  NSLog(@"value of vehdata %@",vehdata.vehid);
                if([[recordarray objectAtIndex:1] isEqualToString:vehdata.vehid])
                {
                    vehidvalue = [vehdata.iD stringValue];
                    break;
                }
            }
            
            NSString *lastdate = [recordarray objectAtIndex:8];
            NSTimeInterval timeInterval;
            
            //NSLog(@"last date %@",lastdate);
            if([[lastdate substringToIndex:1] isEqualToString:@"0"])
            {
                timeInterval = 0;
            }
            else
            {
                
            NSString *subStr = [lastdate substringToIndex:10 ];
            timeInterval = [subStr doubleValue];
            //NSLog(@"timeInterval : %f", timeInterval);
                
            }
            
            dataval.type = @([[recordarray objectAtIndex:2]integerValue]);

            if ([dataval.type  isEqualToNumber:@3]) {
                dataval.vehid = [recordarray objectAtIndex:1];
            }
            else
            dataval.vehid = vehidvalue;
            
            //Swapnil NEW_6
            dataval.iD = @([[recordarray objectAtIndex:0] floatValue]);
            
            [def setObject:dataval.iD forKey:@"maxServiceID"];
            
            
            //NSLog(@"service vehid %@",dataval.vehid);
            //NSLog(@"value of service %@",[recordarray objectAtIndex:3]);
            dataval.serviceName = [recordarray objectAtIndex:3];
            
            if(timeInterval != 0){
                dataval.lastDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            }
            dataval.recurring = [NSNumber numberWithInteger: [[recordarray objectAtIndex:4] integerValue]];
            dataval.type = @([[recordarray objectAtIndex:2]integerValue]);
            dataval.lastOdo =@([[recordarray objectAtIndex:7] floatValue]) ;
            dataval.dueDays =@([[recordarray objectAtIndex:6] integerValue]);
            dataval.dueMiles = @([[recordarray objectAtIndex:5] floatValue]);
        }
        
        } @catch (NSException *exception) {
            if (exception.name == NSRangeException) {
                NSLog(@"Caught an NSRangeException");
                
            } else {
                NSLog(@"Ignored a %@ exception", exception);
                @throw;
            }
            
            if ([contex hasChanges])
            {
               NSLog(@"Context rollback");
                [contex rollback];
                
            }
            
           success = NO;
 
            
        } @finally {
            NSLog(@"Executing finally block");
            if ([contex hasChanges])
            {
                BOOL saved = [contex save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
                NSLog(@"Context saved");
                [[CoreDataController sharedInstance] saveMasterContext];
            }
            
            [self downloadFile:tripFile];
            
        }
    
    //}
    
}




-(void)readTripData:(NSString*)path
{
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    // NSLog(@"filedata %@",content);
    NSArray *datavalue = [[NSArray alloc]init];
    //NSLog(@"string value %@",content);
    datavalue = [content componentsSeparatedByString:@"\n"];
    NSLog(@"string value %@",datavalue);
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"T_Trip"];
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    // [requset setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [requset setSortDescriptors:sortDescriptors];
    
    
    NSArray *trip=[contex executeFetchRequest:requset error:&err];
    for (NSManagedObject *product in trip) {
        [contex deleteObject:product];
        
    }
    
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"Veh_Table"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"iD"
                                                                    ascending:YES];
    NSError *err1;
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    NSArray *vehicle=[contex executeFetchRequest:requset1 error:&err1];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *arrDateComponents = [[NSDateComponents alloc] init];
    NSDateComponents *depDateComponents = [[NSDateComponents alloc] init];
    
    @try
    {
       // NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
       // int maxFuelID = [[def objectForKey:@"maxFuelID"] intValue];
        for(int i=1;i<datavalue.count;i++)
        {
            NSString *recordvalue = [datavalue objectAtIndex:i];
//            NSArray *recordarray = [[NSArray alloc]init];
//            recordarray = [recordvalue componentsSeparatedByString:@","];
            
            NSArray *mainArray = [[NSArray alloc]init];
            mainArray = [recordvalue componentsSeparatedByString:@","];
            
            NSMutableArray *recordarray = [[NSMutableArray alloc] initWithArray:mainArray];
            //NSLog(@"recordArray.count:- %lu",(unsigned long)recordarray.count);
            if(recordarray.count==21){
                
                [recordarray insertObject:@"0" atIndex:20];
                [recordarray insertObject:@"0" atIndex:21];
                [recordarray insertObject:@"0" atIndex:22];
                [recordarray insertObject:@"0" atIndex:23];
            }
            
            // NSLog(@"values of record array %@ at index %d",recordarray,i);
            T_Trip *dataval=[NSEntityDescription insertNewObjectForEntityForName:@"T_Trip" inManagedObjectContext:contex];
            NSString *vehidvalue;
            
            for(Veh_Table *vehdata in vehicle)
            {
                //                NSLog(@"value of record 1 %@",[recordarray objectAtIndex:1]);
                //                NSLog(@"value of vehdata %@",vehdata.vehid);
                if([[recordarray objectAtIndex:1] isEqual:vehdata.vehid])
                {
                    vehidvalue = [vehdata.iD stringValue];
                    break;
                }
            }
         //   NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            dataval.iD = @([[recordarray objectAtIndex:0] intValue]);
         //   int compareTemp = [dataval.iD intValue];
         //   if(compareTemp > maxFuelID){
         //       maxFuelID = compareTemp;
         //   }
            
         //   [def setInteger:maxFuelID forKey:@"maxFuelID"];
            //NSLog(@"maxFuelID = %@",[def objectForKey:@"maxFuelID"]);
            dataval.vehId = vehidvalue;
            dataval.arrLocn = [recordarray objectAtIndex:5];
            dataval.arrOdo = [NSNumber numberWithFloat: [[recordarray objectAtIndex:3] floatValue]];
            dataval.depLocn=[recordarray objectAtIndex:4] ;
            dataval.depOdo =[NSNumber numberWithFloat: [[recordarray objectAtIndex:2] floatValue]];
	      //   NSNumber *iD	=[NSNumber numberWithInteger: [[recordarray objectAtIndex:] integerValue]];
            dataval.notes =[recordarray objectAtIndex:19] ;
            dataval.parkingAmt=[NSNumber numberWithFloat: [[recordarray objectAtIndex:16] floatValue]];
            dataval.taxDedn=[NSNumber numberWithFloat: [[recordarray objectAtIndex:18] floatValue]];
            dataval.tollAmt=[NSNumber numberWithFloat: [[recordarray objectAtIndex:17] floatValue]];
            dataval.tripType = [recordarray objectAtIndex:24] ;
            dataval.depLatitude = [NSNumber numberWithDouble:[[recordarray objectAtIndex:20] doubleValue]];
            dataval.depLongitude = [NSNumber numberWithDouble:[[recordarray objectAtIndex:21] doubleValue]];
            dataval.arrLatitude = [NSNumber numberWithDouble:[[recordarray objectAtIndex:22] doubleValue]];
            dataval.arrLongitude = [NSNumber numberWithDouble:[[recordarray objectAtIndex:23] doubleValue]];
            arrDateComponents.day = [[recordarray objectAtIndex:11] integerValue];
            arrDateComponents.month = [[recordarray objectAtIndex:12] integerValue];
            arrDateComponents.year = [[recordarray objectAtIndex:13] integerValue];
            arrDateComponents.hour = [[recordarray objectAtIndex:14] integerValue];
            arrDateComponents.minute= [[recordarray objectAtIndex:15] integerValue];
            dataval.arrDate = [gregorianCalendar dateFromComponents:arrDateComponents];
            depDateComponents.day = [[recordarray objectAtIndex:6] integerValue];
            depDateComponents.month = [[recordarray objectAtIndex:7] integerValue];
            depDateComponents.year = [[recordarray objectAtIndex:8] integerValue];
            depDateComponents.hour = [[recordarray objectAtIndex:9] integerValue];
            depDateComponents.minute= [[recordarray objectAtIndex:10] integerValue];
            //NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            dataval.depDate = [gregorianCalendar dateFromComponents:depDateComponents];
            
            if (dataval.depOdo > 0 && dataval.arrOdo > 0 ) {
                dataval.tripComplete = YES;
            }
            
            
        }
        
    } @catch (NSException *exception) {
        if (exception.name == NSRangeException) {
            NSLog(@"Caught an NSRangeException");
            
        } else {
            NSLog(@"Ignored a %@ exception", exception);
            @throw;
        }
        
        if ([contex hasChanges])
        {
            NSLog(@"Context rollback");
            [contex rollback];
            
        }
        
        success = NO;

        
    } @finally {
        NSLog(@"Executing finally block");
        if ([contex hasChanges])
        {
            BOOL saved = [contex save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            NSLog(@"Context saved");
            [[CoreDataController sharedInstance] saveMasterContext];
        }
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"] && receiptbackuprestore == YES)
        {
            
            NSString *fileid = [[NSUserDefaults standardUserDefaults]objectForKey:@"receiptid"];
            if(fileid.length>0)
            {
                [self restoreReceipt:fileid];
            }
            
            
        }
        else {
            [self showAlert:NSLocalizedString(@"restore_success", @"Restore successful")  message:@"All files were successfully restored"];
            
            AppDelegate *app = [[AppDelegate alloc] init];
            [app removeRecordType0FromService];
            
            NSString *userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
            
            if(userEmail != nil && userEmail.length > 0){
            
                [self performSelectorInBackground:@selector(uploadDataToServer) withObject:nil];
            }
            [self.loadingView removeFromSuperview];
            
        }
        
    }
    commonMethods *common = [[commonMethods alloc] init];
    NSNumber *maxNumber = [common getMaxFuelID];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:maxNumber forKey:@"maxFuelID"];
}

#pragma mark ----SYNC METHODS----

- (void)uploadDataToServer{
    
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    ResyncVC *resync = [[ResyncVC alloc] init];
    [resync fullUpload];
        
    });
}


#pragma mark GID methods


- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations on signed in user here.
    NSString *userId = user.userID;                  // For client-side use only!
    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    NSString *fullName = user.profile.name;
    NSString *givenName = user.profile.givenName;
    NSString *familyName = user.profile.familyName;
    NSString *email = user.profile.email;
    
    NSLog(@"email: %@", email);
    // ...
    
    if (error == nil) {
 
        if ([GIDSignIn sharedInstance].hasPreviousSignIn) {
            [self.service setAuthorizer:user.authentication.fetcherAuthorizer];
           // [self listFiles];
            
            [self isAuthorizedWithAuthentication];
        }
        else
        {
            NSLog(@"NOT AUTHORIZED");
        }
        
        
          }
    else {
        // ...
        NSLog(@"error is %@", error);
    }
}

#pragma mark - Custom alert
-(void)showcustomalert:(NSString *)title :(NSString *)descval :(NSString *)subtitle{
  
    [alertbgview removeFromSuperview];
    alertbgview = [[UIView alloc]init];
    AppDelegate *app = [AppDelegate sharedAppDelegate];
    alertbgview.frame = CGRectMake(0, 0, app.result.width, app.result.height);
    alertbgview.backgroundColor = [UIColor clearColor];
    //alertbgview.alpha = 0.4;
    [self.view insertSubview:alertbgview aboveSubview:self.tableview];
    
    UIView *alertview = [[UIView alloc]init];
    alertview.frame =CGRectMake(alertbgview.frame.size.width/2-alertview.frame.size.width/2, alertbgview.frame.size.height/2-alertview.frame.size.height/2, 250, 150);
    alertview.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [alertview setCenter:self.view.center];
    alertview.alpha = 1;
    alertview.layer.cornerRadius = 5;
    [alertbgview addSubview:alertview];
    
    UILabel *titlelabel = [[UILabel alloc]init];
    titlelabel.frame = CGRectMake(0, 0, alertview.frame.size.width, 30);
    titlelabel.text = title;
    //titlelabel.backgroundColor = [UIColor redColor];
    titlelabel.font = [UIFont boldSystemFontOfSize:16];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.numberOfLines = 0;
    titlelabel.lineBreakMode = NSLineBreakByWordWrapping;
    titlelabel.textColor = [UIColor blackColor];
    [alertview addSubview:titlelabel];
    
    
    UILabel *descr = [[UILabel alloc]init];
    descr.frame = CGRectMake(0, 25, alertview.frame.size.width, 50);
    //descr.backgroundColor = [UIColor greenColor];
    descr.text = descval;
    descr.font = [UIFont systemFontOfSize:14];
    descr.textAlignment = NSTextAlignmentCenter;
    descr.numberOfLines = 0;
    descr.lineBreakMode = NSLineBreakByWordWrapping;
    descr.textColor = [UIColor blackColor];
    [alertview addSubview:descr];
    
    UIButton *checkmark = [[UIButton alloc]init];
    checkmark.frame = CGRectMake(10, 70, 30, 30);
    [checkmark setImage:[UIImage imageNamed:@"uncheck1"] forState:UIControlStateNormal];
    checkmark.selected = NO;
    checkmark.tag=10;
    [checkmark setImage:[UIImage imageNamed:@"check1"] forState:UIControlStateSelected];
    [checkmark addTarget:self action:@selector(checkclick:) forControlEvents:UIControlEventTouchUpInside];
    [alertview addSubview:checkmark];
    
    UILabel *receiptdet = [[UILabel alloc]init];
    receiptdet.frame = CGRectMake(40, 65, 200, 50);
    receiptdet.text = subtitle;
    receiptdet.numberOfLines = 0;
    receiptdet.lineBreakMode = NSLineBreakByWordWrapping;
    receiptdet.textColor = [UIColor blackColor];
    receiptdet.font = [UIFont boldSystemFontOfSize:14];
    receiptdet.textAlignment = NSTextAlignmentCenter;
    [alertview addSubview:receiptdet];
    
    
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [UIColor blackColor];
    line1.frame = CGRectMake(0,alertview.frame.size.height-42 , alertview.frame.size.width, 1);
    [alertview addSubview:line1];
    
    UIButton *continuebutton = [[UIButton alloc]init];
    continuebutton.frame = CGRectMake(0,alertview.frame.size.height-40, alertview.frame.size.width/2, 40);
    [continuebutton setTitle:NSLocalizedString(@"continue", @"Continue") forState:UIControlStateNormal];
    [continuebutton setTitleColor:[self colorFromHexString:@"#146AFA"] forState:UIControlStateNormal];
    [continuebutton addTarget:self action:@selector(continuebuttonclick) forControlEvents:UIControlEventTouchUpInside];
    [alertview addSubview:continuebutton];
    
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [UIColor darkGrayColor];
    line2.frame = CGRectMake(alertview.frame.size.width/2,alertview.frame.size.height-42,1,42);
    [alertview addSubview:line2];
    
    UIButton *cancelbutton = [[UIButton alloc]init];
    cancelbutton.frame = CGRectMake(alertview.frame.size.width/2,alertview.frame.size.height-40, alertview.frame.size.width/2, 40);
    [cancelbutton setTitle:NSLocalizedString(@"cancel", @"Cancel") forState:UIControlStateNormal];
    [cancelbutton setTitleColor:[self colorFromHexString:@"#146AFA"] forState:UIControlStateNormal];
    [cancelbutton addTarget:self action:@selector(cancelbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    [alertview addSubview:cancelbutton];
    
}

-(void)checkclick:(UIButton *)sender{
    
    if(sender.selected == YES){
        sender.selected = NO;
        receiptbackuprestore = NO;
    }
    
    else{
        sender.selected = YES;
        receiptbackuprestore = YES;
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"]){
            [self gopro];
        }
    }
    
}

-(void)cancelbuttonclick{
    
    [alertbgview removeFromSuperview];
}

-(void)continuebuttonclick{
    
    if (receiptbackuprestore == YES){
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"]){
    [self Drivesetting];
        }
//        else {
//            [self gopro];
//        }
    }
    else{
        [self Drivesetting];
    }
    [alertbgview removeFromSuperview];
    
}

-(void)gopro{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"go_pro_btn", @"Go Pro")
                                          message:NSLocalizedString(@"receipts_backup_restore_go_pro", @"The free version allows backing up and restoring of only data. Receipts can be backed up and restored in the Pro version.")
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    //NSString *go_pro_btn = @"Go Pro";
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"go_pro_btn", @"Go Pro")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   GoProViewController *gopro = (GoProViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"gopro"];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       gopro.modalPresentationStyle = UIModalPresentationFullScreen;
                                       [self presentViewController:gopro animated:YES completion:nil];
                                   });

                                   
                                }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"cancel", @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       UIButton *check = [(UIButton*)self.view viewWithTag:10];
                                       check.selected = NO;
                                   }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
