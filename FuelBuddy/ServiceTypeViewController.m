//
//  ServiceTypeViewController.m
//  FuelBuddy
//
//  Created by Surabhi on 16/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "ServiceTypeViewController.h"
#import "ServiceTableViewCell.h"
#import "AppDelegate.h"
#import "Services_Table.h"
#import "EditTasks.h"
#import "GoProViewController.h"
#import "commonMethods.h"
#import "ReminderViewController.h"
#import "JRNLocalNotificationCenter.h"


@interface ServiceTypeViewController ()
{
    NSMutableDictionary* serviceRec;
    NSMutableArray* serviceRecArray;
}
@end

//Swapnil 15 Mar-17
//static GADMasterViewController *shared;
@implementation ServiceTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.checkedarray =[[NSMutableArray alloc]init];
    
    
   
 /*
    [self fetchservice];
    NSArray *Service = [[NSArray alloc]init];
    self.checkedarray = [[NSMutableArray alloc]init];
    Service = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectservice"]mutableCopy];
    
    for(NSString *string in Service)
    {
        if([self.servicearray containsObject:string])
        {
            [self.checkedarray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self.servicearray indexOfObject:string]]];
        }
    }

*/
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    self.tableview.backgroundColor =[self colorFromHexString:@"#2c2c2c"];
    self.tableview.tableFooterView=[UIView new];
   
    //NSString *add_service = @"Add Service";
    self.navigationItem.title=[NSLocalizedString(@"add_service", @"Add service") capitalizedString];
    
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addclick)];
    self.tableview.separatorColor =[UIColor darkGrayColor];
    [self.tableview reloadData];
   
//[[NSUserDefaults standardUserDefaults]setObject:@"no" forKey:@"reloadtext"];
    
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
   /* if([[NSUserDefaults standardUserDefaults]objectForKey:@"selectservice"]!=nil)
    {
        NSArray *service = [[NSArray alloc]init];
        service = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectservice"]mutableCopy];
        
        for(int i=0 ;i <service.count;i++)
        {
            [self.checkedarray addObject:];
        }
    }*/
    [self createPageVC];

    serviceRecArray =[[NSMutableArray alloc]init];
    [self fetchservice];
    NSArray *Service = [[NSArray alloc]init];
    self.checkedarray = [[NSMutableArray alloc]init];
    Service = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectservice"]mutableCopy];
    
    for(NSString *string in Service)
    {
        if([self.servicearray containsObject:string])
        {
            [self.checkedarray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self.servicearray indexOfObject:string]]];
        }
    }
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [self.tableview reloadData];
    
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(void)fetchservice

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
     NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    self.servicearray = [[NSMutableArray alloc]init];
    self.lastservice =[[NSMutableArray alloc]init];
    for(Services_Table *fuelrecord in datavalue)
    {
       // NSLog(@"Veh id--- %@",fuelrecord.vehid);
      //  NSLog(@"Service name--- %@",fuelrecord.serviceName);
       // NSLog(@"*****************************");
        if([fuelrecord.type floatValue]==1)
        {
            serviceRec = [[NSMutableDictionary alloc] init];

            [self.servicearray addObject:fuelrecord.serviceName];
            if(fuelrecord.lastDate!=NULL)
            {
                [self.lastservice addObject:[formatter stringFromDate:fuelrecord.lastDate]];
            }
            else
            {
                [self.lastservice addObject:@""];
            }
            
            [serviceRec setObject:fuelrecord.serviceName forKey:@"ServiceName"];
            [serviceRec setObject:fuelrecord.recurring forKey:@"Recurring"];
            [serviceRec setObject: (fuelrecord.lastOdo != nil? fuelrecord.lastOdo:@"") forKey:@"LastOdo"];
            [serviceRec setObject: (fuelrecord.lastDate != nil? fuelrecord.lastDate:@"") forKey: @"LastServiceDate"];

            
            
            //NSLog(@"serviceRec is %@", serviceRec);
            
            [serviceRecArray addObject:serviceRec];
       
        
        }
        
        
        
        
    }
    //NSLog(@"fuel date %@",self.lastservice);
    //[self.tableview reloadData];
    
    //NSLog(@"Service Array: %@", serviceRecArray);
    
}


-(void)addclick
{

    
   EditTasks *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editTask"];
   
    modalVC.taskType = @"Service";
    modalVC.operation = @"Add";
    
    //NSLog(@"service arr : %@", self.servicearray);
    modalVC.serviceArray = self.servicearray;
    
    //NSLog(@"modalvc serv : %@", modalVC.serviceArray);
    
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



- (void)showAlert:(NSString *)title message:(NSString *)message {
    
    
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

-(void)backbuttonclick
{
    [self.navigationController popViewControllerAnimated:YES];
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


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return self.servicearray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] ;
        
    }
    
    if(tableView==self.tableview)
    {
        ServiceTableViewCell *cell = (ServiceTableViewCell *)[self.tableview dequeueReusableCellWithIdentifier:@"Cell"];
        cell.backgroundColor=[UIColor clearColor];
        cell.namelab.textColor = [UIColor whiteColor];
        cell.namelab.text = [self.servicearray objectAtIndex:indexPath.row];
        cell.checkmark.tag=indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.checkmark setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
        [cell.checkmark setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        if([self.checkedarray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
        {
            //[cell.checkmark setImage:[UIImage imageNamed:@"checkmark01"] forState:UIControlStateNormal];
            //NSLog(@"selected");
            cell.checkmark.selected=YES;
        }
        
        else if(![self.checkedarray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
        {
            
            cell.checkmark.selected=NO;
        }

         cell.lastservice.textColor = [UIColor whiteColor];
//        NSString *tv_last_service = @"Last Service Date:";
//        NSString *not_serviced = @"Not Yet Serviced";
        
        if(![[self.lastservice objectAtIndex:indexPath.row] isEqualToString: @""])
        {

        cell.lastservice.text = [NSString stringWithFormat:@"%@ %@",
                                 NSLocalizedString(@"tv_last_service", @"last service date: ") , [self.lastservice objectAtIndex:indexPath.row]];
        }
        
        else
        {
             cell.lastservice.text = [NSString stringWithFormat:@"%@ %@",
                                      NSLocalizedString(@"tv_last_service", @"Last Service Date: ") ,
                                      NSLocalizedString(@"not_serviced", @"Not Yet Serviced")];
        }
        [cell.checkmark addTarget:self action:@selector(checkclick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  /*
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Update service"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Service Name", @"Service Name");
         textField.text = [self.servicearray objectAtIndex:indexPath.row];
         self.updateservice = textField.text;
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Update", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                                   UITextField *servicename = alertController.textFields.firstObject;
                                       if(servicename.text.length!=0)
                                       {
                                           
                                           [self updateservice:servicename.text];
                                           for(int i=0; i<self.servicearray.count;i++)
                                           {
                                               NSString *string = [self.servicearray objectAtIndex:i];
                                               if([string isEqualToString:self.updateservice])
                                               {
                                                   [self.servicearray replaceObjectAtIndex:i withObject:servicename.text];
                                               }
                                           }
                                           [self.tableview reloadData];
                                       }

                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    */
    
    EditTasks *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editTask"];
    
    modalVC.taskType = @"Service";
    modalVC.operation = @"Edit";
    modalVC.serviceArray = self.servicearray;
    modalVC.updServiceName = [self.servicearray objectAtIndex:indexPath.row];
    modalVC.serviceRec = [serviceRecArray objectAtIndex:indexPath.row];
    
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

-(void)checkclick : (id)sender
{
    
    //NSLog(@"clicked");
    
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableview];
    NSIndexPath *indexPath = [self.tableview indexPathForRowAtPoint:touchPoint];
    
   ServiceTableViewCell *Cell = (ServiceTableViewCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    
    if(Cell.checkmark.selected == YES)
    {
        //[Cell.checkmark setImage:[UIImage imageNamed:@"checkmark02"] forState:UIControlStateNormal];
        //[self.checkedarray addObject:[NSString stringWithFormat:@"%ld",(long)Cell.checkmark.tag]];
        [Cell.checkmark setSelected:NO];
        [self.checkedarray removeObject:[NSString stringWithFormat:@"%ld",(long)Cell.checkmark.tag]];
      
    }
    
    else if(Cell.checkmark.selected == NO)
    {
        
        [Cell.checkmark setSelected:YES];
        //[Cell.checkmark setImage:[UIImage imageNamed:@"checkmark01"] forState:UIControlStateSelected];
      
        [self.checkedarray addObject:[NSString stringWithFormat:@"%ld",(long)Cell.checkmark.tag]];

    }
   // NSLog(@"checked array %@",self.checkedarray);
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.checkedarray forKey:@"checked"];
    [self.tableview reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSMutableArray *Servicearray = [[NSMutableArray alloc]init];
    //NSLog(@"checked array %@",self.checkedarray);
    //NSLog(@"self.serviceArr = %@", self.servicearray);
    
    for(int i = 0; i <self.checkedarray.count;i++)
    {
        int value = [[self.checkedarray objectAtIndex:i]intValue];
        if(value < self.servicearray.count){

            [Servicearray addObject:[self.servicearray objectAtIndex:value]];
        }else{

            [Servicearray addObject:[self.servicearray lastObject]];
        }

    }
   //NSLog(@"service array %@",Servicearray);
    [[NSUserDefaults standardUserDefaults]setObject:Servicearray forKey:@"selectservice"];
    [[NSUserDefaults standardUserDefaults]setObject:self.servicearray forKey:@"servicearray"];
}

-(void)updateservice: (NSString*)servicename
{
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
   // NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
   // NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    [requset setPredicate:predicate];
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    for ( Services_Table *service in datavalue)
    {
        if([service.serviceName isEqualToString:self.updateservice])
        {
            service.serviceName = servicename;
        
            if ([contex hasChanges])
            {
                BOOL saved = [contex save:&err];
                if (!saved) {
                    // do some real error handling
                    //CLSLog(@“Could not save Data due to %@“, error);
                }
               [[CoreDataController sharedInstance] saveMasterContext];
             //  NSLog(@"saved");
            
            }
        }
    }
    
    
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUserDefaults *Def = [NSUserDefaults standardUserDefaults];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSError *err;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==1 OR type==2"];
    [requset setPredicate:predicate];
    NSArray *data=[contex executeFetchRequest:requset error:&err];
    ReminderViewController *rem = [[ReminderViewController alloc] init];
   
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        for (Services_Table *product in data) {
            
            if([product.serviceName isEqualToString:[self.servicearray objectAtIndex:indexPath.row]])
            {
                //Nikhil
                NSString* jrnKey = [[product.serviceName stringByAppendingString:@","] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"vehname"]];

                [[JRNLocalNotificationCenter defaultCenter] cancelLocalNotificationForKey:jrnKey];

                NSString *userEmail = [Def objectForKey:@"UserEmail"];
                
                //If user is signed In, then only do the sync process..
                if(userEmail != nil && userEmail.length > 0){
                    
                    [rem writeToSyncTableWithRowID:product.iD tableName:@"SERVICE_TABLE" andType:@"del"];
                }
                [contex deleteObject:product];
                [[CoreDataController sharedInstance] saveMasterContext];
            }
        }

        NSError *error = nil;
        if (![contex save:&error]) {
          //  NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }

        
         [self.servicearray removeObjectAtIndex:indexPath.row];
        [serviceRecArray removeObjectAtIndex:indexPath.row];
        //Swapnil BUG_88
        NSInteger value = indexPath.row;
        NSString *valueString = [NSString stringWithFormat:@"%ld", (long)value];
        [self.checkedarray removeObject:valueString];
//        if([[self.checkedarray objectAtIndex:0]integerValue] != 0)
//        {
//            // NSLog(@"checked value....%@",self.checkedarray);
//            int check = [[self.checkedarray objectAtIndex:0]integerValue];
//            [self.checkedarray removeAllObjects];
//            [self.checkedarray addObject:[NSString stringWithFormat:@"%d",check-1]];
//        }
        
        // NSLog(@"checked..... %@",self.checkedarray);
        [self.tableview beginUpdates];
        [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableview endUpdates];
    }
    
    
}


//Swapnil 7 Mar-17

- (void)createPageVC{
    
    if(![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceLaunch"]]){
        
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"serviceLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        navigationOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        navigationOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        
        tabbarOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        tabbarOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        
        [self.navigationController.view addSubview:navigationOverlay];
        [self.tabBarController.tabBar addSubview:tabbarOverlay];
        
        //NSString *add_service_task_help = @"Add new Service Tasks";
        
        self.pageTitles1 = @[NSLocalizedString(@"add_service_task_help", @"Add new Service Tasks")];
        self.pageTitles2 = @[@"Click service name to edit. Swipe to delete service name"];
        
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
