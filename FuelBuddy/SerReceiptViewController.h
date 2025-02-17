//
//  SerReceiptViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 02/07/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SerReceiptViewController;

@protocol SerSenddataProtocol

-(void)sendDataToA:(NSMutableArray *)sendArray;

@end

@interface SerReceiptViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *receiptImageView;

@property (strong, nonatomic) NSMutableArray *receiptsArray;
@property (nonatomic) int index;
@property (weak)id<SerSenddataProtocol> receiptDelegate;

@end
