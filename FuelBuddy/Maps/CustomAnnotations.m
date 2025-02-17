//
//  CustomAnnotations.m
//  FuelBuddy
//
//  Created by Nikhil on 17/12/18.
//  Copyright © 2018 Oraganization. All rights reserved.
//

#import "CustomAnnotations.h"

@implementation CustomAnnotations

-(id)initWithTile:(NSString *)newTitle Location:(CLLocationCoordinate2D)location{
    
    self = [super init];
    
    if(self){
        
        _title = newTitle;
        _coordinate = location;
    }
    return self;
}

-(MKAnnotationView *)annotationView{
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"FillUpAnnotations"];
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    
    return annotationView;
    
}


@end
