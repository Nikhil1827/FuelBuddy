//
//  QNSURLConnection.h
//  FuelBuddy
//
//  Created by Swapnil on 28/09/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QNSURLConnection : NSObject


+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                             error:(__autoreleasing NSError **)errorPtr;
@end
