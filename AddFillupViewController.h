//
//  AddFillupViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 18/11/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"
#import "FillupPageContentViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ReceiptViewController.h"

@interface AddFillupViewController : UIViewController <UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate,GADInterstitialDelegate, UIPageViewControllerDataSource, CLLocationManagerDelegate , UITextViewDelegate , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, FillUpSenddataProtocol>
{ 
    int counter;
    float yaxis;
    GADBannerView *adBanner_;
    UITableView *autocompletable;
     UITableView *autocompletable1;
     UITableView *autocompletable2;
    NSMutableArray *autocompletearray;
    UIButton *dropdown;
    //ENH_56 added dropdown button for unit change
    UIButton *unitButton;
    UIButton *priceCurrencyButton;
    UIButton *totalCurrencyButton;
    
    //Swapnil 7 Mar-17
    UIView *navigationOverlay;
}
//ENH_57 adding collection view for multiple receipts
@property (strong, nonatomic) UICollectionView *receiptCollectionView;
@property (strong, nonatomic) IBOutlet UIView *topview;
@property (strong, nonatomic) IBOutlet UIButton *backbutton;
@property (nonatomic,retain) NSMutableArray *arrayoftext,*textplace,*vehiclearray,*checkedarray,*serviceArray;
@property (nonatomic,assign)CGSize result;
@property (nonatomic,assign) CGRect imageframe;

//Swapnil BUG_91
@property(nonatomic,retain)UIImageView *vehimage,*deleteimg,*date;//NIKHIL ENH_41 added date
//ENH_57 removing image related atrributes :-*receipt *backImage
//@property (nonatomic,retain) UIImage *attachimage;
@property (nonatomic,retain) NSString *pickerval;
@property(nonatomic,retain)UIDatePicker *pic;
@property (nonatomic,retain)UIPickerView *picker;
@property (nonatomic,retain)UIButton *setbutton;
@property (nonatomic,retain) NSString *imagepath,*urlstring, *imageString;
@property (nonatomic,retain)UIView *deleteview,*backView;
@property (nonatomic,retain)NSMutableArray *octanearray,*fuelarray,*fillingarray,*receiptImageArray,*unitPickerArray,*currencyPickerArray;
@property (nonatomic,retain) NSMutableDictionary *details;

//Swapnil 7 Mar-17

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSArray *pageTitles;
@property (nonatomic, strong) NSArray *imagesArray;

- (FillupPageContentViewController *)viewControllerAtIndex: (NSUInteger)index;


@end

@interface NSString (Extensions)
-(NSString *)currencyInputFormatting;
@end
