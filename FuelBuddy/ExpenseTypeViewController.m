//
//  ExpenseTypeViewController.m
//  FuelBuddy
//
//  Created by Surabhi on 21/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "ExpenseTypeViewController.h"
#import "ServiceTableViewCell.h"
#import "AppDelegate.h"
#import "Services_Table.h"
#import "EditTasks.h"
#import "GoProViewController.h"
#import "ReminderViewController.h"


@interface ExpenseTypeViewController ()
{
    NSMutableArray* expenseRecArray;
}

@end

//Swapnil 15 Mar-17
//static GADMasterViewController *shared;
@implementation ExpenseTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
 /*
    [self fetchservice];
    NSArray *Service = [[NSArray alloc]init];
    self.checkedarray = [[NSMutableArray alloc]init];
    Service = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectexpense"]mutableCopy];
    //NSLog(@"expense array %@",self.expensearray);
    for(NSString *string in Service)
    {
        if([self.expensearray containsObject:string])
        {
            [self.checkedarray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self.expensearray indexOfObject:string]]];
        }
    }
*/
    //NSLog(@"expense array %@",self.expensearray);
    //self.expensearray = [[NSMutableArray alloc]init];
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    self.tableview.backgroundColor =[self colorFromHexString:@"#2c2c2c"];
    self.tableview.tableFooterView=[UIView new];
    
    //self.checkedarray = [[NSMutableArray alloc]init];
    //NSString *add_expenses = @"Add Expenses";
    self.navigationItem.title=[NSLocalizedString(@"add_expenses", @"add expenses") capitalizedString];
    
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
    //NSLog(@"expense array %@",self.expensearray);
    //[[NSUserDefaults standardUserDefaults]setObject:@"no" forKey:@"reloadtext"];
}


-(void)viewDidAppear:(BOOL)animated
{
    expenseRecArray = [[NSMutableArray alloc] init];
    [self fetchservice];
    
    NSArray *Service = [[NSArray alloc]init];
    self.checkedarray = [[NSMutableArray alloc]init];
    Service = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectexpense"]mutableCopy];
    //NSLog(@"expense array %@",self.expensearray);
    for(NSString *string in Service)
    {
        if([self.expensearray containsObject:string])
        {
            [self.checkedarray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self.expensearray indexOfObject:string]]];
        }
    }

    //NSLog(@"expense table : %@", self.tableview);
    [self.tableview reloadData];

    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
   
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
    //NSLog(@"comapre string %@",comparestring);
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid==%@ AND type==2",comparestring];
    [requset setPredicate:predicate];
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    self.expensearray = [[NSMutableArray alloc]init];
    self.lastexpense =[[NSMutableArray alloc]init];
    //NSLog(@"datavalue count %lu",(unsigned long)datavalue.count);
    for(Services_Table *fuelrecord in datavalue)
    {
        // NSLog(@"Veh id--- %@",fuelrecord.vehid);
        //  NSLog(@"Service name--- %@",fuelrecord.serviceName);
        // NSLog(@"*****************************");
      if([fuelrecord.type floatValue]==2)
        {
            NSMutableDictionary* expenseRec = [[NSMutableDictionary alloc] init];
            
        [self.expensearray addObject:fuelrecord.serviceName];
           // NSLog(@"expense array %@ count %lu",self.expensearray,(unsigned long)self.expensearray.count);
        if(fuelrecord.lastDate!=NULL)
        {
            [self.lastexpense addObject:[formatter stringFromDate:fuelrecord.lastDate]];
        }
        else
        {
            [self.lastexpense addObject:@""];
        }
            
            [expenseRec setObject:fuelrecord.serviceName forKey:@"ServiceName"];
            [expenseRec setObject:fuelrecord.recurring forKey:@"Recurring"];
            [expenseRec setObject: (fuelrecord.lastOdo != nil? fuelrecord.lastOdo:@"") forKey:@"LastOdo"];
            [expenseRec setObject: (fuelrecord.lastDate != nil? fuelrecord.lastDate:@"") forKey: @"LastServiceDate"];
            
  
            //NSLog(@"serviceRec is %@", expenseRec);
            
            [expenseRecArray addObject:expenseRec];
            
            
        }
    }
    
    //NSLog(@"fuel date %@",self.expensearray);
   // [self.tableview reloadData];
    
}


-(void)backbuttonclick
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addclick
{
    
    EditTasks *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editTask"];
    
    //NSString *tv_expenses = @"Expense";
    modalVC.taskType = @"Expense";
    modalVC.operation = @"Add";
    modalVC.expenseArray = self.expensearray;
    
    // 2. Your code after the modal view dismisses
    modalVC.onDismiss = ^(UIViewController *sender, NSString* message)
    {
        // Do your stuff after dismissing the modal view controller
        //NSLog(@"Modal dissmissed");
        
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

    
    
    [alertController addAction:goproAction];
    [alertController addAction:cancelAction];


    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSMutableArray *Servicearray = [[NSMutableArray alloc]init];
    //NSLog(@"checked array %@",self.checkedarray);
    for(int i = 0; i <self.checkedarray.count;i++)
    {
        int value = [[self.checkedarray objectAtIndex:i]intValue];
        if(value < self.expensearray.count){

            [Servicearray addObject:[self.expensearray objectAtIndex:value]];
        }

    }
    // NSLog(@"service array %@",Servicearray);
    [[NSUserDefaults standardUserDefaults]setObject:Servicearray forKey:@"selectexpense"];
    [[NSUserDefaults standardUserDefaults]setObject:self.expensearray forKey:@"expensearray"];
}

-(void)updateservice: (NSString*)servicename
{
   NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];

    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    // NSUserDefaults *Def =[NSUserDefaults standardUserDefaults];
    // NSString *comparestring = [NSString stringWithFormat:@"%@",[Def objectForKey:@"fillupid"]];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vehid == %@ AND  type==2",comparestring];
    [requset setPredicate:predicate];
    
    NSArray *datavalue=[contex executeFetchRequest:requset error:&err];
    
    for ( Services_Table *service in datavalue)
    {
        if([service.recurring floatValue]==0)
        {

            if([service.serviceName isEqualToString:self.updateexpense])
            {
               service.serviceName = servicename;
            
                if ([contex hasChanges])
                 {
                     BOOL saved = [contex save:&err];
                     if (!saved) {
                         // do some real error handling
                         //CLSLog(@“Could not save Data due to %@“, error);
                     }
                 //  NSLog(@"saved");
                   [[CoreDataController sharedInstance] saveMasterContext];
                 }
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
            if([product.type floatValue]==2)
            {
            if([product.serviceName isEqualToString:[self.expensearray objectAtIndex:indexPath.row]])
            {
                //Swapnil NEW_6
                NSString *userEmail = [Def objectForKey:@"UserEmail"];
                
                //If user is signed In, then only do the sync process..
                if(userEmail != nil && userEmail.length > 0){
                    
                    [rem writeToSyncTableWithRowID:product.iD tableName:@"SERVICE_TABLE" andType:@"del"];
                }
                [contex deleteObject:product];
                [[CoreDataController sharedInstance] saveMasterContext];
            }
            }
        }
        
        NSError *error = nil;
        if (![contex save:&error]) {
           // NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        
        [self.expensearray removeObjectAtIndex:indexPath.row];
        [expenseRecArray removeObjectAtIndex:indexPath.row];

        
        //Swapnil BUG_89
        NSInteger value = indexPath.row;
        NSString *valueString = [NSString stringWithFormat:@"%ld", (long)value];
        [self.checkedarray removeObject:valueString];
        
        [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      //  NSLog(@"expRecArr : %@", expenseRecArray);
    }
    
    
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


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"expense array count %lu",(unsigned long)self.expensearray.count);
    //NSLog(@"expense array value %@",self.expensearray);
    return self.expensearray.count;
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
        cell.namelab.text = [self.expensearray objectAtIndex:indexPath.row];
        cell.checkmark.tag=indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.checkmark setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
        [cell.checkmark setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        if([self.checkedarray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
        {
        
            cell.checkmark.selected=YES;
        }
        
        else if(![self.checkedarray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
        {
            
            cell.checkmark.selected=NO;
        }
        
        cell.lastservice.textColor = [UIColor whiteColor];
//        NSString *last_paid_on = @"Last Paid On";
//        NSString *no_payments = @"No Payments";
        if(![[self.lastexpense objectAtIndex:indexPath.row] isEqualToString: @""])
        {
            cell.lastservice.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"last_paid_on", @"last paid on"), [self.lastexpense objectAtIndex:indexPath.row]];
        }
        
        else
        {
            cell.lastservice.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"last_paid_on", @"Last Paid On"), NSLocalizedString(@"no_payments", @"No Payments")];
        }
        [cell.checkmark addTarget:self action:@selector(checkclick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EditTasks *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editTask"];
    
    modalVC.taskType = @"Expense";
    modalVC.operation = @"Edit";
    modalVC.serviceArray = self.expensearray;
    modalVC.updServiceName = [self.expensearray objectAtIndex:indexPath.row];
    modalVC.serviceRec = [expenseRecArray objectAtIndex:indexPath.row];
    
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

    
    
    
    /*
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Update expense"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Expense Name", @"Expense Name");
         textField.text = [self.expensearray objectAtIndex:indexPath.row];
         self.updateexpense = textField.text;
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
                                           for(int i=0; i<self.expensearray.count;i++)
                                           {
                                               NSString *string = [self.expensearray objectAtIndex:i];
                                               if([string isEqualToString:self.updateexpense])
                                               {
                                                   [self.expensearray replaceObjectAtIndex:i withObject:servicename.text];
                                               }
                                           }
                                           [self.tableview reloadData];
                                       }
                                

                                   
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    */
}

-(void)checkclick : (id)sender
{
    
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableview];
    NSIndexPath *indexPath = [self.tableview indexPathForRowAtPoint:touchPoint];
    
    ServiceTableViewCell *Cell = (ServiceTableViewCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    
    if(Cell.checkmark.selected == YES)
    {
        [Cell.checkmark setSelected:NO];
        [self.checkedarray removeObject:[NSString stringWithFormat:@"%ld",(long)Cell.checkmark.tag]];
        
    }
    
    else if(Cell.checkmark.selected == NO)
    {
        
        [Cell.checkmark setSelected:YES];
        [self.checkedarray addObject:[NSString stringWithFormat:@"%ld",(long)Cell.checkmark.tag]];
        
    }
    
   // NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
   // [def setObject:self.checkedarray forKey:@"checked"];
    [self.tableview reloadData];
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
