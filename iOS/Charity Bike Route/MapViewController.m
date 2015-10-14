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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapView.delegate = self;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    [_locationManager requestWhenInUseAuthorization];
    
    NSData * inputData = [@"[[39.7111543617113,-75.12760716460377],[39.7112133,-75.1275746],[39.7112133,-75.1275746],[39.7115443,-75.1274136],[39.7116075,-75.12737469999999],[39.7116451,-75.1273482],[39.71169709999999,-75.1273032],[39.71169709999999,-75.1273032],[39.7117504,-75.1272534],[39.7118453,-75.1271379],[39.711884100000006,-75.12707569999999],[39.71196389999999,-75.1269234],[39.7120387,-75.1267702],[39.7124385,-75.12592],[39.712607299999995,-75.12557199999999],[39.712925000000006,-75.12496589999999],[39.712925000000006,-75.12496589999999],[39.71296749999999,-75.1248939],[39.71296749999999,-75.1248939],[39.71305448258233,-75.12474640993243], [39.715836142344976, -75.1206815416929], [39.70921431485006,-75.11240626973989],[39.709191700000005,-75.11238],[39.709026599999994,-75.1122184],[39.7084243,-75.11174],[39.7081467,-75.1115231],[39.708002799999996,-75.11142099999999],[39.708002799999996,-75.11142099999999],[39.7079215,-75.111369],[39.7079215,-75.111369],[39.7078499,-75.1113166],[39.7077816,-75.1112575],[39.7075599,-75.11105839999999],[39.7075599,-75.11105839999999],[39.7071003,-75.1110672],[39.7071003,-75.1110672],[39.7066797,-75.1110807],[39.7066797,-75.1110807],[39.7065862,-75.1110734],[39.7065862,-75.1110734]]" dataUsingEncoding:NSUTF8StringEncoding];
    
    id dict = [NSJSONSerialization JSONObjectWithData:inputData options:NSJSONReadingMutableContainers error:nil];
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
