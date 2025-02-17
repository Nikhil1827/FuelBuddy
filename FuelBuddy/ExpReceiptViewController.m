//
//  ExpReceiptViewController.m
//  FuelBuddy
//
//  Created by Nikhil on 29/06/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "ExpReceiptViewController.h"

@interface ExpReceiptViewController () <UIScrollViewDelegate> {
    
     NSString *imageName;
}

@end

@implementation ExpReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [self colorFromHexString:@"#2c2c2c"];
    NSString *path = [self.receiptsArray objectAtIndex:self.index];
    //imageName = [path substringFromIndex:87];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", path]];
    //NSLog(@"completeImgPath:- %@",completeImgPath);
    self.receiptImageView.image = [UIImage imageWithContentsOfFile:completeImgPath];
    
    UIImage *buttonImage = [UIImage imageNamed:@"nav_delete"];
    UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [Button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    Button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width+5,buttonImage.size.height+5);
    UIBarButtonItem *BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:Button];
    [Button addTarget:self action:@selector(deleteimage) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:BarButtonItem];
    
    self.scrollView.minimumZoomScale=1.0;
    
    self.scrollView.maximumZoomScale=6.0;
    
    self.scrollView.contentSize=CGSizeMake(1280, 960);
    
    self.scrollView.delegate=self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.receiptImageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)deleteimage
{
    //NSLog(@"Did Pressed Delete");
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *imagePath = imageName;
    NSString *completeImgPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", imagePath]];
    NSError *error;
    [filemanager removeItemAtPath:completeImgPath error:&error];
    //NSLog(@"self.index:- %d",self.index);
    [self.receiptsArray removeObjectAtIndex:self.index];
    //NSLog(@"self.receiptsArray:- %@",self.receiptsArray);
    [self.receiptDelegate sendDataToA:self.receiptsArray];
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
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
