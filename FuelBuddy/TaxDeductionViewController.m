//
//  TaxDeductionViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 19/11/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "TaxDeductionViewController.h"
#import "CoreDataController.h"
#import "Services_Table.h"
#import "TaxDedTableViewCell.h"

@interface TaxDeductionViewController (){
    
    UIView *addTripView;
    UITextField *tripTypeTextField;
    UITextField *tripValueTextField;
    NSMutableDictionary *selectedTripTypeDict;
    NSInteger rowValue;
    
}

@end

@implementation TaxDeductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#0098AB"];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.topItem.title= NSLocalizedString(@"tax_deduction_rate",@"Tax Deduction Rate");
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
   
    UIImage *buttonImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(20,10,10,10)];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 10.0, buttonImage.size.width+4,buttonImage.size.height+4);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
   
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"add", @"Add") style:UIBarButtonItemStylePlain target:self action:@selector(addButtonPressed)];
    [self fetchTripTypes];
    [self.tripTypeTableView reloadData];
    
}

#pragma mark - GENERAL METHODS

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (IBAction)backButtonPressed: (id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)addButtonPressed{
    
    [self showAddTripView];
    
}

-(void)showAddTripView{
    
    addTripView = [[UIView alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height/2-100, self.view.frame.size.width-60, 200)];
    addTripView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:addTripView];
    
    UILabel *addtripTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 140, 30)];
    addtripTypeLabel.backgroundColor = [UIColor clearColor];
    addtripTypeLabel.textColor = [UIColor whiteColor];
    addtripTypeLabel.text = NSLocalizedString(@"pro_title_add_type", @"Add Trip Type");
    [addtripTypeLabel setFont: [addtripTypeLabel.font fontWithSize: 18]];
    [addTripView addSubview:addtripTypeLabel];
    
    tripTypeTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 50, addTripView.frame.size.width-20, 40)];
    tripTypeTextField.backgroundColor = [UIColor clearColor];
    tripTypeTextField.textColor = [UIColor whiteColor];
    tripTypeTextField.placeholder = NSLocalizedString(@"edit_trip_type_hint", @"Trip Type");
    //[tripTypeTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    NSMutableAttributedString *placeholderAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:tripTypeTextField.attributedPlaceholder];
    [placeholderAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [placeholderAttributedString length])];
    tripTypeTextField.attributedPlaceholder = placeholderAttributedString;
    tripTypeTextField.keyboardType = UIKeyboardTypeDefault;
    tripTypeTextField.returnKeyType = UIReturnKeyDone;
    
    tripTypeTextField.delegate = self;
    [addTripView addSubview:tripTypeTextField];
    
    UIView *tripfieldUnderline = [[UIView alloc] initWithFrame:CGRectMake(10, 86,addTripView.frame.size.width-20, 0.65)];
    tripfieldUnderline.backgroundColor = [UIColor lightGrayColor];
    [addTripView addSubview:tripfieldUnderline];
    
    tripValueTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 100, addTripView.frame.size.width-20, 40)];
    tripValueTextField.backgroundColor = [UIColor clearColor];
    tripValueTextField.textColor = [UIColor whiteColor];
    tripValueTextField.placeholder = @"0.0";
    //[tripValueTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    NSMutableAttributedString *placeholderString = [[NSMutableAttributedString alloc] initWithAttributedString:tripValueTextField.attributedPlaceholder];
    [placeholderString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [placeholderString length])];
    tripValueTextField.attributedPlaceholder = placeholderString;
    tripValueTextField.keyboardType = UIKeyboardTypeDecimalPad;
    tripValueTextField.returnKeyType = UIReturnKeyDone;
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.backgroundColor =[UIColor whiteColor];
    numberToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    
    [numberToolbar sizeToFit];
    tripValueTextField.inputAccessoryView = numberToolbar;
    
    tripValueTextField.delegate = self;
    [addTripView addSubview:tripValueTextField];
    
    UIView *tripValuefieldUnderline = [[UIView alloc] initWithFrame:CGRectMake(10, 136,addTripView.frame.size.width-20, 0.65)];
    tripValuefieldUnderline.backgroundColor = [UIColor lightGrayColor];
    [addTripView addSubview:tripValuefieldUnderline];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(addTripView.frame.size.width-60, addTripView.frame.size.height-40, 50, 30)];
    addButton.backgroundColor = [UIColor clearColor];
    [addButton setTitle:NSLocalizedString(@"save", @"Save") forState:UIControlStateNormal];
    [addButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(savePressed) forControlEvents:UIControlEventTouchUpInside];
    [addTripView addSubview:addButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(addButton.frame.origin.x-70, addTripView.frame.size.height-40, 60, 30)];
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton setTitle:NSLocalizedString(@"cancel", @"Cancel action") forState:UIControlStateNormal];
    [cancelButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
    [addTripView addSubview:cancelButton];
    
}

-(void)showEditTripView:(NSMutableDictionary *)editDict{
    
    addTripView = [[UIView alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height/2-100, self.view.frame.size.width-60, 200)];
    addTripView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:addTripView];
    
    UILabel *editTripTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 140, 30)];
    editTripTypeLabel.backgroundColor = [UIColor clearColor];
    editTripTypeLabel.textColor = [UIColor whiteColor];
    editTripTypeLabel.text = NSLocalizedString(@"edit_custom_type", @"Edit Trip Type");
    [editTripTypeLabel setFont: [editTripTypeLabel.font fontWithSize: 18]];
    [addTripView addSubview:editTripTypeLabel];
    
    tripTypeTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 50, addTripView.frame.size.width-20, 40)];
    tripTypeTextField.backgroundColor = [UIColor clearColor];
    tripTypeTextField.textColor = [UIColor whiteColor];
    tripTypeTextField.text = [editDict objectForKey:@"serviceName"];
    tripTypeTextField.keyboardType = UIKeyboardTypeDefault;
    tripTypeTextField.returnKeyType = UIReturnKeyDone;
    
    tripTypeTextField.delegate = self;
    [addTripView addSubview:tripTypeTextField];
    
    UIView *tripfieldUnderline = [[UIView alloc] initWithFrame:CGRectMake(10, 86,addTripView.frame.size.width-20, 0.65)];
    tripfieldUnderline.backgroundColor = [UIColor lightGrayColor];
    [addTripView addSubview:tripfieldUnderline];
    
    tripValueTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 100, addTripView.frame.size.width-20, 40)];
    tripValueTextField.backgroundColor = [UIColor clearColor];
    tripValueTextField.textColor = [UIColor whiteColor];
    tripValueTextField.text = [[editDict objectForKey:@"dueMiles"] stringValue];
    tripValueTextField.keyboardType = UIKeyboardTypeDecimalPad;
    tripValueTextField.returnKeyType = UIReturnKeyDone;
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.backgroundColor =[UIColor whiteColor];
    numberToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    
    [numberToolbar sizeToFit];
    tripValueTextField.inputAccessoryView = numberToolbar;
    
    tripValueTextField.delegate = self;
    [addTripView addSubview:tripValueTextField];
    
    UIView *tripValuefieldUnderline = [[UIView alloc] initWithFrame:CGRectMake(10, 136,addTripView.frame.size.width-20, 0.65)];
    tripValuefieldUnderline.backgroundColor = [UIColor lightGrayColor];
    [addTripView addSubview:tripValuefieldUnderline];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(8, addTripView.frame.size.height-40, 60, 30)];
    deleteButton.backgroundColor = [UIColor clearColor];
    [deleteButton setTitle:NSLocalizedString(@"delete", @"Delete") forState:UIControlStateNormal];
    [deleteButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deletePressed) forControlEvents:UIControlEventTouchUpInside];
    [addTripView addSubview:deleteButton];
  
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(addTripView.frame.size.width-60, addTripView.frame.size.height-40, 50, 30)];
    addButton.backgroundColor = [UIColor clearColor];
    [addButton setTitle:NSLocalizedString(@"save", @"Save") forState:UIControlStateNormal];
    [addButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(saveEditPressed) forControlEvents:UIControlEventTouchUpInside];
    [addTripView addSubview:addButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(addButton.frame.origin.x-70, addTripView.frame.size.height-40, 60, 30)];
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton setTitle:NSLocalizedString(@"cancel", @"Cancel action") forState:UIControlStateNormal];
    [cancelButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
    [addTripView addSubview:cancelButton];
    
}


-(void)doneWithNumberPad{
    
    [tripValueTextField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if([textField.text containsString:@","]){
        
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"comma_err", @"cannot accept commas")] message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [alertControl addAction:ok];
        [self presentViewController:alertControl animated:YES completion:nil];
        NSString *Stringval = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        textField.text = Stringval;
    }
    
    return YES;
}

-(void)cancelPressed{
   
    [addTripView removeFromSuperview];
}

-(void)savePressed{
    
    NSMutableDictionary *newTripTypeDict = [[NSMutableDictionary alloc] init];
    
    if(tripTypeTextField.text == nil || [tripTypeTextField.text isEqualToString:@""] || tripValueTextField.text == nil || [tripValueTextField.text isEqualToString:@""]){
        
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Fields cannot be empty" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [alertControl addAction:ok];
        [self presentViewController:alertControl animated:YES completion:nil];
  
    }else{
        
        [newTripTypeDict setObject:@"All" forKey:@"vehid"];
        [newTripTypeDict setObject:tripTypeTextField.text forKey:@"serviceName"];
        [newTripTypeDict setObject:[NSNumber numberWithFloat:[tripValueTextField.text floatValue]] forKey:@"dueMiles"];
        [newTripTypeDict setObject:@(3) forKey:@"type"];
        [self.tripTypeArray addObject:newTripTypeDict];
        
        [self.tripTypeTableView reloadData];
        
        NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
        NSError *err;
        Services_Table *tripTypeData = [NSEntityDescription insertNewObjectForEntityForName:@"Services_Table" inManagedObjectContext:context];
        
        tripTypeData.vehid = @"All";
        tripTypeData.serviceName = tripTypeTextField.text;
        tripTypeData.dueMiles = [NSNumber numberWithFloat:[tripValueTextField.text floatValue]];
        tripTypeData.type = @(3);
        
        if ([context hasChanges])
        {
            BOOL saved = [context save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveMasterContext];
        }
        [addTripView removeFromSuperview];
    }
    
}

-(void)saveEditPressed{
    
    if(tripTypeTextField.text == nil || [tripTypeTextField.text isEqualToString:@""] || tripValueTextField.text == nil || [tripValueTextField.text isEqualToString:@""]){
        
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Fields cannot be empty" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [alertControl addAction:ok];
        [self presentViewController:alertControl animated:YES completion:nil];
        
    }else{
        
        NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
        NSError *err;
        NSString *comparestring = [NSString stringWithFormat:@"%@",[selectedTripTypeDict objectForKey:@"serviceName"]];
        
        NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serviceName==%@ and type = 3",comparestring];
        [requset setPredicate:predicate];
        
        NSArray *dataArray=[context executeFetchRequest:requset error:&err];
        Services_Table *updRecord = [dataArray firstObject];
        
        updRecord.vehid = @"All";
        updRecord.serviceName = tripTypeTextField.text;
        updRecord.dueMiles = [NSNumber numberWithFloat:[tripValueTextField.text floatValue]];
        updRecord.type = @(3);
        
        if ([context hasChanges])
        {
            BOOL saved = [context save:&err];
            if (!saved) {
                // do some real error handling
                //CLSLog(@“Could not save Data due to %@“, error);
            }
            [[CoreDataController sharedInstance] saveMasterContext];
        }
        
        [self fetchTripTypes];
        [self.tripTypeTableView reloadData];
        [addTripView removeFromSuperview];
    }
    
}

-(void)deletePressed{
    
    NSManagedObjectContext *context = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSError *err;
    NSString *comparestring = [NSString stringWithFormat:@"%@",[selectedTripTypeDict objectForKey:@"serviceName"]];
    
    NSFetchRequest *requset=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serviceName==%@ and type = 3",comparestring];
    [requset setPredicate:predicate];
    
    NSArray *dataArray=[context executeFetchRequest:requset error:&err];
    Services_Table *updRecord = [dataArray firstObject];
    
    if(updRecord != nil){
        
        [context deleteObject:updRecord];
      
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
    [self fetchTripTypes];
    [self.tripTypeTableView reloadData];
    [addTripView removeFromSuperview];
    
}

-(void)fetchTripTypes{
    
    self.tripTypeArray = [[NSMutableArray alloc] init];
    NSManagedObjectContext *contex = [[CoreDataController sharedInstance] newManagedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Services_Table"];
    NSError *err;
    NSArray *data=[contex executeFetchRequest:request error:&err];
    
    for(Services_Table *tripType in data)
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        if([tripType.type  intValue] == 3){
            
            [dictionary setObject:tripType.vehid forKey:@"vehid"];
            [dictionary setObject:tripType.serviceName forKey:@"serviceName"];
            if(tripType.dueMiles == nil){
                [dictionary setObject:@"0.0" forKey:@"dueMiles"];
            }else{
                [dictionary setObject:tripType.dueMiles forKey:@"dueMiles"];
            }

            [dictionary setObject:tripType.type forKey:@"type"];
            
            [self.tripTypeArray addObject:dictionary];
        }
        
    }
    
}

#pragma mark TableView Delegates methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.tripTypeArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TaxDedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tripTypeCell"];
    if (cell == nil) {
        cell = [[TaxDedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tripTypeCell"] ;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.triptypeLabel.textColor = [UIColor whiteColor];
    cell.tripValueLabel.textColor = [UIColor whiteColor];
    cell.tripValueLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    dictionary = [self.tripTypeArray objectAtIndex:indexPath.row];
    
    cell.triptypeLabel.text = [dictionary objectForKey:@"serviceName"];
    if([dictionary objectForKey:@"dueMiles"] != nil){

        cell.tripValueLabel.text = [[dictionary objectForKey:@"dueMiles"] stringValue];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    selectedTripTypeDict = [[NSMutableDictionary alloc] init];
    
    selectedTripTypeDict = [self.tripTypeArray objectAtIndex:indexPath.row];
   
    [self showEditTripView:selectedTripTypeDict];
    
}

@end
