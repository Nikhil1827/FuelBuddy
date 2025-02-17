//
//  PageContentViewController.m
//  FuelBuddy
//
//  Created by Swapnil on 06/03/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "PageContentViewController.h"

@interface PageContentViewController ()

@end

@implementation PageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.screenLabel.text = self.labelText;
    self.screenLabel2.text = self.labelText2;
    //self.screenLabel.backgroundColor = [UIColor clearColor];
    
    self.imageLabel.image = [UIImage imageNamed:self.imageText];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
