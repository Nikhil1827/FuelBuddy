//
//  CustomSpecificationsController.h
//  
//
//  Created by Swapnil on 27/07/17.
//
//

#import <UIKit/UIKit.h>

@interface CustomSpecificationsController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *specsView;

- (IBAction)cancelPressed:(id)sender;
- (IBAction)addPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;

@property NSString *nameString, *valueString;
@property BOOL isEdit;
@property NSInteger valueIndex;

@property (nonatomic,retain) NSMutableArray *addSpecArr;

@property (nonatomic, copy) void (^onDismiss)(UIViewController *sender, NSString* message);
@end
