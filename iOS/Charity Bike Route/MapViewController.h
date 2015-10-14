//
//  MapViewController.h
//  Charity Bike Route
//
//  Created by Aaron Rudolph on 10/2/15.
//  Copyright © 2015 Advanced Decisions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *resumeBtn;
@property (strong, nonatomic) IBOutlet MKMapView * mapView;
@property (strong, nonatomic) CLLocationManager * locationManager;
@end
