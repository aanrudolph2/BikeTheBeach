//
//  RouteNavigation.h
//  Charity Bike Route
//
//  Created by Aaron Rudolph on 10/30/15.
//  Copyright © 2015 Advanced Decisions. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RouteNavigation : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, NSURLConnectionDataDelegate>

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