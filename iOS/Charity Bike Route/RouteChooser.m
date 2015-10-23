//
//  RouteChooser.m
//  Charity Bike Route
//
//  Created by Aaron Rudolph on 10/15/15.
//  Copyright © 2015 Advanced Decisions. All rights reserved.
//

#import "RouteChooser.h"
#import "MapViewController.h"

@implementation RouteChooser

NSMutableData * routeData;
NSMutableArray * routeNames;

id routeDict;

float responseLength;

- (void) viewDidLoad
{
    routeNames = [[NSMutableArray alloc] init];
    routeData = [[NSMutableData alloc] init];
    
    NSURLRequest * req = [NSURLRequest requestWithURL:
                          [NSURL URLWithString:[_pullURL text]]];
    
    [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [_progressView setProgress:0.1];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [routeNames removeAllObjects];
    [routeData setData:[[NSData alloc]init]];
    responseLength = [response expectedContentLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_progressView setProgress:[data length] / responseLength];
    [routeData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString * jsonString = [[NSString alloc] initWithData:routeData encoding:NSUTF8StringEncoding];
    
    routeDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    [routeNames addObjectsFromArray:[routeDict allKeys]];
    
    [_progressView setProgress:0.0];
    
    [self.tableView reloadData];
}

- (IBAction)refreshClicked:(id)sender
{
    NSURLRequest * req = [NSURLRequest requestWithURL:
                          [NSURL URLWithString:[_pullURL text]]];
    
    [[NSURLConnection alloc] initWithRequest:req delegate:self];
    [_progressView setProgress:0.1];
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"routeName"];
    
    UILabel * label = (UILabel *)[cell viewWithTag:100];
    
    [label setText:[routeNames objectAtIndex:[indexPath row]]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [routeNames count];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell * cell = (UITableViewCell *) sender;
    
    id mapData = [routeDict objectForKey:[[cell textLabel] text]];
    
    [((MapViewController *)[segue destinationViewController]) setRouteData:mapData];
}

@end
