//
//  CustomSpecificationsController.m
//  
//
//  Created by Swapnil on 27/07/17.
//
//

#import "CustomSpecificationsController.h"
#import "AddSpecifications.h"

//This is Add Specifications View
@interface CustomSpecificationsController ()

@end

@implementation CustomSpecificationsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.specsView.layer setCornerRadius:5.0f];
    
    // border
    [self.specsView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.specsView.layer setBorderWidth:0.5f];
    self.alertLabel.hidden = YES;
    
    [self.addButton.layer setCornerRadius:5.0f];
    [self.addButton.layer setBorderWidth:1.0f];
    [self.addButton.layer setBorderColor:[UIColor blackColor].CGColor];
    
    [self.cancelButton.layer setCornerRadius:5.0f];
    [self.cancelButton.layer setBorderWidth:1.0f];
    [self.cancelButton.layer setBorderColor:[UIColor blackColor].CGColor];
    
    self.nameField.delegate = self;
    self.valueField.delegate = self;
    
    if(self.addSpecArr == nil){
        self.addSpecArr = [[NSMutableArray alloc] init];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    if(self.isEdit){
        
        //If Edit change heading to Edit
        //NSString *edit_custom_parts = @"Edit Specifications";
        self.headingLabel.text = NSLocalizedString(@"edit_custom_parts", @"Edit specifications");
        self.nameField.text = self.nameString;
        self.valueField.text = self.valueString;
    } else {
        
        //change heading to Add
        //NSString *add_custom_parts = @"Add Specifications";
        self.headingLabel.text = NSLocalizedString(@"add_custom_parts", @"add specs");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
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

#pragma mark ADD, CANCEL METHODS

- (IBAction)cancelPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addPressed:(id)sender {
    

    if(self.nameField.text.length == 0 || self.valueField.text.length == 0){
        
        //Both fields are mandatory
        [self.alertLabel setHidden:NO];
    } else {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        //Edit a field
        if(self.isEdit){
            
            [dict setObject:self.nameField.text forKey:@"name"];
            [dict setObject:self.valueField.text forKey:@"value"];
            [self.addSpecArr replaceObjectAtIndex:self.valueIndex withObject:dict];
        }
        
        else {
        
            //Add new field
            [dict setObject:self.nameField.text forKey:@"name"];
            [dict setObject:self.valueField.text forKey:@"value"];
        
            [self.addSpecArr addObject:dict];
        }
        //NSLog(@"self.addSpecArr : %@", self.addSpecArr);
        AddSpecifications *addSpecVc = [[AddSpecifications alloc] init];
        addSpecVc.customSpecsArray = self.addSpecArr;
        [[NSUserDefaults standardUserDefaults] setObject:self.addSpecArr forKey:@"customArray"];
        
        //NSLog(@"aDDSPEC : %@", self.addSpecArr);
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"entriesChanged"];
        [self.alertLabel setHidden:YES];
        
        
        [self dismissViewController:nil message:@""];
    }
}


- (void)dismissViewController:(id)sender message:(NSString*) message
{
    
    [self dismissViewControllerAnimated:YES completion:^
     {
         // MAKE THIS CALL
         self.onDismiss(self, message);
     }];
}

#pragma mark UITEXTFIELD DELEGATE METHODS

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(textField == self.nameField){
        
        textField.placeholder = @"";
        if([textField.text containsString:@","]){
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"part_name", @"Name"), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
    }
    
    if(textField == self.valueField){
        
        textField.placeholder = @"";
        if([textField.text containsString:@","]){
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle: [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"part_val", @"Value"), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }

    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField == self.nameField){
        
        textField.placeholder = @"";
        if([textField.text containsString:@","]){
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"part_name", @"Name"), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
    }
    
    if(textField == self.valueField){
        
        textField.placeholder = @"";
        if([textField.text containsString:@","]){
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"part_val", @"Value"), NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertControl addAction:ok];
            [self presentViewController:alertControl animated:YES completion:nil];
            NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = Stringval;
        }
        
    }
    return YES;
}



@end
