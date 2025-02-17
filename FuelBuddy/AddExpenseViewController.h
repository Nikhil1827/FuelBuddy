//
//  AddExpenseViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 21/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"
#import "ExpReceiptViewController.h"


@interface AddExpenseViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,GADBannerViewDelegate,UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, ExpSenddataProtocol>

{
    int counter;
    float yaxis;
    UIButton *dropdown;
    UIView *navigationOverlay;
}

//ENH_57 adding collection view for multiple receipts
@property (strong, nonatomic) UICollectionView *expenseCollectionView;

@property (nonatomic,assign)CGSize result;
@property (nonatomic,retain) NSMutableArray *textplace,*vehiclearray;
@property(nonatomic,retain)UIDatePicker *pic;
@property (nonatomic,retain)UIPickerView *picker;
@property (nonatomic,retain) UIButton *setbutton;
//@property (nonatomic,retain) UIImage *attachimage;

//Swapnil BUG_91
//NIKHIL ENH_43 added date property
//ENH_57 removing image related atrributes :-*receipt *backImage
@property(nonatomic,retain)UIImageView *vehimage,*deleteimg,*date;
@property (nonatomic,retain) NSString *imagepath,*urlstring, *imageString;
@property (nonatomic,retain)UIView *deleteview;
@property (nonatomic,retain) NSString *pickerval,*odometervalue;
@property (nonatomic,retain) NSMutableArray *servicearray,*receiptImageArray;
@property (nonatomic,retain) NSMutableDictionary *details;

@end
