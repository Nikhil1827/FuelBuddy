//
//  CustomDashViewController.m
//  FuelBuddy
//
//  Created by surabhi on 05/02/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "CustomDashViewController.h"
#import "CustomSubViewController.h"
#import "AppDelegate.h"

@interface CustomDashViewController ()

@end

//Swapnil 15 Mar-17
// static GADMasterViewController *shared;
@implementation CustomDashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    [self.tabBarController.tabBar setHidden:YES];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=YES;
    self.dataarray =[[NSMutableArray alloc]initWithObjects:
                     NSLocalizedString(@"tot_fig_tv", @"Total Stats"),
                     NSLocalizedString(@"avg_fig_head", @"Average Fuel Stats"),
                     NSLocalizedString(@"avg_service_head", @"Average Service Stats"),
                     NSLocalizedString(@"avg_expense_head", @"Average Other Expense Stats") ,
                     NSLocalizedString(@"trip_stats", @"Total Trip Stats") , nil];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    //self.tableview.backgroundColor = [self colorFromHexString:@"#303030"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationItem.title=[NSLocalizedString(@"cust_db_head", @"Customise Stats & Charts") capitalizedString];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    self.tableview.tableFooterView =[UIView new];
    self.tableview.backgroundColor =[UIColor clearColor];
    self.tableview.dataSource=self;
    self.tableview.delegate=self;
    self.tableview.separatorColor =[UIColor darkGrayColor];
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
}


-(void)viewDidAppear:(BOOL)animated
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

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
    return self.dataarray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] ;
        
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [self colorFromHexString:@"#303030"];
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [self.dataarray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dist,*vol;
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")])
    {
        dist = NSLocalizedString(@"mi", @"mi");
    }
    
    else
    {
        dist= NSLocalizedString(@"kms", @"km");
    }
    
    NSString *stringval1 =[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"cost_tv", @"Fuel cost/"),dist];
   
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour", @"Kilowatt-Hour")]){

        vol = NSLocalizedString(@"kwh", @"kWh");

    }else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"] isEqualToString:NSLocalizedString(@"disp_litre", @"Litre")])
    {
        vol = NSLocalizedString(@"ltr", @"Ltr");
        
    }
    
    else
    {
        vol = NSLocalizedString(@"gal", @"gal");
    }
    

    NSString *stringval2 =[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"avg_price_tv", @"Average Price/"),vol];
     CustomSubViewController *custsub = (CustomSubViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"custsub"];
     custsub.titlestring = [self.dataarray objectAtIndex:indexPath.row];
    if(indexPath.row==0)
    {
       
        custsub.textplace = [[NSMutableArray alloc]initWithObjects:
                             NSLocalizedString(@"dist_tv", @"Distance") ,
                             NSLocalizedString(@"f_u_tv", @"Fill-ups") ,
                             NSLocalizedString(@"f_q_tv", @"Fuel Qty") ,
                             NSLocalizedString(@"f_c_tv", @"Fuel Cost") ,
                             NSLocalizedString(@"tot_services", @"Services")  ,
                             NSLocalizedString(@"tot_service_cost", @"Service Cost") ,
                             NSLocalizedString(@"tot_expense_cost", @"Other Expenses") ,nil];
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"section0"]==nil)
        {
            custsub.arrayaddedtext = [[NSMutableArray alloc]initWithArray:custsub.textplace];
        }
        
        else
        {
            custsub.arrayaddedtext = [[NSMutableArray alloc]initWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"section0"] mutableCopy]];
        }
        custsub.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:custsub animated:YES];
    }
    
    if(indexPath.row==1)
    {
        NSArray *addedTextsArr = [[[NSUserDefaults standardUserDefaults] objectForKey:@"section1"]mutableCopy];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        
        NSString *maxOctane = [def objectForKey:@"maxmOctane"];
        NSString *maxBrand = [def objectForKey:@"maxmBrand"];
        NSString *maxStation = [def objectForKey:@"maxmStation"];

        custsub.textplace = [[NSMutableArray alloc]initWithObjects:
                             NSLocalizedString(@"avg_fuel_tv", @"Average Fuel Efficiency") ,
                             NSLocalizedString(@"dist_btn_fu_graph_name", @"Distance between Fill-ups") ,
                             NSLocalizedString(@"qty_per_fu_tv", @"Qty per Fill-up") ,
                             NSLocalizedString(@"cost_per_fu_tv", @"Cost per Fill-up") ,
                             NSLocalizedString(@"fu_pm_tv", @"Fill-ups/month") ,
                             NSLocalizedString(@"cpd_tv", @"Fuel cost/day") ,
                             NSLocalizedString(@"cpmth_tv", @"Fuel Cost/Mth") , nil];
        
        [custsub.textplace insertObject:stringval2 atIndex:4];
        [custsub.textplace insertObject:stringval1 atIndex:6];
        [custsub.textplace insertObject:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"eff_oct_tv", @"Eff by Octane"), maxOctane] atIndex:9];
        [custsub.textplace insertObject:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"eff_brand_tv", @"Eff by Brand"), maxBrand] atIndex:10];
        [custsub.textplace insertObject:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"eff_stn_tv", @"Eff by Stn"), maxStation] atIndex:11];

        if([[NSUserDefaults standardUserDefaults]objectForKey:@"section1"]==nil || addedTextsArr.count < 9 )
        {
            custsub.arrayaddedtext = [[NSMutableArray alloc]initWithArray:custsub.textplace];
        }

        else
        {
            custsub.arrayaddedtext = [[NSMutableArray alloc]initWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"section1"] mutableCopy]];
        }
        custsub.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:custsub animated:YES];
    }

    
    if(indexPath.row==2)
    {
        
        custsub.textplace = [[NSMutableArray alloc]init];
        NSString *stringval =[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"service_cost_tv", @"Service Cost/"),dist];
        
        [custsub.textplace addObject:stringval];
        [custsub.textplace addObject:NSLocalizedString(@"scpd_tv", @"Service Cost/Day")];

        if([[NSUserDefaults standardUserDefaults]objectForKey:@"section2"]==nil)
        {
            custsub.arrayaddedtext = [[NSMutableArray alloc]initWithArray:custsub.textplace];
        }
        
        else
        {
            custsub.arrayaddedtext = [[NSMutableArray alloc]initWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"section2"] mutableCopy]];
        }
        custsub.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:custsub animated:YES];
    }

    
    if(indexPath.row==3)
    {
        
        custsub.textplace = [[NSMutableArray alloc]initWithObjects:
                             NSLocalizedString(@"ecpd_tv", @"Other Expenses/Day"),nil];
        
        [custsub.textplace insertObject:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"expense_cost_tv", @"Other Expenses/"),dist] atIndex:0];
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"section3"]==nil)
        {
            custsub.arrayaddedtext = [[NSMutableArray alloc]initWithArray:custsub.textplace];
        }
        else
        {
            custsub.arrayaddedtext = [[NSMutableArray alloc]initWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"section3"] mutableCopy]];
        }
        custsub.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:custsub animated:YES];
    }

    if(indexPath.row==4)
    {
        
        custsub.textplace = [[NSMutableArray alloc]initWithObjects:
                             NSLocalizedString(@"total_trips", @"Total Trips") ,
                             NSLocalizedString(@"total_trip_dist", @"Total Trip Distance") ,
                             NSLocalizedString(@"total_tax_ded", @"Total Trip Deduction") ,
                             NSLocalizedString(@"trip_by_type", @"Dist by Type()") ,
                             NSLocalizedString(@"tax_ded_by_type", @"Tax Dedn by Type()") ,nil];
        //[custsub.textplace insertObject:stringval2 atIndex:4];
        //[custsub.textplace insertObject:stringval1 atIndex:6];
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"section4"]==nil)
        {
            custsub.arrayaddedtext = [[NSMutableArray alloc]initWithArray:custsub.textplace];
        }
        
        else
        {
            custsub.arrayaddedtext = [[NSMutableArray alloc]initWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"section4"] mutableCopy]];
        }
        custsub.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController pushViewController:custsub animated:YES];
    }

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
