//
//  RouteNavigation.m
//  Charity Bike Route
//
//  Created by Aaron Rudolph on 10/30/15.
//  Copyright © 2015 Advanced Decisions. All rights reserved.
//


#import "RouteNavigation.h"

@interface RouteNavigation()
@property MKPolyline * route;
@property CLLocationCoordinate2D * markerCoords;
@property int markerCoordsLength;
@end

@implementation RouteNavigation

@synthesize markerCoords;
@synthesize markerCoordsLength;
@synthesize route;


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
    free(markerCoords);
    
    NSUInteger vCount = [mapPoints count];
    markerCoords = malloc(sizeof(CLLocationCoordinate2D) * vCount);
    
    for(int i = 0; i < vCount; i ++)
    {
        markerCoords[i] = CLLocationCoordinate2DMake([[[mapPoints objectAtIndex:i] objectAtIndex:0] doubleValue],
                                                      [[[mapPoints objectAtIndex:i] objectAtIndex:1] doubleValue]);
    }
    
    route = [MKPolyline polylineWithCoordinates:markerCoords count:vCount];
    markerCoordsLength = vCount;
    
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
    // NSLog(@"%f", newLocation.course);
    // If we are travelling more than 2mph (0.894 m/sec), disable map interaction.
    if(newLocation.speed > 0.894)
    {
        [self disableInteraction];
    }
    else
    {
        [self enableInteraction];
    }
    
    // Check if we're still on course
    
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

// Checks if user is on course
- (bool) isOnCourse: (CLLocation *) loc
{
    for(int i = 0; i < markerCoordsLength - 1; i ++)
    {
        CLLocationCoordinate2D position = loc.coordinate;
        CLLocationCoordinate2D origin = markerCoords[i];
        CLLocationCoordinate2D endpoint = markerCoords[i + 1];
        
        if(fabs((endpoint.latitude - origin.latitude) * position.latitude +
                (origin.longitude - endpoint.longitude) * position.longitude +
                (endpoint.longitude - endpoint.longitude)*origin.latitude +
                (origin.latitude - endpoint.latitude) * origin.longitude) /
           sqrt(pow(endpoint.latitude - origin.latitude, 2) + pow(origin.longitude - origin.longitude, 2)) <= 4.5)
        {
            return true;
        }
        
    }
    return false;
}

@end
