//
//  CustomiseFillupViewController.m
//  FuelBuddy
//
//  Created by Surabhi on 20/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "CustomiseFillupViewController.h"
#import "CustomfillTableViewCell.h"
#import "AppDelegate.h"

@interface CustomiseFillupViewController ()

@end

//Swapnil 15 Mar-17
//static GADMasterViewController *shared;
@implementation CustomiseFillupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    self.tableview.tableFooterView=[UIView new];
    self.tableview.backgroundColor =[self colorFromHexString:@"#2c2c2c"];
    //NIKHIL tableview is not in view so brought down
    self.tableview.frame = CGRectMake(0,self.navigationController.navigationBar.frame.size.height+10 ,self.view.frame.size.width , self.view.frame.size.height);
    //[self.tableview setContentHuggingPriority:999 forAxis:  ];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationItem.title=[NSLocalizedString(@"cust_fu_head", @"Select input fields") capitalizedString];
     [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.arrayaddedtext =[[NSMutableArray alloc]initWithArray:[[def arrayForKey:@"arrayvalue"] mutableCopy]];
    
    //NSLog(@"view did load arrayvalue: %@", self.arrayaddedtext );
    
   // NSLog(@"view did load self.textplace: %@", self.textplace );
    
//    NSString *qty_required = @"Qty";
//    NSString *pf_tv = @"Partial Tank";
//    NSString *mf_tv = @"Missed Previous Fill up";
//    NSString *prc_per_unt = @"Price/Unit";
//    NSString *tc_tv = @"Total Cost";
//    NSString *fb_tv = @"Fuel Brand";
//    NSString *fs_tv = @"Filling station";
//    NSString *notes_tv = @"Notes";
//    NSString *attach_receipt = @"Attach receipt";
    
    if(self.arrayaddedtext.count==0)
    {
        
        self.arrayaddedtext=[[NSMutableArray alloc]initWithObjects:
                             NSLocalizedString(@"date", @"Date"),
                             NSLocalizedString(@"odometer", @"Odometer"),
                             NSLocalizedString(@"qty_required", @"Qty"),
                             NSLocalizedString(@"pf_tv", @"partial tank"),
                             NSLocalizedString(@"mf_tv", @"missed prev fillup"),
                             NSLocalizedString(@"prc_per_unt", @"price/unit"),
                             NSLocalizedString(@"tc_tv", @"Total cost"),
                             NSLocalizedString(@"octane", @"Octane"),
                             NSLocalizedString(@"fb_tv", @"fuel brand"),
                             NSLocalizedString(@"fs_tv", @"filling station"),
                             NSLocalizedString(@"notes_tv", @"Notes"),
                             NSLocalizedString(@"attach_receipt", @"attach receipt"), nil];
        
        
//        self.arrayaddedtext=[[NSMutableArray alloc]initWithObjects:@"Date",@"Odometer",@"Qty",@"Partial Tank",@"Missed Previous Fill up",@"Price/Unit",@"Total Cost",@"Octane",@"Fuel Brand",@"Filling station",@"Notes",@"Attach receipt", nil];

    }
    if(self.arrayaddedtext.count==11)
    {
        
        self.arrayaddedtext=[[NSMutableArray alloc]initWithObjects:
                             NSLocalizedString(@"date", @"Date"),
                             NSLocalizedString(@"odometer", @"Odometer"),
                             NSLocalizedString(@"qty_required", @"Qty"),
                             NSLocalizedString(@"pf_tv", @"partial tank"),
                             @"",
                             NSLocalizedString(@"prc_per_unt", @"price/unit"),
                             NSLocalizedString(@"tc_tv", @"Total cost"),
                             NSLocalizedString(@"octane", @"Octane"),
                             NSLocalizedString(@"fb_tv", @"fuel brand"),
                             NSLocalizedString(@"fs_tv", @"filling station"),
                             NSLocalizedString(@"notes_tv", @"Notes"),
                             NSLocalizedString(@"attach_receipt", @"attach receipt"), nil];
        
//        self.arrayaddedtext=[[NSMutableArray alloc]initWithObjects:@"Date",@"Odometer",@"Qty",@"Partial Tank",@"",@"Price/Unit",@"Total Cost",@"Octane",@"Fuel Brand",@"Filling station",@"Notes",@"Attach receipt", nil];
        
    }
    
    self.textplace=[[NSMutableArray alloc]initWithObjects:
                    NSLocalizedString(@"date", @"Date"),
                    NSLocalizedString(@"odometer", @"Odometer"),
                    NSLocalizedString(@"qty_required", @"Qty"),
                    NSLocalizedString(@"pf_tv", @"partial tank"),
                    NSLocalizedString(@"mf_tv", @"missed prev fillup"),
                    NSLocalizedString(@"prc_per_unt", @"price/unit"),
                    NSLocalizedString(@"tc_tv", @"Total cost"),
                    NSLocalizedString(@"octane", @"Octane"),
                    NSLocalizedString(@"fb_tv", @"fuel brand"),
                    NSLocalizedString(@"fs_tv", @"filling station"),
                    NSLocalizedString(@"notes_tv", @"Notes"),
                    NSLocalizedString(@"attach_receipt", @"attach receipt"), nil];

//     self.textplace=[[NSMutableArray alloc]initWithObjects:@"Date",@"Odometer",@"Qty",@"Partial Tank",@"Missed Previous Fill up",@"Price/Unit",@"Total Cost",@"Octane",@"Fuel Brand",@"Filling station",@"Notes",@"Attach receipt", nil];
   
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

-(void)viewDidAppear:(BOOL)animated
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

-(BOOL)shouldAutorotate
{
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
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
        if(indexPath.row==0|| indexPath.row==1 || indexPath.row ==2)
        {
            cell.slideswitch.userInteractionEnabled=NO;
            
            //NSString *required = @"(req)";
            cell.titlename.text = [NSString stringWithFormat:@"%@ %@", [self.textplace objectAtIndex:indexPath.row],  NSLocalizedString(@"req", @"req")];
            
            //cell.titlename.text =[NSString stringWithFormat:@"%@ (req)",[self.textplace objectAtIndex:indexPath.row]];
        }
        else
        {
            cell.titlename.text =[self.textplace objectAtIndex:indexPath.row];
            
            //Swapnil BUG_91
            if([cell.titlename.text isEqualToString: @"Attach receipt"]){
                if([self.arrayaddedtext containsObject:@"Attach reciept"]){
                    [self.arrayaddedtext replaceObjectAtIndex:indexPath.row withObject:@"Attach receipt"];
                }
            }
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
          
             [self.arrayaddedtext replaceObjectAtIndex:cell.slideswitch.tag withObject:cell.titlename.text];
        }
        
        else
        {
            
            [self.arrayaddedtext replaceObjectAtIndex:cell.slideswitch.tag withObject:@""];
           
        }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.arrayaddedtext forKey:@"arrayvalue"];
    
   // NSLog(@"Will disappear arrayvalue: %@", self.arrayaddedtext );
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
