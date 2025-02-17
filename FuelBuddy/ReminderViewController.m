//
//  ReminderViewController.m
//  FuelBuddy
//
//  Created by surabhi on 28/04/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "ReminderViewController.h"
#import "ReminderTableViewCell.h"
#import "Services_Table.h"
#import "AppDelegate.h"
#import "T_Fuelcons.h"
#import "Veh_Table.h"
#import "AddReminderViewController.h"
#import "EditTasks.h"
#import "AutorotateNavigation.h"
#import "Reachability.h"
#import "Sync_Table.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import "CheckReachability.h"


@interface ReminderViewController ()

//NIKHIL BUG_131 //added property
@property int selPickerRow;
@property NSMutableArray *sortArray;
@property BOOL hasRun,chooseSortName;
@end

@implementation ReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Swapnil 14 Mar-17
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [self createPageVC];

    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.topItem.title=NSLocalizedString(@"reminders", @"Reminders");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if([def boolForKey:@"fromMainScreen"]){
        
        UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
        UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
        [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
        UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
        [Button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationItem setLeftBarButtonItem:BarButtonItem];
        [def setBool:NO forKey:@"fromMainScreen"];
    }
    
    
    [self.segmentControl addTarget:self action:@selector(selectedsegment) forControlEvents:UIControlEventValueChanged];
    _vehimage.contentMode = UIViewContentModeScaleAspectFill;
    _vehimage.layer.borderWidth=0;
    _vehimage.layer.masksToBounds=YES;
    _vehimage.layer.cornerRadius = self.vehimage.frame.size.width/2;
    
    self.vehname.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {
        // NSLog(@"blank....");
        _vehimage.image=[UIImage imageNamed:@"car4.jpg"];
    }
    
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //Swapnil ENH_24
        NSString *urlstring = [paths firstObject];
        
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
        _vehimage.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
    [self fetchdata];
    [self.vehiclebutton addTarget:self action:@selector(openselectpicker) forControlEvents:UIControlEventTouchUpInside];
    
    [self.dropdownButton addTarget:self action:@selector(openselectpicker) forControlEvents:UIControlEventTouchUpInside];
    self.tableview.tableFooterView = [UIView new];
    self.tableview.separatorColor = [UIColor darkGrayColor];
    
    //NIKHIL ENH_48 added array for sort view
    self.sortNames = [[NSArray alloc] initWithObjects:NSLocalizedString(@"reminder_sort_0", @"Sort by name"),NSLocalizedString(@"reminder_sort_1",@"Sort by due"),nil];
    //NIKHIL BUG_157
     self.sortLabelName.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"sortName"];
     self.sortLabelName.userInteractionEnabled = NO;
    
}

- (IBAction)backButtonPressed: (id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//Swapnil 14 Mar-17
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


-(void)viewDidDisappear:(BOOL)animated
{
    
    
    AppDelegate *App = [AppDelegate sharedAppDelegate];
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

-(void)viewDidAppear:(BOOL)animated {
    
    self.vehname.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"];
    //NIKHIL BUG_157  added sort label and user defaults to store bool value
    self.chooseSortName = [[NSUserDefaults standardUserDefaults]objectForKey:@"chooseSortType"];

      if(!self.chooseSortName){
          self.sortLabelName.text = NSLocalizedString(@"reminder_sort_default",@"Sort type");
      }else{
          self.sortLabelName.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"sortName"];
      }

    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {
        //NSLog(@"blank....");
        _vehimage.image=[UIImage imageNamed:@"car4.jpg"];
    }
    
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //Swapnil ENH_24
        NSString *urlstring = [paths firstObject];
        
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
        _vehimage.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
    [self fetchdata];
    [self selectedsegment];
    [self.tableview reloadData];
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


-(void)selectedsegment {
    if(self.segmentControl.selectedSegmentIndex == 0){
        [self fetchservice:1:1];
        
    }
    else {
        [self fetchservice:2:0];
        
    }
    _hasRun = NO;
}

-(void)backbuttonclick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addClick:(id)sender {
  
    EditTasks *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editTask"];
    
    if(self.segmentControl.selectedSegmentIndex == 0)
    {
        //NSString *view_service = @"Service";
        modalVC.taskType = NSLocalizedString(@"view_service", @"Service");
        modalVC.serviceArray = self.dataArray;
    }
    else
    {
        //NSString *view_expense = @"Expense";
        modalVC.taskType = NSLocalizedString(@"view_expense", @"Expense");
        modalVC.expenseArray = self.dataArray;
    }
    modalVC.operation = @"Add";
    
   //NSLog(@"self.dataArray : %@", self.dataArray);
    
    
    // 2. Your code after the modal view dismisses
    modalVC.onDismiss = ^(UIViewController *sender, NSString* message)
    {
        // Do your stuff after dismissing the modal view controller
       // NSLog(@"Modal dissmissed");
        
        if (message.length > 0) {
            [self showAlert:message message:@""];
            
        }
        
        [self viewDidAppear:YES];
    };
    
    modalVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:modalVC animated:YES completion:nil];
  
}

- (IBAction)sortType:(UIButton *)sender {
    [self sortTypePicker];
}

- (IBAction)sortTypeButton:(UIButton *)sender {
    
    [self sortTypePicker];
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

//NIKHIL ENH_48
-(void)progressValue{
    
    _hasRun = YES;
    self.sortArray = [[NSMutableArray alloc]init];
    for (int i=0;i<_dataArray.count;i++){
        
        NSMutableDictionary *sortdict = [[NSMutableDictionary alloc] init];
        
        sortdict = [_dataArray objectAtIndex:i];
        NSDateFormatter *formater=[[NSDateFormatter alloc] init];
        [formater setDateFormat:@"dd-MMM-yyyy"];
        [formater setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
        NSDate *lastdate = [formater dateFromString:[sortdict objectForKey:@"lastdate"]];
        float lastMilesInt= [[sortdict objectForKey:@"lastodo"]integerValue];
        NSInteger dueDays =[[sortdict objectForKey:@"duedays"] integerValue];
        float dueMiles = [[sortdict objectForKey:@"duemiles"]integerValue];
        
        //for ProgressBar
        float y = 0.000f;
        float z = 0.000f;
        if (dueMiles > 0 || dueDays > 0 ) {
            
            float diffToday = maxodo -lastMilesInt;
            //float diffMiles = dueMiles - lastMilesInt;
            
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                                fromDate:lastdate
                                                                  toDate:[NSDate date]
                                                                 options:NSCalendarWrapComponents];
            
            NSInteger diffDay = [components day];
            //float progressDay = (float) diffDay/dueDays ;
            float progressDay = dueDays > 0 ? (float) diffDay/dueDays : 0;
            float progressMiles = dueMiles > 0 ? (float) diffToday/dueMiles : 0;
            
            y = progressDay > progressMiles ? progressDay : progressMiles;
            
            //NSLog(@"Value of y is:::%f",y);
        
            [sortdict setObject:[NSNumber numberWithFloat:y] forKey:@"progress"];
            [self.sortArray addObject:sortdict];
        }else{
            [sortdict setObject:[NSNumber numberWithFloat:z] forKey:@"progress"];
            [self.sortArray addObject:sortdict];
        }
    }
    //NSLog(@"Progess added array:::%@",self.sortArray);
}


#pragma mark - Tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    NSUserDefaults *sortKey = [NSUserDefaults standardUserDefaults];
    ReminderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[ReminderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] ;
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //NIKHIL ENH_48 check the sort type
    if([sortKey integerForKey:@"sortKey"] == 1){
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        [_dataArray sortUsingDescriptors:@[sort]];
   
    }else if([sortKey integerForKey:@"sortKey"] == 2){
        
        if(!_hasRun){
        [self progressValue];
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray: _sortArray];
        [self.dataArray sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"progress" ascending:NO], nil]];
        //NSLog(@"Sorted dataArray%@",_dataArray);
        }
    }
    
    
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.NameLabel.text = [dictionary objectForKey:@"name"];
    NSInteger recurring = [[dictionary objectForKey:@"recurring"]integerValue];
    
//    //Disable add reminders for non-recurring events
    if (recurring == 0) {

        cell.LastDate.text = @"Non-recurring"; //Localize

    }
    else
    {

        //Should be auto filled lets check

    }
    cell.NameLabel.textColor = [UIColor whiteColor];
    cell.LastDate.textColor = [UIColor whiteColor];
    cell.DueOdo.textColor = [UIColor whiteColor];
    
    cell.progressbar.hidden=YES;
    NSString *unit;
  
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    [formater setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
    NSDate *lastdate = [formater dateFromString:[dictionary objectForKey:@"lastdate"]];
    float lastMilesInt= [[dictionary objectForKey:@"lastodo"]integerValue];
    NSInteger dueDays =[[dictionary objectForKey:@"duedays"] integerValue];
    float dueMiles = [[dictionary objectForKey:@"duemiles"]integerValue];
    NSDate* dueDate  = [lastdate dateByAddingTimeInterval:(24*3600)*dueDays];
    
    //for ProgressBar
    float y = 0;
    if (dueMiles > 0 || dueDays > 0 ) {
        
        float diffToday = maxodo -lastMilesInt;
        //float diffMiles = dueMiles - lastMilesInt;
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:lastdate
                                                              toDate:[NSDate date]
                                                             options:NSCalendarWrapComponents];

        NSInteger diffDay = [components day];
        float progressDay = dueDays > 0 ? (float) diffDay/dueDays : 0;
        float progressMiles = dueMiles > 0 ? (float) diffToday/dueMiles : 0;
        
        y = progressDay > progressMiles ? progressDay : progressMiles;
        cell.progressbar.progress = y;
        cell.progressbar.hidden=NO;

    }
    
    if (y >= 1) {
        cell.progressbar.progressTintColor = [UIColor redColor];
    }
    else
        cell.progressbar.progressTintColor = [self colorFromHexString:@"#FFCC00"];
    
    
    
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        unit = NSLocalizedString(@"mi", @"mi");
    }
    
    else
    {
        unit = NSLocalizedString(@"kms", @"km");
    }

    if([[dictionary objectForKey:@"duemiles"]integerValue]!=0 ){
        
        
  if([dictionary objectForKey:@"lastdate"]!=[NSNull null] && [dictionary objectForKey:@"lastdate"]!=NULL && [[dictionary objectForKey:@"lastdate"] length]!=0) {
    
      
      
      cell.LastDate.text = [NSString stringWithFormat:@"%@ %@",
                            NSLocalizedString(@"last_service", @"Last Service: "), [dictionary objectForKey:@"lastdate"]];
      
      
    }
    else {
       cell.LastDate.text = [NSString stringWithFormat:@"%@ %@",
                             NSLocalizedString(@"last_service", @"Last Service:"), NSLocalizedString(@"not_applicable", @"n/a")];
    }
        
        if ([[dictionary objectForKey:@"duedays"] longValue]!=0 && [[[dictionary objectForKey:@"duemiles"]stringValue]length]!=0) {
            
            if([[dictionary objectForKey:@"lastodo"]integerValue]==0 ) {
                cell.LastDate.text = [NSString stringWithFormat:@"%@ %d %@/%@",  NSLocalizedString(@"last_service", @"Last Service: "), (int)maxodo,unit,[dictionary objectForKey:@"lastdate"]];

                if(recurring == 0){

                    if([dictionary objectForKey:@"lastdate"]!=[NSNull null] && [dictionary objectForKey:@"lastdate"]!=NULL && [[dictionary objectForKey:@"lastdate"] length]!=0) {
                        cell.LastDate.text = [NSString stringWithFormat:@"%@ %@",
                                              NSLocalizedString(@"last_service", @"Last Service: ") ,[dictionary objectForKey:@"lastdate"]];
                        if([[dictionary objectForKey:@"duedays"]longValue]!=0){
                            NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                            [formater setDateFormat:@"dd-MMM-yyyy"];
                            [formater setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
                            NSDate *date = [formater dateFromString:[dictionary objectForKey:@"lastdate"]];
                            NSDate *duedate = [date dateByAddingTimeInterval:(60*60*24*[[dictionary objectForKey:@"duedays"]longValue])];

                            NSString *dateString = [[formater stringFromDate:duedate] substringToIndex:6];
                            cell.DueOdo.text = [NSString stringWithFormat:@"%@ %ld %@/%@", NSLocalizedString(@"due_on", @"Due on"),[[dictionary objectForKey:@"duemiles"]integerValue] + (int)maxodo,unit,dateString];

                           // cell.DueOdo.text = [NSString stringWithFormat:@"%@ %@",
                           //                     NSLocalizedString(@"due_on", @"Due: "),[formater stringFromDate:duedate]];
                        }

                    }
                }else{

                    cell.DueOdo.text = [NSString stringWithFormat:@"%@ %ld %@/%@", NSLocalizedString(@"due_on", @"Due on"),[[dictionary objectForKey:@"duemiles"]integerValue] + (int)maxodo,unit,[dictionary objectForKey:@"duedays"]];
                }
            }
            
            else {
                cell.LastDate.text = [NSString stringWithFormat:@"Last Service: %ld %@",[[dictionary objectForKey:@"lastodo"]integerValue],unit];
                
                [formater setDateFormat:@"dd-MMM"];
                NSString *dateString = [formater stringFromDate:dueDate];
                
                cell.DueOdo.text = [NSString stringWithFormat:@"%@ %ld %@/%@",  NSLocalizedString(@"due_on", @"Due on") , [[dictionary objectForKey:@"duemiles"]integerValue] + [[dictionary objectForKey:@"lastodo"]integerValue],unit,dateString];
                
            }
            
            
            
        }

    
   else if([[[dictionary objectForKey:@"duemiles"]stringValue]length]!=0 ||[[[dictionary objectForKey:@"lastodo"]stringValue]length]!=0){

        if([[dictionary objectForKey:@"lastodo"]integerValue]==0 ) {
            cell.LastDate.text = [NSString stringWithFormat:@"%@ %d %@",
                                  NSLocalizedString(@"last_service", @"Last Service: "),(int)maxodo,unit];
        }
        
        else {
            cell.LastDate.text = [NSString stringWithFormat:@"%@ %ld %@",
                                  NSLocalizedString(@"last_service", @"Last Service"), [[dictionary objectForKey:@"lastodo"]integerValue],unit];
        }
     
       
 
       cell.DueOdo.text = [NSString stringWithFormat:@"%@ %ld %@",
                           NSLocalizedString(@"due_on", @"Due: "),[[dictionary objectForKey:@"duemiles"]integerValue] + [[dictionary objectForKey:@"lastodo"]integerValue],unit];
        
        
        if([[dictionary objectForKey:@"duemiles"]floatValue]!=0 && maxodo!=0) {
            cell.progressbar.hidden=NO;
        }
        
            }
    else {
    cell.DueOdo.text = [NSString stringWithFormat:@"%@ %@",
                        NSLocalizedString(@"due_on", @"Due: ") ,
                        NSLocalizedString(@"not_applicable", @"n/a")];
    }
    }
    else if ([[dictionary objectForKey:@"duedays"] longValue]!=0){
        
        //NSString *last_service = @"Last Service:";
        //NSString *due_on = @"Due:";
       // NSString *not_applicable = @"n/a";
        
        if([dictionary objectForKey:@"lastdate"]!=[NSNull null] && [dictionary objectForKey:@"lastdate"]!=NULL && [[dictionary objectForKey:@"lastdate"] length]!=0) {
            cell.LastDate.text = [NSString stringWithFormat:@"%@ %@",
                                  NSLocalizedString(@"last_service", @"Last Service: ") ,[dictionary objectForKey:@"lastdate"]];
            if([[dictionary objectForKey:@"duedays"]longValue]!=0){
                NSDateFormatter *formater=[[NSDateFormatter alloc] init];
                [formater setDateFormat:@"dd-MMM-yyyy"];
                [formater setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
                NSDate *date = [formater dateFromString:[dictionary objectForKey:@"lastdate"]];
                NSDate *duedate = [date dateByAddingTimeInterval:(60*60*24*[[dictionary objectForKey:@"duedays"]longValue])];
                cell.DueOdo.text = [NSString stringWithFormat:@"%@ %@",
                                    NSLocalizedString(@"due_on", @"Due: "),[formater stringFromDate:duedate]];
            }

        }
        
    }
    
        else {
            
        cell.LastDate.text = [NSString stringWithFormat:@"%@ %@",
                              NSLocalizedString(@"last_service", @"Last Service: ") ,
                              NSLocalizedString(@"not_applicable", "n/a")];
        cell.DueOdo.text = [NSString stringWithFormat:@"%@ %@",
                            NSLocalizedString(@"due_on", @"Due: ") ,
                            NSLocalizedString(@"not_applicable", @"n/a")];
    }

    if (recurring == 0) {

        cell.LastDate.text = @"Non-recurring"; //Localize

    }
   
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.dataArray objectAtIndex:indexPath.row];
    NSInteger recurring = [[dictionary objectForKey:@"recurring"]integerValue];

    NSString *message = [NSString stringWithFormat:@"Since %@ is a non-recurring task, you can only set a one time reminder for it.\n\nYou can make the task recurring by editing the task.(You can edit the task by swiping it to left)",[dictionary objectForKey:@"name"]];

    NSUserDefaults *Def = [NSUserDefaults standardUserDefaults];

    if (recurring == 0) {

        bool messageShown = [Def boolForKey:@"OneTimeMessageShown"];

        if(messageShown){
            
            AddReminderViewController *reminder = (AddReminderViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"addreminder"];
            NSDictionary *dictionary = [[NSDictionary alloc]init];
            dictionary = [self.dataArray objectAtIndex:indexPath.row];
            //NSLog(@"Reminder dictionary %@", dictionary);
            reminder.servicedetails = [[NSDictionary alloc]initWithDictionary:dictionary];
            //NSLog(@"data array %@",reminder.servicedetails);
            reminder.namestring = [dictionary objectForKey:@"name"];
            reminder.recurring = false;
            reminder.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navigationController pushViewController:reminder animated:YES];

        }else{

            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@""
                                                  message:message
                                                  preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"ok", @"OK action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {

                AddReminderViewController *reminder = (AddReminderViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"addreminder"];
                NSDictionary *dictionary = [[NSDictionary alloc]init];
                dictionary = [self.dataArray objectAtIndex:indexPath.row];
                //NSLog(@"Reminder dictionary %@", dictionary);
                reminder.servicedetails = [[NSDictionary alloc]initWithDictionary:dictionary];
                //NSLog(@"data array %@",reminder.servicedetails);
                reminder.namestring = [dictionary objectForKey:@"name"];
                reminder.recurring = false;
                [Def setBool:true forKey:@"OneTimeMessageShown"];
                reminder.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController pushViewController:reminder animated:YES];
            }];

            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];

        }
    }
    else
    {

        AddReminderViewController *reminder = (AddReminderViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"addreminder"];
        NSDictionary *dictionary = [[NSDictionary alloc]init];
        dictionary = [self.dataArray objectAtIndex:indexPath.row];
        // NSLog(@"Reminder dictionary %@", dictionary);
        reminder.servicedetails = [[NSDictionary alloc]initWithDictionary:dictionary];
        // NSLog(@"data array %@",reminder.servicedetails);
        reminder.namestring = [dictionary objectForKey:@"name"];
        reminder.recurring = true;
        reminder.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:reminder animated:YES];
    }


}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"delete", @"Delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        //NSLog(@"Delete Button Clicked");
                                        NSUserDefaults *Def = [NSUserDefaults standardUserDefaults];
                                        NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
                                        NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
                                        NSError *err;
                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
                                        [requset setPredicate:predicate];
                                        
                                        NSArray *data=[contex executeFetchRequest:requset error:&err];
                                        
                                        NSDictionary *dictionary = [[NSDictionary alloc]init];
                                        dictionary = [self.dataArray objectAtIndex:indexPath.row];

                                            for (Services_Table *product in data) {
                                                
                                                if([product.serviceName isEqualToString:[dictionary objectForKey:@"name"]])
                                                {
                                                    
                                                    //Swapnil NEW_6
                                                    NSString *userEmail = [Def objectForKey:@"UserEmail"];
                                                    
                                                    //If user is signed In, then only do the sync process..
                                                    if(userEmail != nil && userEmail.length > 0){
                                                    
                                                        [self writeToSyncTableWithRowID:product.iD tableName:@"SERVICE_TABLE" andType:@"del"];
                                                    }
                                                    [contex deleteObject:product];
                                                    //Cancel all notifications related to this service
                                                    [[CoreDataController sharedInstance] saveMasterContext];
                                                    AppDelegate *app=(AppDelegate*)[UIApplication sharedApplication].delegate;
                                                    
                                                    [app expireOldNotifications];
                                                
                                                
                                                }
                                                
                                            }
                                                    
                                            NSError *error = nil;
                                            if (![contex save:&error]) {
                                               // NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                                                return;
                                            }
                                            
                                            
                                          //  [self.servicearray removeObjectAtIndex:indexPath.row];
                                            [self.dataArray removeObjectAtIndex:indexPath.row];
                                                
                                            [self.tableview beginUpdates];
                                            [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                            [self.tableview endUpdates];


                                    }];
    button.backgroundColor = [self colorFromHexString:@"#C65E5E"];
    UITableViewRowAction *button1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"edit", @"Edit") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {
                                         
                                     NSMutableDictionary* serviceRec = [[NSMutableDictionary alloc] init];
                                         
                                         NSDictionary *dictionary = [[NSDictionary alloc]init];
                                         dictionary = [self.dataArray objectAtIndex:indexPath.row];
//                                         NSLog(@"dataArr : %@", self.dataArray);
//                                         NSLog(@"dict : %@", dictionary);

                                         [serviceRec setObject:[dictionary objectForKey:@"name"] forKey:@"ServiceName"];
                                         [serviceRec setObject:[dictionary objectForKey:@"recurring"] forKey:@"Recurring"];
                                         [serviceRec setObject: [dictionary objectForKey:@"lastodo"] forKey:@"LastOdo"];
                                         [serviceRec setObject: [dictionary objectForKey:@"lastdate"] forKey: @"LastServiceDate"];
                                         [serviceRec setObject: [dictionary objectForKey:@"id"] forKey: @"id"];
                                         
                                         // NSLog(@"serviceRec is %@", serviceRec);
                                         
                                         
                                         EditTasks *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editTask"];
                                         
                                        
                                         if(self.segmentControl.selectedSegmentIndex == 0)
                                         {
                                             
                                             //NSString *view_service = @"Service";
                                             modalVC.taskType = NSLocalizedString(@"view_service", @"Service");
                                         }
                                         else
                                         {
                                            //NSString *view_expense = @"Expense";
                                             modalVC.taskType = NSLocalizedString(@"view_expense", @"Expense");
                                         }
                                         
                                         modalVC.operation = @"Edit";
                                         //modalVC.serviceArray = self.servicearray;
                                         //modalVC.updServiceName = [self.servicearray objectAtIndex:indexPath.row];
                                         modalVC.serviceRec = serviceRec;
                                         
                                         // 2. Your code after the modal view dismisses
                                         modalVC.onDismiss = ^(UIViewController *sender, NSString* message)
                                         {
                                             // Do your stuff after dismissing the modal view controller
                                            // NSLog(@"Modal dissmissed");
                                             
                                             if (message.length > 0) {
                                                 [self showAlert:message message:@""];
                                                 
                                             }
                                             
                                             [self viewDidAppear:YES];
                                         };
                                         
                                         modalVC.modalPresentationStyle = UIModalPresentationFullScreen;
                                         [self presentViewController:modalVC animated:YES completion:nil];
                                         
                                         
                                       // NSLog(@"Edit Button Clicked");
                                         
                                     }];
    button1.backgroundColor = [self colorFromHexString:@"#FFC107"];
    
    return @[button, button1];
}


#pragma mark- Custom Methods

-(void)fetchservice:(int)recordtype :(int)recurring

{
    //NSLog(@"called service-----");
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND (type==1 OR type==2)",comparestring];

    [requset setPredicate:predicate];
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd-MMM-yyyy"];
    [formater setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
    
    NSFetchRequest *requset1=[[NSFetchRequest alloc] initWithEntityName:@"T_Fuelcons"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"vehid==%@",comparestring];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"odo"
                                                                   ascending:NO];
    NSArray *sortDescriptors1 = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [requset1 setPredicate:predicate1];
    [requset1 setSortDescriptors:sortDescriptors1];
    
    
    NSArray *datavalue1=[[NSArray alloc]init];
    datavalue1 = [contex executeFetchRequest:requset1 error:&err];
   // NSLog(@"data %lu",(unsigned long)datavalue1.count);
     self.dataArray = [[NSMutableArray alloc]init];
    //NSLog(@"count %lu",(unsigned long)datavalue1.count);
    T_Fuelcons *fuelrecord1 = [datavalue1 firstObject] ;
    
    maxodo = [fuelrecord1.odo floatValue];
    //NSLog(@"maxOdo:::%f",maxodo);
    NSMutableArray *serviceArray = [[NSMutableArray alloc]init];
    for(Services_Table *fuelrecord in datavalue)
    {
        if([fuelrecord.type floatValue]==recordtype)
        {
          //  NSLog(@"fuelrecord.lastDate: %@", fuelrecord.lastDate);
           // if([fuelrecord.recurring integerValue] == recurring){
               
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                [dictionary setValue:fuelrecord.vehid forKey:@"vehid"];
                if([formater stringFromDate:fuelrecord.lastDate].length!=0) {
                [dictionary setValue:[formater stringFromDate:fuelrecord.lastDate] forKey:@"lastdate"];
                NSLog(@"Common methods line number 796 %@",[dictionary objectForKey:@"lastdate"]);
                }
            
                else {
                   [dictionary setValue:[formater stringFromDate:fuelrecord1.stringDate] forKey:@"lastdate"];
                }
            
            //Swapnil BUG_94
            if([dictionary valueForKey:@"lastdate"] == nil){
                [dictionary setValue:@"n/a" forKey:@"lastdate"];
            }
                NSLog(@"ReminderViewController line number 807 : %@", [dictionary valueForKey:@"lastdate"]);
                [dictionary setValue:fuelrecord.serviceName forKey:@"name"];
                [dictionary setValue:fuelrecord.recurring  forKey:@"recurring"];
                [dictionary setValue:fuelrecord.type forKey:@"type"];
                [dictionary setValue:[NSString stringWithFormat:@"%.2f",maxodo] forKey:@"maxodo"];
                [dictionary setValue:fuelrecord.dueDays forKey:@"duedays"];
                [dictionary setValue:fuelrecord.dueMiles forKey:@"duemiles"];
            
            //Swapnil BUG_94
            if(fuelrecord.lastOdo != nil){
                [dictionary setValue:fuelrecord.lastOdo forKey:@"lastodo"];
            } else {
                [dictionary setValue:@0 forKey:@"lastodo"];
            }
            
                [dictionary setValue:fuelrecord.objectID forKey:@"id"];
            
            
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"serviceType CONTAINS[cd] %@", fuelrecord.serviceName];
            //NSLog(@"Predicate is: %@", pred);
                //NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY servicetype CONTAINS[c] %@", fuelrecord.serviceName];
            [requset1 setPredicate:pred];
            
            NSError *error = nil;
            NSUInteger count = [contex countForFetchRequest:requset1 error:&error];

            if (count > 0) {
                [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"serviceExists"];
            }
            else
                [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"serviceExists"];
            
            
                [serviceArray addObject:dictionary];
           // }
            }
    }

    NSLog(@"serviceArray is: %@", serviceArray);
    [self.dataArray addObjectsFromArray:serviceArray];

    [self.tableview reloadData];
    
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
    [_picker removeFromSuperview];
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
    
    
    [self.view addSubview:_picker];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    //button.titleLabel.text = @"Set" ;
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //_setbutton.layer.cornerRadius = 5;
    [_setbutton addTarget:self action:@selector(donelabel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];
    
    
}

//NIKHIL ENH_48
- (void)sortTypePicker {
    [_sortPicker removeFromSuperview];
    _sortPicker = [[UIPickerView alloc]init];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    _sortPicker.frame = CGRectMake(App.result.width/2-130,App.result.height/2-220, 260, 270);
    _sortPicker.backgroundColor=[UIColor grayColor];
    
    _sortPicker.clipsToBounds=YES;
    _sortPicker.delegate =self;
    _sortPicker.dataSource=self;
    _sortPicker.tag=-9;
    
    //NIKHIL BUG_131 //added below line
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    int picRowId = (int)[setRowValue integerForKey:@"rowValue"];
    [_sortPicker selectRow:picRowId inComponent:0 animated:NO];
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_sortPicker.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.frame;
    maskLayer.path = maskPath.CGPath;
    _sortPicker.layer.mask = maskLayer;
    
    
    [self.view addSubview:_sortPicker];
    _setbutton =[[UIButton alloc]init];
    _setbutton.frame = CGRectMake(App.result.width/2-130,(App.result.height/2-220)+270, 260, 40);
    //button.titleLabel.text = @"Set" ;
    [_setbutton setBackgroundColor:[UIColor lightGrayColor]];
    [_setbutton setTitle:NSLocalizedString(@"set", @"Set") forState:UIControlStateNormal];
    [_setbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //_setbutton.layer.cornerRadius = 5;
    [_setbutton addTarget:self action:@selector(doneSortlabel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setbutton];
    
    
}

//NIKHIL ENH_48
-(void)doneSortlabel
{
    //NSLog(@"DATA ARRAY :::%@",_dataArray);
    [self.sortPicker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    NSUserDefaults *sortKey = [NSUserDefaults standardUserDefaults];
    
    
    if([[self.sortNames objectAtIndex:[self.sortPicker selectedRowInComponent:0]] isEqualToString:NSLocalizedString(@"reminder_sort_0", @"Sort by name")])
    {
        //ENH_48 sort alphabatically wise
        [sortKey setInteger:1 forKey:@"sortKey"];
        [self.tableview reloadData];
        //NIKHIL BUG_157
        self.sortLabelName.text = NSLocalizedString(@"reminder_sort_0", @"Sort by name");
        [sortKey setObject:NSLocalizedString(@"reminder_sort_0", @"Sort by name") forKey:@"sortName"];
        [sortKey setBool:YES forKey:@"chooseSortType"];
        self.chooseSortName = YES;
    }
    else
    {
        //NIKHIL ENH_48 Sorted with progressBar percentage
        _hasRun = NO;
        [sortKey setInteger:2 forKey:@"sortKey"];
        [self.tableview reloadData];
        //NIKHIL BUG_157
        self.sortLabelName.text = NSLocalizedString(@"reminder_sort_1",@"Sort by due");
        [sortKey setObject:NSLocalizedString(@"reminder_sort_1",@"Sort by due") forKey:@"sortName"];
        [sortKey setBool:YES forKey:@"chooseSortType"];
        self.chooseSortName = YES;
    }
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
    else if(pickerView.tag==-9)
    {
        return _sortNames.count;
    }else
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
    else if(pickerView.tag==-9)
    {
       
        return [_sortNames objectAtIndex:row];
      
    }else
        
        return 0;
}

//NIKHIL BUG_131 added below method
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    _selPickerRow = (int)[pickerView selectedRowInComponent:0];
    NSUserDefaults *setRowValue = [NSUserDefaults standardUserDefaults];
    [setRowValue setInteger:_selPickerRow forKey:@"rowValue"];
}

-(void)donelabel
{
    [self.picker removeFromSuperview];
    [self.setbutton removeFromSuperview];
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.vehiclearray objectAtIndex:[self.picker selectedRowInComponent:0]];
    // NSLog(@"id value for vehid %@",[dictionary objectForKey:@"Id"]);
    [[NSUserDefaults standardUserDefaults]setObject:[dictionary objectForKey:@"Id"] forKey:@"fillupid"];
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"fillupmake"];
    [def setObject:[def objectForKey:@"fillupid"] forKey:@"oldFillupid"];

    self.vehname.text = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]];
    
    [def setObject:[dictionary objectForKey:@"Id"] forKey:@"idvalue"];
    [def setObject:[NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"Make"],[dictionary objectForKey:@"Model"]] forKey:@"vehname"];
    [def setObject:[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"Id"]] forKey:@"fillupid"];
    [def setObject:[dictionary objectForKey:@"Picture"] forKey:@"vehimage"];
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]isEqualToString:@""])
    {
        // NSLog(@"blank....");
        _vehimage.image=[UIImage imageNamed:@"car4.jpg"];
    }
    
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //Swapnil ENH_24
        NSString *urlstring = [paths firstObject];
        
        NSString *vehiclepic = [NSString stringWithFormat:@"%@/%@",urlstring,[[NSUserDefaults standardUserDefaults]objectForKey:@"vehimage"]];
        _vehimage.image =[UIImage imageWithContentsOfFile:vehiclepic];
    }
    if(self.segmentControl.selectedSegmentIndex==0){
        [self fetchservice:1 :1];
    }
    else{
        [self fetchservice:2 :0];
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

//Swapnil 7 Mar-17

- (void)createPageVC{
    
    if(![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"reminderLaunch"]]){
        
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"reminderLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        navigationOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        navigationOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        
        tabbarOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        tabbarOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        
        [self.navigationController.view addSubview:navigationOverlay];
        [self.tabBarController.tabBar addSubview:tabbarOverlay];

        //NSString *add_service_task_help = @"Add new Service Tasks";
        
        self.pageTitles1 = @[NSLocalizedString(@"add_service_task_help", @"Add new Service Tasks")];
        self.pageTitles2 = @[@"Click Service Task to add/update Reminder. Swipe to edit/delete a service name"];
        
        self.imagesArray1 = @[@"help_arrow2.png"];
        self.imagesArray2 = @[@"arrowleft.png"];

        //Create page view controller
        
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReminderPageViewController"];
        self.pageViewController.dataSource = self;
        ReminderPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
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
    
    NSUInteger index = ((ReminderPageContentViewController *) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound)){
        
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    NSUInteger index = ((ReminderPageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound){
        return nil;
    }
    
    index++;
    
    if (index == [self.pageTitles1 count]){
        
        return nil;
    }
    
    
    return [self viewControllerAtIndex:index];
}

- (void)dissmissAction{
    
    [self.pageViewController.view removeFromSuperview];
    [self.pageViewController removeFromParentViewController];
    [navigationOverlay removeFromSuperview];
    [tabbarOverlay removeFromSuperview];
}

-(ReminderPageContentViewController *)viewControllerAtIndex:(NSUInteger)index{
    
    if (([self.pageTitles1 count] == 0) || (index >= [self.pageTitles1 count])) {
        
        
        return nil;
    }
    
    ReminderPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReminderPageContentViewController"];
    pageContentViewController.labelText1 = self.pageTitles1[index];
    pageContentViewController.labelText2 = self.pageTitles2[index];
    pageContentViewController.imageText1 = self.imagesArray1[index];
    pageContentViewController.imageText2 = self.imagesArray2[index];

    pageContentViewController.pageIndex = index;
    return pageContentViewController;
    
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    
    return 0;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    
    return 0;
}

#pragma mark CLOUD SYNC METHODS

//Swapnil NEW_6

//Save rowID, tableName, and type in phones Sync table
- (void)writeToSyncTableWithRowID: (NSNumber *)rowID tableName: (NSString *)tableName andType: (NSString *)type{

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    Sync_Table *syncData = [NSEntityDescription insertNewObjectForEntityForName:@"Sync_Table" inManagedObjectContext:context];
    
    syncData.rowID = rowID;
    syncData.tableName = tableName;
    syncData.type = type;
    syncData.processing = @0;
    
    if([context hasChanges]){
        
        BOOL saved = [context save:&err];
        if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
        }
       
        [[CoreDataController sharedInstance] saveMasterContext];
        //Upload data from common methods
        commonMethods *common = [[commonMethods alloc] init];
        [common checkNetworkForCloudStorage:@"isReminder"];
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tableName == 'SERVICE_TABLE'"];
    
    [request setPredicate:predicate];
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

            [self setType:type andRowID:syncData.rowID andTableName:syncData.tableName];
        }
    }
}

//Loop thr' the specified tableName and delete record for specified rowID
- (void)setType: (NSString *)type andRowID: (NSNumber *)rowID andTableName: (NSString *)tableName{
    
    NSError *err;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if(rowID != nil){
        [dictionary setObject:rowID forKey:@"_id"];
    } else {
        [dictionary setObject:@"" forKey:@"_id"];
    }
    
    if(type != nil){
        [dictionary setObject:type forKey:@"type"];
    } else {
        [dictionary setObject:@"" forKey:@"type"];
    }
    
    [dictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email"];
    [dictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];
    [dictionary setObject:@"phone" forKey:@"source"];
    
    commonMethods *common = [[commonMethods alloc] init];
   // NSLog(@"service val : %@", dictionary);
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    [def setBool:YES forKey:@"updateTimeStamp"];
    //Pass parameters dictionary and URL of script to get response
    [common saveToCloud:postData urlString:kServiceDataScript success:^(NSDictionary *responseDict) {
      //  NSLog(@"Service responseDict : %@", responseDict);
        
        if([[responseDict objectForKey:@"message"] isEqualToString:@"Success"]){
            
            [common clearPhoneSyncTableWithID:rowID tableName:tableName andType:type];
            
        }
    } failure:^(NSError *error) {
      //  NSLog(@"%@", error.localizedDescription);
    }];
    
}


@end
