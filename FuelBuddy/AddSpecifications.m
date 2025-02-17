//
//  AddSpecifications.m
//  FuelBuddy
//
//  Created by Swapnil on 28/07/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "AddSpecifications.h"
#import "CustomSpecificationsController.h"
#import "VehicleaddViewController.h"

//This is Custom Specifications View

@interface AddSpecifications ()


@end

@implementation AddSpecifications


#pragma mark GENERAL METHODS

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addclick)];
    
    self.specificationTable.delegate = self;
    self.specificationTable.dataSource = self;
    
    self.specificationTable.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.specificationTable.separatorColor =[UIColor darkGrayColor];
    
    self.customSpecsArray = [[NSMutableArray alloc] init];
    self.tempArray = [[NSMutableArray alloc] init];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //If it is Edit Vehicle
    if([[def objectForKey:@"save"]isEqualToString:@"Edit"]){
        
        //self.custSpec populated from vehiceAddVC
        //Separate by comma and add in nameValArray
        NSArray *nameValArray = [self.custSpec componentsSeparatedByString:@","];
       // NSLog(@"arr : %@", nameValArray);
        
        if(nameValArray.count != 0){
            
        //loop through nameValArray as it now contains unique specifications
        for(int i = 0; i < nameValArray.count; i++){
        
            //Take out name, value objects of nameValArray and set to dictionary
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[[[nameValArray objectAtIndex:i] componentsSeparatedByString:@":::"] firstObject] forKey:@"name"];
            if([[nameValArray objectAtIndex:i] componentsSeparatedByString:@":::"].count>1){

                [dict setObject:[[[nameValArray objectAtIndex:i] componentsSeparatedByString:@":::"] objectAtIndex:1] forKey:@"value"];

            }else{
                [dict setObject:@"" forKey:@"value"];
            }

            //NSLog(@"Specifications dict : %@", dict);
            //Add dict to self.customSpecsArray
            [self.customSpecsArray addObject:dict];
            }
        }
    
        //NSLog(@"edited : %@", self.customSpecsArray);
    }
    
    //[self viewDidAppear:YES];
    
    //reload table data with data already present for that vehicle
    [self.specificationTable reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([def boolForKey:@"entriesChanged"] == YES){
        
        self.customSpecsArray = [[def objectForKey:@"customArray"] mutableCopy];
    }
    [self.specificationTable reloadData];
    [super viewWillAppear:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //If new specifications are added they are populated in self.customSpecsArray from CustomSpecificationVC
    //NSLog(@"specs arr : %@", self.customSpecsArray);
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    //reload data with newly added fields
    [self.specificationTable reloadData];
    
    //set self.customSpecsArray with complete specs of a vehicle to user defaults for database entry
    //[def setObject:self.customSpecsArray forKey:@"customArray"];

}

- (void)viewWillDisappear:(BOOL)animated{
    
    
}

- (BOOL)shouldAutorotate{
    
    return NO;
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

#pragma mark ADD, BACK BUTTON METHODS

- (void)addclick{
    
    CustomSpecificationsController *customVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomSpecifications"];
    
    customVC.addSpecArr = self.customSpecsArray;
    
    //callback function of customVC
    customVC.onDismiss = ^(UIViewController *sender, NSString* message)
    {
        // Do your stuff after dismissing the modal view controller
        //NSLog(@"Modal dissmissed");
        
        [self viewDidAppear:YES];
    };
    
    //Present CustomVC
    customVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:customVC animated:YES completion:nil];
}

- (void)backbuttonclick{
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark UITABLEVIEW METHODS

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.customSpecsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"] ;
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    cell.textLabel.text = [[self.customSpecsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text = [[self.customSpecsArray objectAtIndex:indexPath.row] objectForKey:@"value"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Edit a particular field
    CustomSpecificationsController *customVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomSpecifications"];
    
    customVC.addSpecArr = self.customSpecsArray;
    //NSLog(@"custom specArr = %@", self.customSpecsArray);
    customVC.isEdit = YES;
    customVC.nameString = [[self.customSpecsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
    customVC.valueString = [[self.customSpecsArray objectAtIndex:indexPath.row] valueForKey:@"value"];
    
    //Pass rowNo to customVC to replace object at that row
    customVC.valueIndex = indexPath.row;
    //NSLog(@"nameField : %@, valueField : %@", customVC.nameString, customVC.valueString);
    
    customVC.onDismiss = ^(UIViewController *sender, NSString* message)
    {
        // Do your stuff after dismissing the modal view controller
        //NSLog(@"Modal dissmissed");
        
        [self viewDidAppear:YES];
    };
    customVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:customVC animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Deleting a field
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.customSpecsArray removeObjectAtIndex:indexPath.row];
        
        [self.specificationTable beginUpdates];
        [self.specificationTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.specificationTable endUpdates];
    }
    
    //Setting user defaults after deletion
    [[NSUserDefaults standardUserDefaults] setObject:self.customSpecsArray forKey:@"customArray"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"entriesChanged"];
    
}


@end
