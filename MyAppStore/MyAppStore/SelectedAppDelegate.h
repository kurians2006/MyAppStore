//
//  SelectedAppDelegate.h
//  MyAppStore
//
//  Created by Rob Timpone on 4/30/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//
//  This is a custom protocol that allows a view controller to send information about an App to
//  a class that implements this protocol.  This is used in the iPad implementation of this project.
//  Currently, the SearchViewController is set up to have a delegate property, and the DetailViewController
//  is set as the delegate.  When a user clicks on an AppInfoCell in SearchViewController, the
//  SearchViewController class sends information about an App object to its delegate, the
//  DetailViewController.
//
//  Used the tutorial at www.raywenderlich.com/29469 for help on setting up this custom delegate

#import <Foundation/Foundation.h>

@class App;

@protocol SelectedAppDelegate <NSObject>

- (void)selectedApp:(App *)app;

@end
