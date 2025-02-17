//
//  CloudHelpTableVC.m
//  FuelBuddy
//
//  Created by Swapnil on 12/11/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "CloudHelpTableVC.h"
#import "CloudHelpSelectionVC.h"
#import "SyncAcrossHelpVC.h"
#import "BackupToCloudVC1.h"

@interface CloudHelpTableVC ()
{
    NSArray *tableContent;
}
@end

@implementation CloudHelpTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"slideOutOn"];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.topItem.title= NSLocalizedString(@"cloud_help", @"Cloud Help");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    
    self.cloudHelpTable.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    [self.cloudHelpTable setSeparatorColor:[UIColor darkGrayColor]];
    [self.cloudHelpTable setScrollEnabled:NO];
    
    
    tableContent = [[NSArray alloc] initWithObjects:NSLocalizedString(@"help_backup", @"Backup to cloud"),
                    NSLocalizedString(@"help_web", @"Simply Auto web"),
                    NSLocalizedString(@"help_multi_devices", @"Sync between multiple devices"), nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate {
    return NO;
}

-(void)backbuttonclick
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


#pragma mark Table view Datasource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return tableContent.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(cell == nil){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [tableContent objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
        
        //Backup to cloud
        
        BackupToCloudVC1 *backupCloud1 = (BackupToCloudVC1 *)[self.storyboard instantiateViewControllerWithIdentifier:@"backupToCloud1"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            backupCloud1.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:backupCloud1 animated:YES completion:^{
                
            }];
            
        });
    }
    
    if(indexPath.row == 1){
        
        //Fuel Buddy web
        
        CloudHelpSelectionVC *selectionVC = (CloudHelpSelectionVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"cloudHelpSelections"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            selectionVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:selectionVC animated:YES completion:^{
            
            }];
            
        });

        
    }
    
    if(indexPath.row == 2){
        
        //Sync across multiple devices
        
        SyncAcrossHelpVC *selectionVC = (SyncAcrossHelpVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"syncAcross"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            selectionVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:selectionVC animated:YES completion:nil];
            
        });
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 55.0;
}


@end
