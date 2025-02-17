//
//  AddDriverViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 18/04/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "AddDriverViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "Friends_Table.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import "Reachability.h"

@interface AddDriverViewController ()

@end
//New_7 nikhil
@implementation AddDriverViewController{
    
    BOOL validEmail;
    BOOL friendPresent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    self.searchEmailField.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    UITextField *text = [[UITextField alloc]init];
    text = self.searchEmailField;
    text.delegate = self;
    self.searchEmailField.tag = 1;
    [self textfieldsetting:text];
     self.viewUnderline.hidden = YES;
     self.requestedLabel.hidden = YES;
     self.buttonImage.hidden = YES;
    [self fetchDrivers];
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

-(void)viewWillDisappear:(BOOL)animated{
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"doSignIn"];
    
}

#pragma mark search_friend method
-(void)searchFriendScript:(NSString *) emailString{
   
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    [parametersDictionary setObject:emailString forKey:@"name"];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSError *err;
    NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];
    
    commonMethods *common = [[commonMethods alloc]init];
    [def setBool:NO forKey:@"updateTimeStamp"];
    [common saveToCloud:postDataArray urlString:kSearchFriendScript success:^(NSDictionary *responseDict) {

        //NSLog(@"ResponseDict is : %@", responseDict);
        
        if(![[[responseDict valueForKey:@"arr_email"] objectAtIndex:0]  isEqual: @"no records found"]){
           
            dispatch_async(dispatch_get_main_queue(),^{
            
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                self.driverEmailLabel.text = [[responseDict valueForKey:@"arr_email"] objectAtIndex:0];
                self.driverNameLabel.text = [[responseDict valueForKey:@"arr_name"] objectAtIndex:0];
                self.viewUnderline.hidden = NO;
                self.buttonImage.hidden = NO;
                
                self.friendDictionary = [[NSMutableDictionary alloc]init];
                [self.friendDictionary setObject:[[responseDict valueForKey:@"arr_name"] objectAtIndex:0] forKey:@"arr_name"];
                [self.friendDictionary setObject:[[responseDict valueForKey:@"arr_email"] objectAtIndex:0] forKey:@"arr_email"];
                //NSLog(@"friendDictionary is : %@", self.friendDictionary);
                
            });
           
        }else{
            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            
                //Review : to get actual copy from android
                NSString *message = @"No result found for the email address";
                NSString *title = @"No result";
                [self showAlert:title :message];
            });
            
        }
  
    } failure:^(NSError *error) {
        
       // NSLog(@"friend Response failed");
    }];
   
}

- (BOOL)checkNetwork{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable){
        dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showAlertAndDismiss:@"Failed to Search" message:@"Please check your internet connection and try again later"];
             });
        return NO;
    } else {
        
        return  YES;
    }
}

- (void)showAlertAndDismiss: (NSString *)title message:(NSString *)message{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)checkFriendStatus {
    
    NSString *statusRequested = @"request sent";
    NSString *statusConfirmed = @"confirm";
    //Review : change to textbox.text
    NSString *currentEmail = self.searchEmailField.text;
     for(int i=0; i<self.friendsArray.count; i++){
        //NSLog(@"currentEmail arr_email ::%@",currentEmail);
        //NSLog(@"self.friendsArray Email ::%@",[[self.friendsArray objectAtIndex:i] valueForKey:@"Email"]);
        if([currentEmail isEqualToString: [[self.friendsArray objectAtIndex:i] valueForKey:@"Email"]]){
            
            self.driverEmailLabel.text = [[self.friendsArray objectAtIndex:i] valueForKey:@"Email"];
            self.driverNameLabel.text = [[self.friendsArray objectAtIndex:i] valueForKey:@"Name"];
            
            if([[[self.friendsArray objectAtIndex:i] valueForKey:@"Status"] isEqual: statusRequested]){
                
                //NSLog(@"Friend is already requested");
                
                self.requestedLabel.hidden = NO;
                self.buttonImage.hidden = YES;
            }
            else if([[[self.friendsArray objectAtIndex:i] valueForKey:@"Status"] isEqual: statusConfirmed]){
             
                //NSLog(@"Friend is already confirmed");
                self.requestedLabel.hidden = YES;
                self.buttonImage.hidden = YES;
               
            }
            
        }else{
            
            //NSLog(@"Friend is new");
            friendPresent = NO;
            
            
        }
            
      }
   
}

-(void)fetchDrivers{
    
    self.friendsArray =[[NSMutableArray alloc]init];
    
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Friends_Table"];
    NSError *err;
    NSArray *data=[contex executeFetchRequest:requset error:&err];
    
    for(Friends_Table *friend in data)
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        if(friend.name != nil){
            [dictionary setObject:friend.name forKey:@"Name"];
        }else{
            [dictionary setObject:@"" forKey:@"Name"];
        }
        if(friend.email != nil){
            [dictionary setObject:friend.email forKey:@"Email"];
        }else{
            [dictionary setObject:@"" forKey:@"Email"];
        }
        if(friend.status != nil){
            [dictionary setObject:friend.status forKey:@"Status"];
        }else{
            [dictionary setObject:@"" forKey:@"Status"];
        }
        
        [self.friendsArray addObject:dictionary];
    }
    
}

-(void)saveToFriendTable{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    Friends_Table *friendData = [NSEntityDescription insertNewObjectForEntityForName:@"Friends_Table" inManagedObjectContext:context];
    NSString *status = @"request sent";
    //NSLog(@"response Array is::%@",self.friendDictionary);
    if(![[self.friendDictionary objectForKey:@"arr_email"] isEqual:@""]){
        friendData.name = [self.friendDictionary objectForKey:@"arr_name"];
        friendData.email = [self.friendDictionary objectForKey:@"arr_email"];
        friendData.status = status;
        friendData.requested_by_me = @"1";
    
        if ([context hasChanges])
        {
           BOOL saved = [context save:&err];
           if (!saved) {
            // do some real error handling
            //CLSLog(@“Could not save Data due to %@“, error);
           }
          [[CoreDataController sharedInstance] saveMasterContext];
        }
        
    }
}

#pragma mark friend_request method
-(void)callFriendRequest:(NSMutableDictionary *) parametersDict{
    
    NSError *err;
    NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:parametersDict options:NSJSONWritingPrettyPrinted error:&err];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    commonMethods *common = [[commonMethods alloc]init];
    [def setBool:NO forKey:@"updateTimeStamp"];

    [common saveToCloud:postDataArray urlString:kFriendRequestScript success:^(NSDictionary *responseDict) {
        
        //NSLog(@"ResponseDict is : %@", responseDict);
        
        // Review : Check if in synchronized thread
        if([[responseDict valueForKey:@"success"]  isEqual: @1]){
             dispatch_async(dispatch_get_main_queue(),^{
                [self saveToFriendTable];
                 //Do any additional things if needed
             });
        }
    
    } failure:^(NSError *error) {
        
        //NSLog(@"friend request failed");
    }];
    
}

#pragma mark textfield Delegates methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
        textField.returnKeyType=UIReturnKeySearch;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    validEmail = [self validateEmail];
    
    if(validEmail){
        
        // check if email already present in table, if yes show from there itself
        [self checkFriendStatus];
        //or else call the script
        if(friendPresent == NO){
            
            if([self checkNetwork]){
               //NSLog(@"Call script from here");
               MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
               hud.mode = MBProgressHUDModeIndeterminate;
               hud.offset = CGPointMake(0,85);
               AppDelegate *App = [AppDelegate sharedAppDelegate];
               if(App.result.height == 480) {
                  hud.offset = CGPointMake(0,120);
               }
               hud.label.text = NSLocalizedString(@"searching_msg", @"Searching");
               hud.label.textColor = [self colorFromHexString:@"#FFCA1D"];
               hud.bezelView.backgroundColor = [UIColor clearColor];
               hud.bezelView.alpha =0.6;
            
              NSString *userEmail = self.searchEmailField.text;
                [self performSelectorInBackground:@selector(searchFriendScript:) withObject:userEmail];
            }
        }
        
        
    }else{
        
        NSString *message = NSLocalizedString(@"enter_valid_email",@"Please enter proper email address");
        NSString *title = NSLocalizedString(@"invalid_email",@"Invalid Email");
        [self showAlert:title :message];
    }
   
    
    return YES;
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

-(void)textfieldsetting: (UITextField *)textfield{
   
    //[textfield setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    NSMutableAttributedString *placeholderAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:textfield.attributedPlaceholder];
    [placeholderAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [placeholderAttributedString length])];
    textfield.attributedPlaceholder = placeholderAttributedString;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//NIKHIL for validating email

 -(BOOL)validateEmail{
      NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
      NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
      if ([emailTest evaluateWithObject:self.searchEmailField.text] == YES)
        {
          //NSLog(@"valid email format");
            return YES;
        }
      else
       {
          //NSLog(@"email not in proper format");
           return NO;
       }
 }
 

- (IBAction)requestButtonClicked:(id)sender {
    
    self.requestedLabel.hidden = NO;
    self.buttonImage.hidden = YES;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    
    [parametersDictionary setObject:[def objectForKey:@"UserEmail"] forKey:@"email1"];
    [parametersDictionary setObject:[def objectForKey:@"UserName"] forKey:@"name1"];
    [parametersDictionary setObject:self.driverEmailLabel.text forKey:@"email2"];
    [parametersDictionary setObject:self.driverNameLabel.text forKey:@"name2"];
    [parametersDictionary setObject:[def objectForKey:@"UserDeviceId"] forKey:@"androidId"];

    
    [self performSelectorInBackground:@selector(callFriendRequest:) withObject:parametersDictionary];
    
}
@end
