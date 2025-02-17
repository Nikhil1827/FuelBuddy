//
//  SupportViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 03/04/19.
//  Copyright © 2019 Oraganization. All rights reserved.
//

#import "SupportViewController.h"
#import "commonMethods.h"
#import "WebServiceURL's.h"
#import "Reachability.h"
#import "AppDelegate.h"

@interface SupportViewController (){


    UILabel *emailTitleLabel;
    UITextField *emailField;
    UITextView *messageTextView;
    BOOL validEmail;
    UIButton *submitBtn;
}

@end

@implementation SupportViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpView];
}

-(void)setUpView{

    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    //Support Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-15, 60, 30, 30)];
    imageView.image = [UIImage imageNamed:@"ic_support"];
    imageView.layer.masksToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    [self.view addSubview:imageView];

    //Hi How are you
    UILabel *hiLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-100, imageView.frame.origin.y+40, 200, 40)];
    hiLabel.text = NSLocalizedString(@"support_msg", @"Hi! How can we help?");
    hiLabel.textColor = UIColor.whiteColor;
    hiLabel.textAlignment = NSTextAlignmentCenter;
    [hiLabel setFont:[UIFont systemFontOfSize:17]];

    [self.view addSubview:hiLabel];

    //Email Title Label
    emailTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, hiLabel.frame.origin.y+70, 100, 30)];
    emailTitleLabel.textColor = UIColor.whiteColor;
    emailTitleLabel.text = NSLocalizedString(@"email", @"Email");
    [emailTitleLabel setFont:[UIFont systemFontOfSize:16]];

    [self.view addSubview:emailTitleLabel];

    //Email field
    emailField = [[UITextField alloc] initWithFrame:CGRectMake(20, emailTitleLabel.frame.origin.y+26, self.view.frame.size.width-40, 30)];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"email", @"Email") attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];

    emailField.attributedPlaceholder = str;
    emailField.delegate = self;
    emailField.textColor = UIColor.whiteColor;

    [self.view addSubview:emailField];

    emailTitleLabel.hidden = true;

    //emailfield underline
    UIView *emailUnderline = [[UIView alloc] initWithFrame:CGRectMake(emailField.frame.origin.x, emailField.frame.origin.y+28, emailField.frame.size.width, 0.65)];
    emailUnderline.backgroundColor = UIColor.lightGrayColor;

    [self.view addSubview:emailUnderline];

    //Message Label
    UILabel *messageTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, emailUnderline.frame.origin.y+30, emailUnderline.frame.size.width, 30)];
    messageTitleLabel.text = NSLocalizedString(@"message", @"Message");
    messageTitleLabel.textColor = UIColor.whiteColor;
    messageTitleLabel.textAlignment = NSTextAlignmentLeft;
    [messageTitleLabel setFont:[UIFont systemFontOfSize:16]];

    [self.view addSubview:messageTitleLabel];

    //Message TextView
    messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, messageTitleLabel.frame.origin.y+32, self.view.frame.size.width-40, 120)];
    messageTextView.backgroundColor = UIColor.clearColor;
    messageTextView.textColor = UIColor.whiteColor;
    messageTextView.delegate = self;

    [self.view addSubview:messageTextView];


    //Message underline
    UIView *messageUnderline = [[UIView alloc] initWithFrame:CGRectMake(messageTextView.frame.origin.x, messageTextView.frame.origin.y+121, emailField.frame.size.width, 0.65)];
    messageUnderline.backgroundColor = UIColor.lightGrayColor;

    [self.view addSubview:messageUnderline];

    //Submit Button
    submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, messageUnderline.frame.origin.y+30, emailField.frame.size.width, 40)];
    submitBtn.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(202/255.0) blue:(29/255.0) alpha:1];
    [submitBtn setTitle:NSLocalizedString(@"submit", @"Submit") forState:UIControlStateNormal];
    submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [submitBtn setTitleColor:UIColor.blackColor forState: UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitClicked) forControlEvents:UIControlEventTouchUpInside];
    submitBtn.userInteractionEnabled = NO;
    [self.view addSubview:submitBtn];

    //Cancel Button
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, submitBtn.frame.origin.y+60, emailField.frame.size.width, 40)];
    cancelBtn.backgroundColor = UIColor.darkGrayColor;//[UIColor colorWithRed:221 green:221 blue:221 alpha:1];
    [cancelBtn setTitle:NSLocalizedString(@"cancel", @"Cancel") forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [cancelBtn setTitleColor:UIColor.blackColor forState: UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:cancelBtn];
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)submitClicked{

    if(emailField.text != nil || emailField.text.length == 0){

        validEmail = [self validateEmail];

        if(validEmail){

            [self startActivitySpinner:@"Sending Mail"];
            [self submitSupport];

        }else{

            NSString *message = NSLocalizedString(@"enter_valid_email",@"Please enter proper email address");
            NSString *title = NSLocalizedString(@"invalid_email",@"Invalid Email");
            [self showAlert:title :message];
        }

    }else{

        NSString *message = NSLocalizedString(@"enter_valid_email",@"Please enter proper email address");
        NSString *title = NSLocalizedString(@"invalid_email",@"Invalid Email");
        [self showAlert:title :message];

    }


}

-(void)cancelClicked{

    [self dismissViewControllerAnimated:YES completion:nil];

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

- (void)startActivitySpinner: (NSString *)labelText {
    // [[self driveService] setAuthorizer:auth];

    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.loadingView = [[UIView alloc]initWithFrame:CGRectMake(app.result.width/2-50, app.result.height/2-50, 100, 100)];
    self.loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    self.loadingView.layer.cornerRadius = 5;

    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(_loadingView.frame.size.width / 2.0, 35);

    [activityView startAnimating];

    activityView.tag = 100;
    [self.loadingView addSubview:activityView];

    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(3, 48, 100, 50)];
    lblLoading.text = labelText;
    lblLoading.numberOfLines = 2;
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:13];
    lblLoading.textAlignment = NSTextAlignmentCenter;

    [self.loadingView addSubview:lblLoading];
    [self.view addSubview:self.loadingView];

}


#pragma mark - Submit Script

-(void)submitSupport{

    //{"email":"mrigaen@gmail.com","subject":"Free User: Support Message","msg":"Blah blah blah.","os":"android"}

    NSString *userEmail = emailField.text;
    BOOL platinum = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSubscribed"];
    BOOL golden = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAdDisabled"];

    NSString *subject;

    if(platinum){

        subject = @"Platinum User: Support Message";
    }else if(golden){

        subject = @"Gold User: Support Message";
    }else{

        subject = @"Free User: Support Message";
    }

    NSString *msg = messageTextView.text;

    NSString *os = @"ios";

    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];

    [parametersDictionary setObject:userEmail forKey:@"email"];
    [parametersDictionary setObject:subject forKey:@"subject"];
    [parametersDictionary setObject:msg forKey:@"msg"];
    [parametersDictionary setObject:os forKey:@"os"];

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSError *err;
    NSData *postDataArray = [NSJSONSerialization dataWithJSONObject:parametersDictionary options:NSJSONWritingPrettyPrinted error:&err];

    commonMethods *common = [[commonMethods alloc]init];
    [def setBool:NO forKey:@"updateTimeStamp"];
    [common saveToCloud:postDataArray urlString:kSupportScript success:^(NSDictionary *responseDict) {

        NSLog(@"ResponseDict is : %@", responseDict);

        if([[responseDict objectForKey:@"success"]  isEqual: @1]){

            NSString *message = NSLocalizedString(@"support_sent", @"Thank you! We will be in touch with you shortly.");

            dispatch_async(dispatch_get_main_queue(),^{

                [self showAlert:@"" :message];
                [self.loadingView removeFromSuperview];

            });

        }else {

            NSString *message = NSLocalizedString(@"support_send_err", @"Sorry, there was an issue submitting. Please try to mail us directly at support-ios@simplyauto.app.");

            dispatch_async(dispatch_get_main_queue(),^{

                [self showAlert:@"" :message];
                [self.loadingView removeFromSuperview];

            });

        }

    } failure:^(NSError *error) {

        NSString *message = NSLocalizedString(@"support_send_err", @"Sorry, there was an issue submitting. Please try to mail us directly at support-ios@simplyauto.app.");

        dispatch_async(dispatch_get_main_queue(),^{

            [self showAlert:@"" :message];
            [self.loadingView removeFromSuperview];

        });
        // NSLog(@"friend Response failed");
    }];

}

#pragma mark - UITextField Delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField{

   // [self paddingTextFields:textField];
    emailTitleLabel.hidden = NO;
    emailField.placeholder = @"";
    textField.returnKeyType = UIReturnKeyDone;
}

//- (void) paddingTextFields: (UITextField *)textField{
//
//    UIView *padding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4.8, 20)];
//    textField.leftView = padding;
//    textField.leftViewMode = UITextFieldViewModeAlways;
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    validEmail = [self validateEmail];

    if(validEmail){

        submitBtn.userInteractionEnabled = YES;

    }else{

        NSString *message = NSLocalizedString(@"enter_valid_email",@"Please enter proper email address");
        NSString *title = NSLocalizedString(@"invalid_email",@"Invalid Email");
        [self showAlert:title :message];
        submitBtn.userInteractionEnabled = NO;
    }


    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason{

    if(textField.text.length == 0){
        emailTitleLabel.hidden = YES;
        emailField.placeholder = NSLocalizedString(@"email", @"Email");
    }else{
        emailTitleLabel.hidden = NO;
    }
}

-(BOOL)validateEmail{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if ([emailTest evaluateWithObject:emailField.text] == YES)
    {

        return YES;
    }
    else
    {

        return NO;
    }
}

#pragma mark - UITextView Delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView{

    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-150, self.view.frame.size.width, self.view.frame.size.height)];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{

    if ([text isEqualToString:@"\n"]) {

        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }

    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{

    [self.view setFrame:CGRectMake(self.view.frame.origin.x,0, self.view.frame.size.width, self.view.frame.size.height)];
    if([textView.text isEqualToString:@""]){

        NSString *message = NSLocalizedString(@"msg_err",@"Please enter a message to send to us");
        NSString *title = @"";
        [self showAlert:title :message];
        submitBtn.userInteractionEnabled = NO;
    }else{
        submitBtn.userInteractionEnabled = YES;
    }
}

@end
