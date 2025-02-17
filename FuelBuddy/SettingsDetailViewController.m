//
//  SettingsDetailViewController.m
//  FuelBuddy
//
//  Created by Surabhi on 08/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "SettingsDetailViewController.h"

@interface SettingsDetailViewController ()

@end

//Swapnil 15 Mar-17
//static GADMasterViewController *shared;
@implementation SettingsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    self.tableview.tableFooterView=[UIView new];
    self.tableview.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    

}

-(void)backbuttonclick

{
    
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)viewDidAppear:(BOOL)animated
{
    self.distance = [[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"];
    self.volume =[[NSUserDefaults standardUserDefaults]objectForKey:@"vol_unit"];
    self.consump =[[NSUserDefaults standardUserDefaults]objectForKey:@"con_unit"];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

}

-(BOOL)shouldAutorotate
{
    return NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.selectvalue.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] ;
        
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor= [UIColor whiteColor];
   // cell.accessoryType =UITableViewCellAccessoryNone;
    cell.backgroundColor=[UIColor clearColor];
    cell.textLabel.text = [self.selectvalue objectAtIndex:indexPath.row];
    NSLog(@"%@",self.selectvalue);
  if([self.unittype isEqualToString:NSLocalizedString(@"dist_tv", @"Distance")])
  {
      //NSLog(@"distance value %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"]);
    if([cell.textLabel.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"dist_unit"]])
    {
    cell.selected=YES;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
      
      else
      {
          cell.selected = NO;
          cell.accessoryType = UITableViewCellAccessoryNone;
      }
  }
    
    
   else if([self.unittype isEqualToString:NSLocalizedString(@"vol_head", @"Volume")])
    {
        //NSLog(@"distance value %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"]);
        if([cell.textLabel.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"vol_unit"]])
        {
            cell.selected=YES;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        else
        {
            cell.selected = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }

    
    
   else if([self.unittype isEqualToString:NSLocalizedString(@"cons_head", @"Consumption")])
    {
        //NSLog(@"distance value %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"]);
        if([cell.textLabel.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"con_unit"]])
        {
            cell.selected=YES;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        else
        {
            cell.selected = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    
   else if([self.unittype isEqualToString:NSLocalizedString(@"curr_head", @"Currency")])
   {
       //NSLog(@"distance value %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"dist_unit"]);
       if([cell.textLabel.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"curr_unit"]])
       {
           cell.selected=YES;
           cell.accessoryType = UITableViewCellAccessoryCheckmark;
       }
       
       else
       {
           cell.selected = NO;
           cell.accessoryType = UITableViewCellAccessoryNone;
       }
   }


    return cell;
    
    
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([self.unittype isEqualToString:NSLocalizedString(@"dist_tv", @"Distance")])
    {
        [def setObject:[self.selectvalue objectAtIndex:indexPath.row] forKey:@"dist_unit"];

        if([[self.selectvalue objectAtIndex:indexPath.row] isEqualToString:NSLocalizedString(@"disp_miles", @"Miles")]){

            if([self.volume isEqualToString:NSLocalizedString(@"disp_kilowatt_hour",@"Kilowatt-Hour")]){

                [[NSUserDefaults standardUserDefaults] setObject:NSLocalizedString(@"disp_mpkwh", @"m/kWh") forKey:@"con_unit"];
            }else{

                [[NSUserDefaults standardUserDefaults] setObject:NSLocalizedString(@"disp_kmpkwh", @"km/kWh") forKey:@"con_unit"];
            }

        }
    }
    
    else if([self.unittype isEqualToString:NSLocalizedString(@"vol_head", @"Volume")])
    {
        //NSLog(@"vol %@",[self.selectvalue objectAtIndex:indexPath.row]);
        [def setObject:[self.selectvalue objectAtIndex:indexPath.row] forKey:@"vol_unit"];

        if([[self.selectvalue objectAtIndex:indexPath.row] isEqualToString:NSLocalizedString(@"disp_kilowatt_hour",@"Kilowatt-Hour")]){

            if([self.distance isEqualToString: NSLocalizedString(@"disp_miles", @"Miles")]){

                [[NSUserDefaults standardUserDefaults] setObject:NSLocalizedString(@"disp_mpkwh", @"m/kWh") forKey:@"con_unit"];
            }else{

                [[NSUserDefaults standardUserDefaults] setObject:NSLocalizedString(@"disp_kmpkwh", @"km/kWh") forKey:@"con_unit"];
            }
        }else {

            if([self.consump isEqualToString: NSLocalizedString(@"disp_mpkwh", @"m/kWh")] || [self.consump isEqualToString: NSLocalizedString(@"disp_kmpkwh", @"km/kWh")]){

                if([[self.selectvalue objectAtIndex:indexPath.row] isEqualToString: NSLocalizedString(@"disp_litre", @"Litre")]){

                    [[NSUserDefaults standardUserDefaults] setObject:NSLocalizedString(@"disp_kmpl", @"km/L") forKey:@"con_unit"];

                }else if([[self.selectvalue objectAtIndex:indexPath.row] isEqualToString: NSLocalizedString(@"disp_gal_us", @"Gallon (US)")]){

                    [[NSUserDefaults standardUserDefaults] setObject:NSLocalizedString(@"disp_mpg_us", @"mpg (US)") forKey:@"con_unit"];
                }else{

                    [[NSUserDefaults standardUserDefaults] setObject:NSLocalizedString(@"disp_mpg_uk", @"mpg (UK)") forKey:@"con_unit"];
                }

            }

        }
    }

    else if([self.unittype isEqualToString:NSLocalizedString(@"cons_head", @"Consumption")])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[self.selectvalue objectAtIndex:indexPath.row] forKey:@"con_unit"];
    }

    else if([self.unittype isEqualToString:NSLocalizedString(@"curr_head", @"Currency")])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[self.selectvalue objectAtIndex:indexPath.row] forKey:@"curr_unit"];
    }

    [self.tableview reloadData];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    [self.tableview reloadData];
}




@end
