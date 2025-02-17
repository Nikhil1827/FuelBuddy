//
//  DashPageContentViewController.m
//  FuelBuddy
//
//  Created by Swapnil on 06/03/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "DashPageContentViewController.h"

@interface DashPageContentViewController ()

@end

@implementation DashPageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.screenLabel.text = self.labelText;
    self.screenImage.image = [UIImage imageNamed:self.imageText];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
