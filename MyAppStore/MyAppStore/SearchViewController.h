//
//  SearchViewController.h
//  MyAppStore
//
//  Created by Rob Timpone on 4/29/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectedAppDelegate.h"

@interface SearchViewController : UIViewController

// This class has a custom delegate - see the SelectedAppDelegate protocol
@property (nonatomic, strong) id<SelectedAppDelegate> delegate;

@end
