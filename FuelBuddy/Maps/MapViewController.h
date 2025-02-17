//
//  MapViewController.h
//  FuelBuddy
//
//  Created by Nikhil on 12/12/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet UISegmentedControl *segment;
@property (strong, nonatomic) IBOutlet UIImageView *vehImage;
@property (strong, nonatomic) IBOutlet UILabel *vehName;
@property (nonatomic,retain)UIPickerView *picker;
@property (nonatomic,retain) UIButton *setbutton;
@property (nonatomic,retain) NSMutableArray *vehiclearray;

- (IBAction)vehButton:(id)sender;
- (IBAction)dropdownButton:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *tripLabel;

- (IBAction)leftArrow:(UIButton *)sender;
- (IBAction)rightArrow:(UIButton *)sender;
- (IBAction)leftTripButton:(UIButton *)sender;
- (IBAction)rightTripButton:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *rightTripButOt;
@property (strong, nonatomic) IBOutlet UIButton *leftTripButOt;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;


@end
