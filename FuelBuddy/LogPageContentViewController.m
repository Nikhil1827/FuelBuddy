//
//  LogPageContentViewController.m
//  FuelBuddy
//
//  Created by Swapnil on 07/03/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "LogPageContentViewController.h"

@interface LogPageContentViewController ()

@end

@implementation LogPageContentViewController

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
