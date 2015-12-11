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
int currentVertex = -1;

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
        [[[UIAlertView alloc] initWithTitle:@"Invalid Route" message:@"Overlay creation failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
            [directions setObject:[[mapPoints objectAtIndex:i] objectAtIndex:2] forKey:[[NSNumber alloc] initWithInteger:i]];
        }
    }
    
    route = [MKPolyline polylineWithCoordinates:markerCoords count:vCount];
    markerCoordsLength = vCount;
    
}

// Called when user manually pans map away from its center point. Shows the "Resume Navigation" button.
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
        [[[UIAlertView alloc] initWithTitle:@"Need Location Access" message:@"Please go to your settings and enable location access for Charity Bike Route" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Can't Determine Location" message:error.localizedFailureReason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


// Called when location is updated.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    
    CLLocation * loc = [locations objectAtIndex:0];
    
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

- (bool) lineIntersectsRadius:(CLLocationCoordinate2D)center : (CLLocationCoordinate2D) beginPoint : (CLLocationCoordinate2D) endPoint : (float) radius
{
    return fabs((endPoint.longitude - beginPoint.longitude) * center.latitude + (beginPoint.latitude - endPoint.latitude) * center.longitude + (beginPoint.longitude - endPoint.longitude) * beginPoint.latitude + (endPoint.latitude - beginPoint.latitude) * beginPoint.longitude)/sqrt(pow(endPoint.longitude - beginPoint.longitude, 2) + pow(beginPoint.latitude - endPoint.latitude, 2)) <= radius;
}

// Checks if user is on course
- (bool) isOnCourse: (CLLocation *) loc
{
    for(int i = 0; i < markerCoordsLength - 1; i ++)
    {
        CLLocationCoordinate2D pos = loc.coordinate;
        CLLocationCoordinate2D p1 = markerCoords[i];
        CLLocationCoordinate2D p2 = markerCoords[i + 1];
        
        if([self lineIntersectsRadius:pos:p1:p2:0.00006f])
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
        
        if(sqrt(pow(pos.longitude - p1.longitude, 2) + pow(pos.latitude - p1.latitude, 2)) <= 0.0001f
         && currentVertex != i)
        {
            currentVertex = i;
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
