//
//  RouteChooser.h
//  Charity Bike Route
//
//  Created by Aaron Rudolph on 10/15/15.
//  Copyright © 2015 Advanced Decisions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RouteChooser : UITableViewController <NSURLConnectionDataDelegate>

// Interface Builder Outlets
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UITextField *pullURL;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshRoutes;

@end
