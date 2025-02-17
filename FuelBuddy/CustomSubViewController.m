//
//  CustomSubViewController.m
//  FuelBuddy
//
//  Created by surabhi on 05/02/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "CustomSubViewController.h"
#import "CustomfillTableViewCell.h"
#import "AppDelegate.h"

@interface CustomSubViewController ()

@end
 //static GADMasterViewController *shared;
@implementation CustomSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableview.backgroundColor =[self colorFromHexString:@"#2c2c2c"];
    [self.tabBarController.tabBar setHidden:YES];
    AppDelegate *App = [AppDelegate sharedAppDelegate];
    App.tabbutton.hidden=YES;
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationItem.title=[self.titlestring capitalizedString];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    
    //self.navigationController.title = self.titlestring;
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    self.tableview.tableFooterView =[UIView new];
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
}


-(void)backbuttonclick
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

}
-(void)viewDidDisappear:(BOOL)animated
{
    
    //NSLog(@"array text %@",self.arrayaddedtext);
    if([self.titlestring isEqualToString:[NSLocalizedString(@"tot_fig_tv", @"Total Stats") capitalizedString]])
    {
        [[NSUserDefaults standardUserDefaults]setObject:self.arrayaddedtext forKey:@"section0"];
    }
    if([self.titlestring isEqualToString:[NSLocalizedString(@"avg_fig_head", @"Average Fuel Stats") capitalizedString]])
    {
        [[NSUserDefaults standardUserDefaults]setObject:self.arrayaddedtext forKey:@"section1"];
    }
    if([self.titlestring isEqualToString:[NSLocalizedString(@"avg_service_head", @"Average Service Stats") capitalizedString]])
    {
        [[NSUserDefaults standardUserDefaults]setObject:self.arrayaddedtext forKey:@"section2"];
    }
    if([self.titlestring isEqualToString:[NSLocalizedString(@"avg_expense_head", @"Average Other Expense Stats") capitalizedString]])
    {
        [[NSUserDefaults standardUserDefaults]setObject:self.arrayaddedtext forKey:@"section3"];
    }
    if([self.titlestring isEqualToString:[NSLocalizedString(@"trip_stats", @"Total Trip Stats") capitalizedString]])
    {
        [[NSUserDefaults standardUserDefaults]setObject:self.arrayaddedtext forKey:@"section4"];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.textplace.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] ;
        
    }
    
    if(tableView==self.tableview)
    {
        CustomfillTableViewCell *cell = (CustomfillTableViewCell *)[self.tableview dequeueReusableCellWithIdentifier:@"Cell"];
        cell.backgroundColor=[UIColor clearColor];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        
        cell.slideswitch.onTintColor =[self colorFromHexString:@"#F9D400"];
        if(indexPath.row==0)
        {
            cell.slideswitch.userInteractionEnabled=NO;
            cell.titlename.text =[NSString stringWithFormat:@"%@ %@",[self.textplace objectAtIndex:indexPath.row], NSLocalizedString(@"required", @"(req)")];
        }
        else
        {
            cell.slideswitch.userInteractionEnabled =YES;
            cell.titlename.text =[self.textplace objectAtIndex:indexPath.row];
            if([self.arrayaddedtext containsObject:cell.titlename.text])
            {
                [cell.slideswitch setOn:YES animated:NO];
            }
            else
            {
                [cell.slideswitch setOn:NO animated:NO];
                
            }
        }
        
        cell.slideswitch.tag=indexPath.row;
        [cell.slideswitch addTarget:self action:@selector(switchclick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return cell;
}


-(void) switchclick: (id)sender
{
    
    CGPoint switchPositionPoint = [sender convertPoint:CGPointZero toView:[self tableview]];
    NSIndexPath *indexPath = [[self tableview] indexPathForRowAtPoint:switchPositionPoint];
    
    CustomfillTableViewCell *cell = (CustomfillTableViewCell*)[self.tableview cellForRowAtIndexPath:indexPath];
    
    if (cell.slideswitch.on)
    {
        //NSLog(@"array added text = %@", self.arrayaddedtext);
        [self.arrayaddedtext replaceObjectAtIndex:cell.slideswitch.tag withObject:cell.titlename.text];
        
    }
    
    else
    {
        
        [self.arrayaddedtext replaceObjectAtIndex:cell.slideswitch.tag withObject:@""];
        
    }
    
    //NSLog(@"self.arrayaddedtext: %@", self.arrayaddedtext);
    //[[NSUserDefaults standardUserDefaults] setObject:self.arrayaddedtext forKey:@"addedTexts"];
    
}


-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
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
