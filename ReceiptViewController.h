//
//  ReceiptViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 28/06/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReceiptViewController;

@protocol FillUpSenddataProtocol

-(void)sendDataToA:(NSMutableArray *)sendArray;

@end

@interface ReceiptViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *receiptImage;
@property (strong, nonatomic) NSMutableArray *receiptsArray;
@property (nonatomic) int index;
@property (weak)id<FillUpSenddataProtocol> receiptDelegate;

@end
