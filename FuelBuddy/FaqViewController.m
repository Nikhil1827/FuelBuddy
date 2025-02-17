//
//  FaqViewController.m
//  FuelBuddy
//
//  Created by Surabhi on 10/12/15.
//  Copyright (c) 2015 Oraganization. All rights reserved.
//

#import "FaqViewController.h"
#import "AppDelegate.h"

@interface FaqViewController ()

@end

//Swapnil 15 Mar-17
// static GADMasterViewController *shared;
@implementation FaqViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webview.delegate=self;
    
    AppDelegate *app = [AppDelegate sharedAppDelegate];
    
    if(app.result.width == 320)
    {
    _loadingView = [[UIView alloc]initWithFrame:CGRectMake(120, 200, 80, 80)];
    }
    else
    {
        _loadingView = [[UIView alloc]initWithFrame:CGRectMake(150, 200, 80, 80)];
    }
    _loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    _loadingView.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(_loadingView.frame.size.width / 2.0, 35);
    
    [activityView startAnimating];
    activityView.tag = 100;
    [_loadingView addSubview:activityView];
    
    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, 80, 30)];
    lblLoading.text = @"Loading...";
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    [_loadingView addSubview:lblLoading];
    
    [self.view addSubview:_loadingView];
    
    //NSLog(@"url string %@",self.urlstring);
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlstring]]];
    UIImage *buttonImage = [UIImage imageNamed:@"nav_back"];
    
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    
    [Button addTarget:self action:@selector(backbuttonclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:BarButtonItem];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationItem.title=self.navtitle;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor] , NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:18.0] }];


}

-(void)viewDidAppear:(BOOL)animated
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(void)backbuttonclick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [_loadingView setHidden:NO];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
     [_loadingView setHidden:YES];
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
