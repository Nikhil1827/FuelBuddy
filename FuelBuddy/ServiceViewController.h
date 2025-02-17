//
//  ServiceViewController.h
//  FuelBuddy
//
//  Created by Surabhi on 16/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADMasterViewController.h"
#import "SerReceiptViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "FeedBackView.h"
//#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMapsBase/GoogleMapsBase.h>

@interface ServiceViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,GADBannerViewDelegate,UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, SerSenddataProtocol ,CLLocationManagerDelegate ,UITableViewDelegate ,UITableViewDataSource>
{
    int counter;
    float yaxis;
    UIButton *dropdown;
    UITableView *autocompletable;
    NSMutableArray *autocompletearray;
}

//ENH_57 adding collection view for multiple receipts //*receipt,
@property (strong, nonatomic) UICollectionView *serviceCollectionView;
//ENH_57 adding table view for service centers
@property (strong, nonatomic) UITableView *placesTableView;
@property (nonatomic,retain)NSMutableArray *centerArray;
@property (nonatomic,retain) NSMutableArray *textplace,*vehiclearray;
@property (nonatomic,assign)CGSize result;
@property(nonatomic,retain)UIImageView *vehimage,*deleteimg,*date;//NIKHIL ENH_42 added date
@property (nonatomic,retain)UIView *deleteview;
@property (nonatomic,retain) NSString *imagepath,*urlstring;
@property (nonatomic,retain) NSString *pickerval, *imageString;
@property(nonatomic,retain)UIDatePicker *pic;
@property (nonatomic,retain)UIPickerView *picker;
//@property (nonatomic,retain) UIImage *attachimage;
@property (nonatomic,retain) UIButton *setbutton;
@property (nonatomic,retain) NSMutableArray *servicearray,*receiptImageArray;
@property (nonatomic,retain) NSMutableDictionary *details;
@property (weak, nonatomic) UIButton *saveButton;


-(void)insertservice: (int)statusForUpdateService;

@end
