//
//  AutorotateNavigation.m
//  FuelBuddy
//
//  Created by surabhi on 28/01/16.
//  Copyright © 2016 Oraganization. All rights reserved.
//

#import "AutorotateNavigation.h"

@interface AutorotateNavigation ()

@end

@implementation AutorotateNavigation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (BOOL)shouldAutorotate {
    if (self.visibleViewController) {
        return [self.visibleViewController shouldAutorotate];
    } else {
        return YES;
    }
}



#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    if (self.visibleViewController) {
        return [self.visibleViewController supportedInterfaceOrientations];
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
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
