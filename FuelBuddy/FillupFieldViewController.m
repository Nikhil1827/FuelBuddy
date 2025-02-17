//
//  FillupFieldViewController.m
//  FuelBuddy
//
//  Created by Swapnil on 20/03/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "FillupFieldViewController.h"
#import "FillupFieldTableViewCell.h"
#import "AutorotateNavigation.h"

@interface FillupFieldViewController ()
{
    NSMutableArray *tripArray;
    
}

@end

@implementation FillupFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //rowNumber = 0;
    
    // Do any additional setup after loading the view.
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    self.checkedarray =[[NSMutableArray alloc]init];
    self.tripCheck0 = [[NSMutableArray alloc] init];
    self.tripCheck1 = [[NSMutableArray alloc] init];
    self.tripCheck2 = [[NSMutableArray alloc] init];
    self.tripCheck3 = [[NSMutableArray alloc] init];

    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.backgroundColor =[self colorFromHexString:@"#2c2c2c"];
    self.tableView.tableFooterView=[UIView new];
    
    //Trip Records
    self.tripSection0 = [[NSMutableArray alloc] initWithObjects:
                         NSLocalizedString(@"date_time", @"Date/Time"),
                         NSLocalizedString(@"odometer", @"Odometer"),
                         NSLocalizedString(@"location", @"Location"), nil];
    
    self.tripSection1 = [[NSMutableArray alloc] initWithObjects:
                         NSLocalizedString(@"Date/Time.", @"Date/Time."),
                         NSLocalizedString(@"Odometer.", @"Odometer."),
                         NSLocalizedString(@"Location.", @"Location."), nil];
    
    self.tripSection2 = [[NSMutableArray alloc] initWithObjects:
                         NSLocalizedString(@"type", @"Type"),
                         NSLocalizedString(@"dist_traveled", @"Distance Traveled"),
                         NSLocalizedString(@"time_traveled", @"Time Traveled"),
                         NSLocalizedString(@"tax_deduction_rate", @"Tax Deduction Rate"),
                         @"Parking",
                         @"Toll",
                         NSLocalizedString(@"tax_deduction_amount", @"Tax Deducted"),
                         NSLocalizedString(@"notes_tv", @"Notes"), nil];
    
    self.tripSection3 = [[NSMutableArray alloc] initWithObjects:
                         NSLocalizedString(@"trip_by_type_tv", @"Dist by Type"),
                         NSLocalizedString(@"tax_ded_by_type_tv", @"Tax Ded by type"), nil];
    
    self.tripFinalArray = [[NSArray alloc] initWithObjects:self.tripSection0, self.tripSection1, self.tripSection2, self.tripSection3, nil];

    
    if(self.rowSelected == 0){
        self.navigationItem.title=[NSLocalizedString(@"f_u_tv", @"Fill-Ups") capitalizedString];
    }
    if(self.rowSelected == 1){
        self.navigationItem.title=[NSLocalizedString(@"tot_services", @"Services") capitalizedString];
    }
    if(self.rowSelected == 2){
        self.navigationItem.title=[NSLocalizedString(@"tv_expenses", @"Expenses") capitalizedString];
    }
    if(self.rowSelected == 3){
        self.navigationItem.title=[NSLocalizedString(@"trips", @"Trips") capitalizedString];
    }
    
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];

    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);

    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];

    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
//    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addclick)];
    self.tableView.separatorColor =[UIColor darkGrayColor];
    
    if(self.rowSelected == 0){
    self.fillUparray = [[NSMutableArray alloc] initWithObjects:
                        NSLocalizedString(@"odometer", @"Odometer"),
                        NSLocalizedString(@"qty_tv", @"Quantity"),
                        NSLocalizedString(@"dist_tv", @"Distance"),
                        NSLocalizedString(@"tc_tv", @"Total Cost"),
                        NSLocalizedString(@"cons_head", @"Consumption"),
                        NSLocalizedString(@"pf_tv", @"Partial Tank"),
                        NSLocalizedString(@"octane", @"Octane"),
                        NSLocalizedString(@"fb_tv", @"Fuel Brand"),
                        NSLocalizedString(@"fs_tv", @"Filling Station"),
                        NSLocalizedString(@"notes_tv", @"Notes"),
                        NSLocalizedString(@"attach_receipt", @"Attach Receipt"), nil];
    }
    
    if(self.rowSelected == 1){
        self.fillUparray = [[NSMutableArray alloc] initWithObjects:
                            NSLocalizedString(@"odometer", @"Odometer"),
                            NSLocalizedString(@"tot_services", @"Services"),
                            NSLocalizedString(@"tc_tv", @"Total Cost"),
                            NSLocalizedString(@"tv_service_center", @"Service Center"),
                            NSLocalizedString(@"notes_tv", @"Notes"),
                            NSLocalizedString(@"attach_receipt", @"Attach Receipt"), nil];
    }
    
    if(self.rowSelected == 2){
        self.fillUparray = [[NSMutableArray alloc] initWithObjects:
                            NSLocalizedString(@"odometer", @"Odometer"),
                            NSLocalizedString(@"tv_expenses", @"Expenses"),
                            NSLocalizedString(@"tc_tv", @"Total Cost"),
                            NSLocalizedString(@"tv_vendor", @"Vendor"),
                            NSLocalizedString(@"notes_tv", @"Notes"),
                            NSLocalizedString(@"attach_receipt", @"Attach Receipt"), nil];
    }

    
    tripArray = [[[NSUserDefaults standardUserDefaults] valueForKey:@"selectTrip"] mutableCopy];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    NSMutableArray *Servicearray = [[NSMutableArray alloc]init];
    NSMutableArray *sortedTripArr = [[NSMutableArray alloc] init];
    NSMutableArray *sortedFillups = [[NSMutableArray alloc] init];
    NSMutableArray *sortedServices = [[NSMutableArray alloc] init];
    NSMutableArray *sortedExpenses = [[NSMutableArray alloc] init];


    if(self.rowSelected == 3){
         //NSMutableDictionary* indexDict = [[NSMutableDictionary alloc] init];

        
        [[NSUserDefaults standardUserDefaults] setObject:[self.checkedarray componentsJoinedByString:@","] forKey:@"checkedArr"];
        
        for(int i = 0; i < self.checkedarray.count; i++){
    
          NSIndexPath  *indexPath  = [self.checkedarray objectAtIndex:i];
            
            NSInteger secInteger = indexPath.section;
            
            if(secInteger  == 0){
                [Servicearray addObject:[self.tripSection0 objectAtIndex: indexPath.row]];
            }
            if(secInteger  == 1){
                [Servicearray addObject:[self.tripSection1 objectAtIndex: indexPath.row]];
               
            }
            if(secInteger  == 2){
                [Servicearray addObject:[self.tripSection2 objectAtIndex: indexPath.row]];
            }
            if(secInteger  == 3){
                [Servicearray addObject:[self.tripSection3 objectAtIndex: indexPath.row]];
            }
            
           
            
            
        }
        
       
        
        if([Servicearray containsObject:NSLocalizedString(@"date_time", @"Date/Time")]){
            [sortedTripArr addObject:@"Dep Date/Time"];
        }
        if([Servicearray containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
            [sortedTripArr addObject:@"Dep Odometer"];
        }
        if([Servicearray containsObject:NSLocalizedString(@"location", @"Location")]){
            [sortedTripArr addObject:@"Dep Location"];
        }
        if([Servicearray containsObject:NSLocalizedString(@"Date/Time.", @"Date/Time.")]){
            [sortedTripArr addObject:@"Arr Date/Time"];
        }
        if([Servicearray containsObject:NSLocalizedString(@"Odometer.", @"Odometer.")]){
            [sortedTripArr addObject:@"Arr Odometer"];
        }
        if([Servicearray containsObject:NSLocalizedString(@"Location.", @"Location.")]){
            [sortedTripArr addObject:@"Arr Location"];
        }
        if([Servicearray containsObject:NSLocalizedString(@"type", @"Type")]){
            [sortedTripArr addObject:NSLocalizedString(@"type", @"Type")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"dist_traveled", @"Distance Traveled") ]){
            [sortedTripArr addObject:NSLocalizedString(@"dist_traveled", @"Distance Traveled")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"time_traveled", @"Time Traveled")]){
            [sortedTripArr addObject:NSLocalizedString(@"time_traveled", @"Time Traveled")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"tax_deduction_rate", @"Tax Deduction Rate")]){
            [sortedTripArr addObject:NSLocalizedString(@"tax_deduction_rate", @"Tax Deduction Rate")];
        }
        if([Servicearray containsObject:@"Parking"]){
            [sortedTripArr addObject:@"Parking"];
        }
        if([Servicearray containsObject:@"Toll"]){
            [sortedTripArr addObject:@"Toll"];
        }
        if([Servicearray containsObject:NSLocalizedString(@"tax_deduction_amount", @"Tax Deducted")]){
            [sortedTripArr addObject:NSLocalizedString(@"tax_deduction_amount", @"Tax Deducted")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
            [sortedTripArr addObject:NSLocalizedString(@"notes_tv", @"Notes")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"trip_by_type_tv", @"Dist by Type")]){
            [sortedTripArr addObject:NSLocalizedString(@"trip_by_type_tv", @"Dist by Type")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"tax_ded_by_type_tv", @"Tax Ded by type")]){
            [sortedTripArr addObject:NSLocalizedString(@"tax_ded_by_type_tv", @"Tax Ded by type")];
        }
        
        //NSLog(@"sorted trips = %@", sortedTripArr);
        [[NSUserDefaults standardUserDefaults]setObject:Servicearray forKey:@"selectTrip"];
        [[NSUserDefaults standardUserDefaults] setObject:sortedTripArr forKey:@"sortedTrips"];
        

        
    }else {
            //For Fill ups, services, Expenses
            for(int i = 0; i <self.checkedarray.count;i++)
            {
                int value = [[self.checkedarray objectAtIndex:i]intValue];
                [Servicearray addObject:[self.fillUparray objectAtIndex:value]];
            }
        }
    
    
    if(self.rowSelected == 0){
        [[NSUserDefaults standardUserDefaults]setObject:Servicearray forKey:@"selectFillup"];

        if([Servicearray containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
            [sortedFillups addObject:NSLocalizedString(@"odometer", @"Odometer")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"qty_tv", @"Quantity")]){
            [sortedFillups addObject:NSLocalizedString(@"qty_tv", @"Quantity")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"dist_tv", @"Distance")]){
            [sortedFillups addObject:NSLocalizedString(@"dist_tv", @"Distance")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"tc_tv", @"Total Cost")]){
            [sortedFillups addObject:NSLocalizedString(@"tc_tv", @"Total Cost")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"cons_head", @"Consumption")]){
            [sortedFillups addObject:NSLocalizedString(@"cons_head", @"Consumption")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"pf_tv", @"Partial Tank")]){
            [sortedFillups addObject:NSLocalizedString(@"pf_tv", @"Partial Tank")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"octane", @"Octane")]){
            [sortedFillups addObject:NSLocalizedString(@"octane", @"Octane")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"fb_tv", @"Fuel Brand")]){
            [sortedFillups addObject:NSLocalizedString(@"fb_tv", @"Fuel Brand")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"fs_tv", @"Filling Station")]){
            [sortedFillups addObject:NSLocalizedString(@"fs_tv", @"Filling Station")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
            [sortedFillups addObject:NSLocalizedString(@"notes_tv", @"Notes")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
            [sortedFillups addObject:NSLocalizedString(@"attach_receipt", @"Attach Receipt")];
        }
        [[NSUserDefaults standardUserDefaults] setObject:sortedFillups forKey:@"sortedFills"];
    }
    if(self.rowSelected == 1){
        [[NSUserDefaults standardUserDefaults]setObject:Servicearray forKey:@"selectService"];
        if([Servicearray containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
            [sortedServices addObject:NSLocalizedString(@"odometer", @"Odometer")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"tot_services", @"Services")]){
            [sortedServices addObject:NSLocalizedString(@"tot_services", @"Services")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"tc_tv", @"Total Cost")]){
            [sortedServices addObject:NSLocalizedString(@"tc_tv", @"Total Cost")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"tv_service_center", @"Service Center")]){
            [sortedServices addObject:NSLocalizedString(@"tv_service_center", @"Service Center")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
            [sortedServices addObject:NSLocalizedString(@"notes_tv", @"Notes")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
            [sortedServices addObject:NSLocalizedString(@"attach_receipt", @"Attach Receipt")];
        }
        [[NSUserDefaults standardUserDefaults] setObject:sortedServices forKey:@"sortedService"];

    }
    if(self.rowSelected == 2){
        [[NSUserDefaults standardUserDefaults]setObject:Servicearray forKey:@"selectExpense"];
        if([Servicearray containsObject:NSLocalizedString(@"odometer", @"Odometer")]){
            [sortedExpenses addObject:NSLocalizedString(@"odometer", @"Odometer")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"tv_expenses", @"Expenses")]){
            [sortedExpenses addObject:NSLocalizedString(@"tv_expenses", @"Expenses")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"tc_tv", @"Total Cost")]){
            [sortedExpenses addObject:NSLocalizedString(@"tc_tv", @"Total Cost")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"tv_vendor", @"Vendor")]){
            [sortedExpenses addObject:NSLocalizedString(@"tv_vendor", @"Vendor")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"notes_tv", @"Notes")]){
            [sortedExpenses addObject:NSLocalizedString(@"notes_tv", @"Notes")];
        }
        if([Servicearray containsObject:NSLocalizedString(@"attach_receipt", @"Attach Receipt")]){
            [sortedExpenses addObject:NSLocalizedString(@"attach_receipt", @"Attach Receipt")];
        }
        [[NSUserDefaults standardUserDefaults] setObject:sortedExpenses forKey:@"sortedExpense"];

    }

    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    
    NSArray *Service = [[NSArray alloc]init];
//    for(int i = 0; i < self.checkedarray.count; i++){
//    }
    
    
    if(self.rowSelected == 0){
        Service = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectFillup"]mutableCopy];
        for(NSString *string in Service)
        {
            if([self.fillUparray containsObject:string])
            {
                [self.checkedarray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self.fillUparray     indexOfObject:string]]];
            }
        }
    }
    if(self.rowSelected == 1){
        Service = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectService"]mutableCopy];
        for(NSString *string in Service)
        {
            if([self.fillUparray containsObject:string])
            {
                [self.checkedarray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self.fillUparray     indexOfObject:string]]];
            }
        }
    }
    if(self.rowSelected == 2){
        Service = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectExpense"]mutableCopy];
        for(NSString *string in Service)
        {
            if([self.fillUparray containsObject:string])
            {
                [self.checkedarray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self.fillUparray     indexOfObject:string]]];
            }
        }
    }
    if(self.rowSelected == 3){
        Service = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectTrip"]mutableCopy];

        for(int i = 0; i < self.checkedarray.count; i++){
        NSIndexPath *indexPath = [self.checkedarray objectAtIndex:i];
        NSInteger sectionNumber = indexPath.section;
        

        
        if(sectionNumber == 0){
            for(NSString *string in Service)
            {
                if([self.tripSection0 containsObject:string]){
                    [self.checkedarray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self.tripSection0     indexOfObject:string]]];
                }
            }
        }
        if(sectionNumber == 1){
            for(NSString *string in Service)
            {
                if([self.tripSection1 containsObject:string]){
                    [self.checkedarray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self.tripSection1     indexOfObject:string]]];
                }
            }
        }

        if(sectionNumber == 2){
            for(NSString *string in Service)
            {
                if([self.tripSection2 containsObject:string]){
                    [self.checkedarray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self.tripSection2     indexOfObject:string]]];
                }
            }
        }
        if(sectionNumber == 3){
            for(NSString *string in Service)
            {
                if([self.tripSection3 containsObject:string]){
                    [self.checkedarray addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self.tripSection3 indexOfObject:string]]];
                }
            }
            }
        }
    }

        /*
        if([sectionNumber isEqual:@(3)]){
            for(NSString *string in Service)
            {
                if([self.tripSection3 containsObject:string]){
                    [self.checkedarray addObject:[self.tripSection3 objectAtIndex:[[indexDict valueForKey:@"row"] integerValue]]];
                }
            }
        }*/

    
    
    

    
    

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [self.tableView reloadData];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

//In a storyboard-based application, you will often want to do a little preparation before navigation

#pragma mark - AUTOROTATE NAVIGATION OFF

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

#pragma mark - GENERAL METHODS

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)backbuttonclick
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITABLEVIEW DATASOURCE METHODS

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if(self.rowSelected == 3){
        return self.tripFinalArray.count;
    } else
        return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(self.rowSelected == 3){
        
        if(section == 0){
            return self.tripSection0.count;
        }
        if (section == 1){
            return self.tripSection1.count;
        }
        if (section == 2){
            return self.tripSection2.count;
        }
        if(section == 3){
            return self.tripSection3.count;
        }
        else
            return 0;
    } else
        return self.fillUparray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FillupFieldTableViewCell *cell = (FillupFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[FillupFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] ;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.nameLabel.textColor = [UIColor whiteColor];

   // NSMutableDictionary* indexDict = [[NSMutableDictionary alloc] init];

    if(self.rowSelected == 3){

        //Read serviceArray
        //For trips
        
        if(indexPath.section == 0){
            cell.nameLabel.text = [self.tripSection0 objectAtIndex:indexPath.row];
            //Check if text contained in ServiceArray
            if([tripArray containsObject:cell.nameLabel.text]){
                [self.checkedarray addObject:indexPath];
                
            }
            
            
            
        }
        if(indexPath.section == 1){
            cell.nameLabel.text = [self.tripSection1 objectAtIndex:indexPath.row];
            
            if([tripArray containsObject:cell.nameLabel.text]){
                [self.checkedarray addObject:indexPath];
            }
            
            
        }
        if(indexPath.section == 2){
            cell.nameLabel.text = [self.tripSection2 objectAtIndex:indexPath.row];
            if([tripArray containsObject:cell.nameLabel.text]){
                [self.checkedarray addObject:indexPath];
            }
            
        }
        if(indexPath.section == 3){
            cell.nameLabel.text = [self.tripSection3 objectAtIndex:indexPath.row];
            if([tripArray containsObject:cell.nameLabel.text]){
                [self.checkedarray addObject:indexPath];
            }
            
        }
        
        
        if([self.checkedarray containsObject:indexPath])
        {
            cell.checkmarkButton.selected=YES;
        }
        
        else
        {
            cell.checkmarkButton.selected=NO;
        }

        [cell.checkmarkButton addTarget:self action:@selector(checkclick:) forControlEvents:UIControlEventTouchUpInside];
        


    } else {
        
            //For Fill-ups, services, Expenses
            cell.nameLabel.text = [self.fillUparray objectAtIndex:indexPath.row];
            cell.checkmarkButton.tag = indexPath.row;
        
            if([self.checkedarray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
            {
                cell.checkmarkButton.selected=YES;
            }
            
            else if(![self.checkedarray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
            {
                
                cell.checkmarkButton.selected=NO;
            }
        
        }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.checkmarkButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
    [cell.checkmarkButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [cell.checkmarkButton addTarget:self action:@selector(checkclick:) forControlEvents:UIControlEventTouchUpInside];
    

    return cell;
    
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(self.rowSelected == 3){
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    sectionView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, tableView.bounds.size.width, 22)];
    tempLabel.textColor = [self colorFromHexString:@"#F4D03F"];
    tempLabel.backgroundColor = [UIColor clearColor];
    
    if(section == 0){
        tempLabel.text = NSLocalizedString(@"departure", @"Departure");
    }
    if(section == 1){
        tempLabel.text = NSLocalizedString(@"arrival", @"Arrival");
    }
    if(section == 2){
        tempLabel.text = @"Others";
    }
    if(section == 3){
        tempLabel.text = NSLocalizedString(@"total", @"Trip Totals");
    }
        
    
    
    [sectionView addSubview:tempLabel];
    return sectionView;
    }
    else{
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
        sectionView.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
        return sectionView;
    }
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView==self.tableView)
    {
        return 30;
        return UITableViewAutomaticDimension;
    }
    
    
    else
        return NO;
}


-(void)checkclick : (id)sender
{
    
    
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    
    FillupFieldTableViewCell *Cell = (FillupFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if(self.rowSelected == 3){
        
        if(indexPath.section == 0){
            if(Cell.checkmarkButton.selected == YES)
            {
                
                [Cell.checkmarkButton setSelected:NO];
                
                [self.checkedarray removeObject:indexPath];
                if([tripArray containsObject:Cell.nameLabel.text]){

                    [tripArray removeObject:Cell.nameLabel.text];
                }
            }
            
            else if(Cell.checkmarkButton.selected == NO)
            {
                
                [Cell.checkmarkButton setSelected:YES];
                
                [self.checkedarray addObject:indexPath];
                
            }
        }
        if(indexPath.section == 1){
            if(Cell.checkmarkButton.selected == YES)
            {
                
                [Cell.checkmarkButton setSelected:NO];
                
                [self.checkedarray removeObject:indexPath];
                if([tripArray containsObject:Cell.nameLabel.text]){
                    [tripArray removeObject:Cell.nameLabel.text];
                }
            }
            
            else if(Cell.checkmarkButton.selected == NO)
            {
                
                [Cell.checkmarkButton setSelected:YES];
                
                [self.checkedarray addObject:indexPath];
                
            }
        }
        if(indexPath.section == 2){
            if(Cell.checkmarkButton.selected == YES)
            {
                
                [Cell.checkmarkButton setSelected:NO];
                
                [self.checkedarray removeObject:indexPath];
                if([tripArray containsObject:Cell.nameLabel.text]){

                [tripArray removeObject:Cell.nameLabel.text];
                }
            }
            
            else if(Cell.checkmarkButton.selected == NO)
            {
                
                [Cell.checkmarkButton setSelected:YES];
                

                [self.checkedarray addObject:indexPath];
                
            }
        }
        if(indexPath.section == 3){
            if(Cell.checkmarkButton.selected == YES)
            {
                
                [Cell.checkmarkButton setSelected:NO];
                
                [self.checkedarray removeObject:indexPath];
                if([tripArray containsObject:Cell.nameLabel.text]){
                    
                    [tripArray removeObject:Cell.nameLabel.text];
                }
            }
            
            else if(Cell.checkmarkButton.selected == NO)
            {
                
                [Cell.checkmarkButton setSelected:YES];
                
                
                [self.checkedarray addObject:indexPath];
                
            }
        }

        
        
    }
    
    else {

    if(Cell.checkmarkButton.selected == YES)
    {
        [Cell.checkmarkButton setSelected:NO];
        [self.checkedarray removeObject:[NSString stringWithFormat:@"%ld",(long)Cell.checkmarkButton.tag]];
        
    }
    
    else if(Cell.checkmarkButton.selected == NO)
    {
        
        [Cell.checkmarkButton setSelected:YES];
        
        [self.checkedarray addObject:[NSString stringWithFormat:@"%ld",(long)Cell.checkmarkButton.tag]];
        
    }
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.checkedarray forKey:@"checked"];
    [self.tableView reloadData];

    }
    

}





@end
