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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapView.delegate = self;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    [_locationManager requestWhenInUseAuthorization];
    
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


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if(mapView.userTrackingMode == MKUserTrackingModeNone)
    {
        [_resumeBtn setHidden:false];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (IBAction)resumeNavigation:(id)sender
{
    [_resumeBtn setHidden:TRUE];
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if(newLocation.speed > 0.894)
    {
        [self disableInteraction];
    }
    else
    {
        [self enableInteraction];
    }
}

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

#pragma mark User Helper Functions

- (void) disableInteraction
{
    [_mapView setUserInteractionEnabled:FALSE];
}

- (void) enableInteraction
{
    [_mapView setUserInteractionEnabled:true];
}

@end
