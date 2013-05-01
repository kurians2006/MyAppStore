//
//  DetailViewController.h
//  MyAppStore
//
//  Created by Rob Timpone on 4/29/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "App.h"
#import "SelectedAppDelegate.h"

@interface DetailViewController : UIViewController <SelectedAppDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) App *app;

@end
