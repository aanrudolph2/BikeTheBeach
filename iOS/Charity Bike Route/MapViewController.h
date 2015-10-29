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

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, NSURLConnectionDataDelegate>

// Interface Builder Outlets
@property (weak, nonatomic) IBOutlet MKMapView * mapView;
@property (weak, nonatomic) IBOutlet UIButton * resumeBtn;

// Accessible Location Manager
@property (strong, nonatomic) CLLocationManager * locationManager;

// Function Prototypes
- (void) setRouteData: (id) mapPoints;
- (void) disableInteraction;
- (void) enableInteraction;

@end
