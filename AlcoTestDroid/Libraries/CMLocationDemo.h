//
//  CMLocationDemo.h
//  CoreMotion
//
//  Created by Andreas Eichner on 02.09.13.
//  Copyright (c) 2013 Andreas Eichner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CMLocationDemo : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
{
    IBOutlet UIButton *locateButton;
    IBOutlet MKMapView *mapView;
    IBOutlet UILabel *coordinatesLabel;
    IBOutlet UILabel *locationNameLabel;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
}

- (IBAction)startUserLocalization:(id)sender;

@end
