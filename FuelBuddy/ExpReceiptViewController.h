//
//  ExpReceiptViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 29/06/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExpReceiptViewController;

@protocol ExpSenddataProtocol

-(void)sendDataToA:(NSMutableArray *)sendArray;

@end

@interface ExpReceiptViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *receiptImageView;
@property (strong, nonatomic) NSMutableArray *receiptsArray;
@property (nonatomic) int index;
@property (weak)id<ExpSenddataProtocol> receiptDelegate;

@end
