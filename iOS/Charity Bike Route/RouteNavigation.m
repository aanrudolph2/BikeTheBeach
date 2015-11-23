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
@property NSMutableDictionary * directions;
@end

@implementation RouteNavigation

@synthesize markerCoords;
@synthesize markerCoordsLength;
@synthesize route;
@synthesize directions;

BOOL onCourse = false;

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
    directions = [[NSMutableDictionary alloc] init];
    free(markerCoords);
    
    int vCount = (int)[mapPoints count];
    markerCoords = malloc(sizeof(CLLocationCoordinate2D) * vCount);
    
    for(int i = 0; i < vCount; i ++)
    {
        markerCoords[i] = CLLocationCoordinate2DMake([[[mapPoints objectAtIndex:i] objectAtIndex:0] doubleValue],
                                                     [[[mapPoints objectAtIndex:i] objectAtIndex:1] doubleValue]);
        
        
        if([[mapPoints objectAtIndex:i] count] > 2)
        {
            [directions setObject:[[NSNumber alloc] initWithInteger:i] forKey:[[mapPoints objectAtIndex:i] objectAtIndex:2]];
        }
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
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    
    CLLocation * loc = [locations objectAtIndex:0];
    
    // NSLog(@"%f", newLocation.course);
    // If we are travelling more than 2mph (0.894 m/sec), disable map interaction.
    if(loc.speed > 0.894)
    {
        [self disableInteraction];
    }
    else
    {
        [self enableInteraction];
    }
    
    // Check if we're still on course
    if([self isOnCourse:loc] != onCourse)
    {
        onCourse = !onCourse;
        
        if(!onCourse)
        {
            [self speakText:@"You may be off course."];
        }
    }
    [_courseNotification setHidden:onCourse];
    NSString * direction = [self getNextInstruction:loc];
    
    if(direction != nil)
    {
        [self speakText:direction];
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

// Checks if user is on course
- (bool) isOnCourse: (CLLocation *) loc
{
    for(int i = 0; i < markerCoordsLength - 1; i ++)
    {
        CLLocationCoordinate2D pos = loc.coordinate;
        CLLocationCoordinate2D p1 = markerCoords[i];
        CLLocationCoordinate2D p2 = markerCoords[i + 1];
        
        if(fabs((p2.longitude - p1.longitude) * pos.latitude + (p1.latitude - p2.latitude) * pos.longitude + (p1.longitude - p2.longitude) * p1.latitude + (p2.latitude - p1.latitude) * p1.longitude)/sqrt(pow(p2.longitude - p1.longitude, 2) + pow(p1.latitude - p2.latitude, 2)) <= 0.00004f)
        {
            return true;
        }
        
    }
    return false;
}

- (NSString *) getNextInstruction:(CLLocation *) loc
{
    for(int i = 0; i < markerCoordsLength - 1; i ++)
    {
        CLLocationCoordinate2D pos = loc.coordinate;
        CLLocationCoordinate2D p1 = markerCoords[i];
        
        if(sqrt(pow(pos.longitude - p1.longitude, 2) + pow(pos.latitude - p1.latitude, 2)) <= 0.00004f)
        {
            return [directions objectForKey:[[NSNumber alloc] initWithInteger:i]];
        }
    }
    return nil;
}

- (void) speakText:(NSString *)text
{
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    AVSpeechSynthesizer * synth = [[AVSpeechSynthesizer alloc] init];
    [synth speakUtterance:utterance];
}

@end
