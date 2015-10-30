//
//  MapViewController.m
//  Charity Bike Route
//
//  Created by Aaron Rudolph on 10/2/15.
//  Copyright © 2015 Advanced Decisions. All rights reserved.
//

#import "RoutePreview.h"

@interface RoutePreview ()

@property MKPolyline * route;
@property (weak, nonatomic) IBOutlet UINavigationItem * TitleView;
@property id mapPoints;

@end

@implementation RoutePreview

// Called when view loads
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Allow this class to take actions from the MapView
    _mapView.delegate = self;
    
    // Add route overlay. If overlay is not specified, exception will be thrown.
    @try
    {
        [_mapView addOverlay:_route];
        [_mapView setCenterCoordinate:[_route coordinate] animated:FALSE];
        [_mapView setVisibleMapRect:[_route boundingMapRect] animated:FALSE];
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
- (void) setRouteData:(id) mapPoints : (NSString *) routeName
{
    _mapPoints = mapPoints;
    [_TitleView setTitle:routeName];
    
    NSUInteger vCount = [mapPoints count];
    
    CLLocationCoordinate2D markerCoords[vCount];
    
    for(int i = 0; i < vCount; i ++)
    {
        markerCoords[i] = CLLocationCoordinate2DMake([[[mapPoints objectAtIndex:i] objectAtIndex:0] doubleValue],
                                                     [[[mapPoints objectAtIndex:i] objectAtIndex:1] doubleValue]);
    }
    
    _route = [MKPolyline polylineWithCoordinates:markerCoords count:vCount];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [((RouteNavigation *)[segue destinationViewController]) setRouteData:_mapPoints];
}

@end
