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

NSMutableData * routeData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapView.delegate = self;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    [_locationManager requestWhenInUseAuthorization];
    
    routeData = [[NSMutableData alloc] init];
    
    NSURLRequest * req = [NSURLRequest requestWithURL:
                          [NSURL URLWithString:@"https://raw.githubusercontent.com/aanrudolph2/BikeTheBeach/master/routes.json"]];
    
    [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    // Wait for response and load from there.
    
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [routeData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString * jsonString = [[NSString alloc] initWithData:routeData encoding:NSUTF8StringEncoding];
    
    id dict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSUInteger vCount = [dict count];
    
    CLLocationCoordinate2D markerCoords[vCount];
    
    for(int i = 0; i < vCount; i ++)
    {
        markerCoords[i] = CLLocationCoordinate2DMake([[[dict objectAtIndex:i] objectAtIndex:0] doubleValue], [[[dict objectAtIndex:i] objectAtIndex:1] doubleValue]);
    }
    
    MKPolyline * route = [MKPolyline polylineWithCoordinates:markerCoords count:vCount];
    
    [_mapView addOverlay:route];
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
        NSLog(@"Authorized to use location");
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

@end
