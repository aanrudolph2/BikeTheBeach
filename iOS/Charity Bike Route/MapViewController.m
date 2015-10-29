//
//  MapViewController.m
//  Charity Bike Route
//
//  Created by Aaron Rudolph on 10/2/15.
//  Copyright © 2015 Advanced Decisions. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

MKPolyline * route = nil;

// Called when view loads
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Allow this class to take actions from the MapView
    _mapView.delegate = self;
    
    // Set up location manager
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    // Request authorization from user. Calls didChangeAuthorizationStatus on completion
    [_locationManager requestWhenInUseAuthorization];
    
    // Add route overlay. If overlay is not specified, exception will be thrown.
    @try
    {
        [_mapView addOverlay:route];
        [_mapView setCenterCoordinate:[route coordinate] animated:FALSE];
        [_mapView setVisibleMapRect:[route boundingMapRect] animated:FALSE];
    }
    @catch(NSException * ex)
    {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Set route data using serialized JSON text
// mapPoints may be as NSArray or NSDictionary depending on JSON input, thus it is specified as id
- (void) setRouteData:(id) mapPoints
{
    NSUInteger vCount = [mapPoints count];
    
    CLLocationCoordinate2D markerCoords[vCount];
    
    for(int i = 0; i < vCount; i ++)
    {
        markerCoords[i] = CLLocationCoordinate2DMake([[[mapPoints objectAtIndex:i] objectAtIndex:0] doubleValue],
                                                     [[[mapPoints objectAtIndex:i] objectAtIndex:1] doubleValue]);
    }
    
    route = [MKPolyline polylineWithCoordinates:markerCoords count:vCount];
    
}

// Called when user manually pans map away from its center point. Shows the "Resueme Navigation" button.
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if(mapView.userTrackingMode == MKUserTrackingModeNone)
    {
        [_resumeBtn setHidden:false];
    }
}

// Called when app must handle location authorization. See viewDidLoad.
- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [_locationManager startUpdatingLocation];
        [_mapView setMapType:MKMapTypeStandard];
        
        _mapView.showsUserLocation = YES;
        _mapView.showsPointsOfInterest = NO;
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
        [_resumeBtn setHidden:TRUE];
    }
    else if(status == kCLAuthorizationStatusDenied)
    {
        // TODO: Nag user with an info dialog saying location authorization is required, then offer to re-request auth.
        NSLog(@"Location auth failed");
    }
    else
    {
        NSLog(@"Unknown state");
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager error: %@", error.localizedDescription);
}


// Called when location is updated.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // If we are travelling more than 2mph (0.894 m/sec), disable map interaction.
    if(newLocation.speed > 0.894)
    {
        [self disableInteraction];
    }
    else
    {
        [self enableInteraction];
    }
}

// Called by the view renderer to determine how to render the map overlay. Set overlay color/alpha/line width here.
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:MKPolyline.class])
    {
        MKPolylineRenderer * lineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        lineView.strokeColor = [UIColor greenColor];
        lineView.lineWidth = 5;
        lineView.alpha = 0.5;
        
        return lineView;
    }
    else
    {
        return nil;
    }
}

#pragma mark Interface Builder Outlet handlers

// Called when Resume Button (if shown) is pressed. Resumes tracking the user on the map
- (IBAction)resumeNavigation:(id)sender
{
    [_resumeBtn setHidden:TRUE];
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
}

#pragma mark User Helper Functions

// Disables user interaction on the map
- (void) disableInteraction
{
    [_mapView setUserInteractionEnabled:FALSE];
}

// Enables user interaction on the map
- (void) enableInteraction
{
    [_mapView setUserInteractionEnabled:true];
}

@end
