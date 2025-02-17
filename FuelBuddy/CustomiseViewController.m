//
//  CustomiseViewController.m
//  FuelBuddy
//
//  Created by Surabhi on 23/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "CustomiseViewController.h"
#import "AppDelegate.h"
#import "CustomiseFillupViewController.h"
@interface CustomiseViewController ()

@end

//Swapnil 15 Mar-17
//static GADMasterViewController *shared;
@implementation CustomiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    
    //NSString *cust_fus_head = @"Customize Fill up";
    self.navigationItem.title=[NSLocalizedString(@"cust_fus_head", @"customize fillup") capitalizedString];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];

    self.view.backgroundColor = [self colorFromHexString:@"#303030"];
    
//    NSString *cust_fu_head = @"Select input fields";
//    NSString *odo_trip_tv = @"VALUE TO ENTER DURING FILL UP";
//    NSString *trp_distance = @"Trip Distance";
//    NSString *pv_msg = @"Copy values from previous fill-up";
//    NSString *atuo_brand_fs_msg = @"Auto detect Filling Station and Brand based on location";
    
    
    self.addvalues = [[NSMutableArray alloc]initWithObjects:
                      NSLocalizedString(@"cust_fu_head", @"select input fields"),
                      NSLocalizedString(@"odo_trip_tv", @"value to enter during fillup"),
                      NSLocalizedString(@"odometer", @"Odometer"),
                      NSLocalizedString(@"trp_distance", @"trip distance"),
                      @"",
                      NSLocalizedString(@"pv_msg", @"copy values from prev fillup"),
                      NSLocalizedString(@"atuo_brand_fs_msg", @"auto detect"),@"Automatically add .009 to the fuel price",nil];
    
//    self.addvalues = [[NSMutableArray alloc]initWithObjects:@"Select input fields",@"VALUE TO ENTER DURING FILL UP",@"odometer",@"Trip Distance",@"",@"Copy values from previous fill-up", @"Auto detect Filling Station and Brand based on location",nil];
    [[NSUserDefaults standardUserDefaults]setObject:@"yes" forKey:@"reloadtext"];
    [self addview];
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

-(BOOL)shouldAutorotate
{
    return NO;
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


-(void)addview
{
    AppDelegate *app = [AppDelegate sharedAppDelegate];
    self.result=app.result;
    //NIKHIL //select field stays up in X y=60;
    int y=self.navigationController.navigationBar.frame.size.height+50;
    for(int i= 0; i<self.addvalues.count;i++)
    {
        UIButton *button = [[UIButton alloc]init];
        
        //Swapnil ENH_11
        if(i == 6 || i == 7){
            button.frame = CGRectMake(0, y, self.result.width, 61);
        } else {
            button.frame = CGRectMake(0,y,self.result.width,51);
        }
        button.tag=i;
        // button.backgroundColor =[UIColor blackColor];
        button.userInteractionEnabled=YES;
        [self viewsetting:button];
        [self.view addSubview:button];
        
        
        if(button.tag==2 || button.tag==3 || button.tag==5 || button.tag == 6 || button.tag == 7)
        {
            UIButton *check = [[UIButton alloc]init];
            check.frame = CGRectMake(10, 5, 40, 40);
            if(button.tag==2)
            {
                //Changed the object type bcuz it is causing langaue issues
                //                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"filluptype"]isEqualToString:NSLocalizedString(@"odometer", @"Odometer")] || [[NSUserDefaults standardUserDefaults]objectForKey:@"filluptype"]==nil)
                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"filluptype"]isEqualToString:@"odometer"] || [[NSUserDefaults standardUserDefaults]objectForKey:@"filluptype"]==nil)
                {
                    check.selected=YES;
                }
                check.tag=-1;
            }
            else if(button.tag==3)
            {
                //Changed the object type bcuz it is causing langaue issues
                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"filluptype"]isEqualToString:@"Trip"])
                {
                    check.selected=YES;
                }
                check.tag=-2;
            }
            
            //Swapnil ENH_11
            else if (button.tag == 6){
                
                //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                //NSLog(@"autoLoc = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"autoDetectLoc"]);
                
                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"autoDetectLoc"]  isEqual: @"YES"]){
                    check.selected = YES;
                }
                check.tag = -6;
            }
            else if(button.tag==7)
            {

                check.frame = CGRectMake(10, 15, 40, 40);
                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"autoAdd009"]  isEqual: @"YES"]){
                    check.selected = YES;
                }
                check.tag=-7;
            }

            else if(button.tag==5)
            {
                if([[[NSUserDefaults standardUserDefaults]objectForKey: @"copyvalues"]isEqualToString:@"copy"])
                {
                    check.selected=YES;
                }
            }
            [check setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
            [check setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
            [check addTarget:self action:@selector(checkclick:) forControlEvents:UIControlEventTouchUpInside];
            [button addSubview:check];
            
        }
        if(button.tag==1 || button.tag==4)
        {
            button.backgroundColor=[self colorFromHexString:@"#2c2c2c"];
        }
        if(button.tag==0 || button.tag==3)
        {
            
            UIView *bottom = [[UIView alloc]init];
            bottom.frame = CGRectMake(0,button.frame.size.height-2,button.frame.size.width, 1);
            bottom.backgroundColor =[UIColor darkGrayColor];
            [button addSubview:bottom];
        }
        
        if (button.tag==0) {
            UIButton *nextclick = [[UIButton alloc]init];
            nextclick.frame = CGRectMake(button.frame.size.width-30, 10, 40, 40);
            [nextclick setImage:[UIImage imageNamed:@"chevron"] forState:UIControlStateNormal];
            [button addSubview:nextclick];
            [nextclick addTarget:self action:@selector(customise) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(customise) forControlEvents:UIControlEventTouchUpInside];
        }

        y=y+50;
    }

    
}

-(void)customise
{
    
    CustomiseFillupViewController *custom = (CustomiseFillupViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"customfill"];
    custom.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:custom animated:YES];
}

-(void)checkclick:(UIButton *)sender
{
    NSUserDefaults *def =[NSUserDefaults standardUserDefaults];
    if(sender.tag==-1)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag:-2];
        if(sender.selected == YES)
        {

            button.selected=YES;
            sender.selected=NO;
        }

        else
        {
            //Changed the object type bcuz it is causing langauge issues
            [def setObject:@"odometer" forKey:@"filluptype"];
            button.selected=NO;
            sender.selected=YES;
        }

    }
    
    else if(sender.tag==-2)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag:-1];
        if(sender.selected == YES)
        {
            
            button.selected=YES;
            sender.selected=NO;
        }
        
        else
        {
            //Changed the object type bcuz it is causing langaue issues
            [def setObject:@"Trip" forKey:@"filluptype"];
            button.selected=NO;
            sender.selected=YES;
        }
        
    }
    
    //Swapnil ENH_11
    else if (sender.tag == -6){

        BOOL proUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];

        if(sender.selected == YES){

            sender.selected = NO;
            [def setObject:@"NO" forKey:@"autoDetectLoc"];
        } else {

            if(proUser){
                sender.selected = YES;
                [def setObject:@"YES" forKey:@"autoDetectLoc"];
            }else{

                NSString *title = @"Auto Detection";
                NSString *message = @"In the free version Simply Auto can auto detect filling station and brand by matching your current location with the location of previously filled out records by you. Whereas, in the pro version Simply Auto will auto detect filling stations by searching for them on the internet.";
                [def setObject:@"NO" forKey:@"autoDetectLoc"];
                [self showAlert:title :message];
            }

        }
    }else if(sender.tag==-7)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag:-7];
        if(sender.selected == YES)
        {

            [def setObject:@"NO" forKey:@"autoAdd009"];
            button.selected=YES;
            sender.selected=NO;
        }

        else
        {

            [def setObject:@"YES" forKey:@"autoAdd009"];
            button.selected=NO;
            sender.selected=YES;
        }

    }

    else
    {

        if(sender.selected == YES)
        {
            
            sender.selected=NO;
            [def setObject:@"dontcopy" forKey:@"copyvalues"];
        }
        
        else
        {

            sender.selected=YES;
            [def setObject:@"copy" forKey:@"copyvalues"];

        }

        
    }

}

-(void)showAlert:(NSString *)title :(NSString *) message{

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

-(void)viewsetting: (UIButton *)setview
{
    
    //NSLog(@"tag value %ld",(long)setview.tag);
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 0.5;
    border.borderColor = [UIColor darkGrayColor].CGColor;
    
    if(setview.tag==2)
    {
        border.frame = CGRectMake(60, setview.frame.size.height - 0.5, setview.frame.size.width, setview.frame.size.height);
    }
    
    else
    {
        border.frame = CGRectMake(0, setview.frame.size.height - 0.5, setview.frame.size.width, setview.frame.size.height);
    }
    border.borderWidth = borderWidth;
    [setview.layer addSublayer:border];
    setview.layer.masksToBounds = YES;
    [setview setTitle:[self.addvalues objectAtIndex:setview.tag] forState:UIControlStateNormal];
    [setview setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    setview.titleLabel.font = [UIFont systemFontOfSize:15];
    setview.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    
    [setview setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    if(setview.tag==1 || setview.tag==4)
    {
        setview.titleLabel.font = [UIFont systemFontOfSize:12];
        [setview setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        // [setview setBackgroundColor:[self colorFromHexString:@"#2c2c2c"]];
        
    }
    
    if(setview.tag==2|| setview.tag==3 || setview.tag==5)
    {
        
        [setview setTitleEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
    }
    
    if(setview.tag == 6 || setview.tag == 7){
        
        setview.titleLabel.numberOfLines = 2;
        [setview setTitleEdgeInsets:UIEdgeInsetsMake(18, 60, 0, 0)];
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
