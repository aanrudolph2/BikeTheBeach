//
//  RouteChooser.m
//  Charity Bike Route
//
//  Created by Aaron Rudolph on 10/15/15.
//  Copyright © 2015 Advanced Decisions. All rights reserved.
//

#import "RouteChooser.h"
#import "RoutePreview.h"

@implementation RouteChooser

NSMutableData * routeData;
NSMutableArray * routeNames;

id routeDict;

float responseLength;

- (void) viewDidLoad
{
    // Init route names/data arrays
    routeNames = [[NSMutableArray alloc] init];
    routeData = [[NSMutableData alloc] init];
    
    // Create asynchronous URL request
    NSURLRequest * req = [NSURLRequest requestWithURL:
                          [NSURL URLWithString:[_pullURL text]]];
    
    // Set self to handle URL responses
    [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    // Set progress view accordingly
    [_progressView setProgress:0.1];
}

// Called when URLConnection receives header data. Get expected content length here, re-initialize arrays, etc.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [routeNames removeAllObjects];
    [routeData setData:[[NSData alloc]init]];
    responseLength = [response expectedContentLength];
}

// Called when data is received. NOTE: THIS METHOD MAY BE CALLED SEVERAL TIMES. APPEND DATA, BUT DO NOT REPLACE IT.
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_progressView setProgress:[data length] / responseLength];
    [routeData appendData:data];
}

// Called when URL request is completed.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString * jsonString = [[NSString alloc] initWithData:routeData encoding:NSUTF8StringEncoding];
    
    routeDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    [routeNames addObjectsFromArray:[routeDict allKeys]];
    
    [_progressView setProgress:0.0];
    
    [self.tableView reloadData];
}

#pragma mark Interface Builder Outlet handlers

// Called when Refresh button is pressed
- (IBAction)refreshClicked:(id)sender
{
    NSURLRequest * req = [NSURLRequest requestWithURL:
                          [NSURL URLWithString:[_pullURL text]]];
    
    [[NSURLConnection alloc] initWithRequest:req delegate:self];
    [_progressView setProgress:0.1];
}

#pragma mark TableViewController-specific functions

// Called when the view controller requests a given cell view. Use this to populate cell data (i.e. the route name)
- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"routeName"];
    
    UILabel * label = (UILabel *)[cell viewWithTag:100];
    
    [label setText:[routeNames objectAtIndex:[indexPath row]]];
    
    return cell;
}

// Called when the view controller requests the number of sections in the table view. Always going to be 1 here.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Called when the view controller requests the number of cell views to create. This should be equal to the number of routes.
- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [routeNames count];
}

// Called when we will "seque" to another portion of the storyboard. Used to pass coordinate data to the map view from the serialized JSON input.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell * cell = (UITableViewCell *) sender;
    
    id mapData = [routeDict objectForKey:[[cell textLabel] text]];
    
    [((RoutePreview *)[segue destinationViewController]) setRouteData:mapData];
}

@end
