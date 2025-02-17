//
//  GoProViewController.h
//  FuelBuddy
//
//  Created by surabhi on 09/03/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "MBProgressHUD.h"

@interface GoProViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,SKProductsRequestDelegate,SKPaymentTransactionObserver,UITextViewDelegate>
{
    SKProductsRequest *productsRequest;
    NSArray *validProducts;
}
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UIButton *goprogold;
@property (weak, nonatomic) IBOutlet UIButton *goproyearly;
@property (weak, nonatomic) IBOutlet UIButton *gopromonthly;
- (IBAction)goproclick:(id)sender;
- (IBAction)goproyearlyclick:(id)sender;
- (IBAction)gopromonthlyclick:(id)sender;
@property (nonatomic,retain) NSString *callmethod;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
//ENH_58 added segment control
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (nonatomic,retain)NSMutableArray *dataarray,*imagearray;
//@property (weak, nonatomic) IBOutlet UILabel *toplabel;
@property (nonatomic,retain)MBProgressHUD *hud;

@end
