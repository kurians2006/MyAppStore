//
//  App.h
//  MyAppStore
//
//  Created by Rob Timpone on 4/29/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//
//  This is a basic object that holds information about an app.  To see how this information is obtained
//  from the Apple API, see SearchViewController.  Note that this is not a core data class.  

#import <Foundation/Foundation.h>

@interface App : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *developer;
@property (strong, nonatomic) NSNumber *price;
@property (strong, nonatomic) NSNumber *stars;
@property (strong, nonatomic) NSString *appID;
@property (strong, nonatomic) NSString *appDescription;
@property (strong, nonatomic) NSString *iconUrl;

@property (strong, nonatomic) NSArray *screenshotUrls;
@property (strong, nonatomic) UIImage *icon;

@end
