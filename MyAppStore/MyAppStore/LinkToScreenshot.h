//
//  LinkToScreenshot.h
//  MyAppStore
//
//  Created by Rob Timpone on 5/1/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//
//  This is a core data class that was generated automatically.  It stores data about a screenshot
//  URL.  This needed to be a separate class in order to establish a 'has-many' relationship
//  where a FavApp can 'have-many' LinkToScreenshots.  

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FavApp;

@interface LinkToScreenshot : NSManagedObject

@property (nonatomic, retain) NSString * screenshotLink;
@property (nonatomic, retain) FavApp *belongsTo;

@end
