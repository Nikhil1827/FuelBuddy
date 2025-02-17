//
//  ReminderPageContentViewController.m
//  FuelBuddy
//
//  Created by Swapnil on 07/03/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "ReminderPageContentViewController.h"

@interface ReminderPageContentViewController ()

@end

@implementation ReminderPageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.screenLabel1.text = self.labelText1;
    self.screenLabel2.text = self.labelText2;

    self.screenImage1.image = [UIImage imageNamed:self.imageText1];
    self.screenImage2.image = [UIImage imageNamed:self.imageText2];
    //self.screenLabel.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
