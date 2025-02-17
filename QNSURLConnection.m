//
//  QNSURLConnection.m
//  FuelBuddy
//
//  Created by Swapnil on 28/09/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "QNSURLConnection.h"

@implementation QNSURLConnection

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                             error:(__autoreleasing NSError **)errorPtr {
    dispatch_semaphore_t    sem;
    __block NSData *        result;
    
    result = nil;
    
    sem = dispatch_semaphore_create(0);
    //Nikhil 14june2018 increased sessiontime to 120
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest = 120.0;
    sessionConfig.timeoutIntervalForResource = 120.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    //[NSURLSession sharedSession]
    [[session dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         if (errorPtr != NULL) {
                                             *errorPtr = error;
                                         }
                                         if (responsePtr != NULL) {
                                             *responsePtr = response;
                                         }  
                                         if (error == nil) {  
                                             result = data;  
                                         }  
                                         dispatch_semaphore_signal(sem);  
                                     }] resume];  
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);  
    
    return result;  
}  


@end
