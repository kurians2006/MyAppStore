//
//  FavApp.h
//  MyAppStore
//
//  Created by Rob Timpone on 5/1/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//
//  This is a core data class that was generated automatically.  It stores data about apps that the
//  user marks as a 'favorite'.  

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FavApp : NSManagedObject

@property (nonatomic, retain) NSString * appName;
@property (nonatomic, retain) NSString * developer;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * stars;
@property (nonatomic, retain) NSNumber * appID;
@property (nonatomic, retain) NSString * appDescription;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSDate * dateFavorited;
@property (nonatomic, retain) NSSet *screenshotLinks;
@end

@interface FavApp (CoreDataGeneratedAccessors)

- (void)addScreenshotLinksObject:(NSManagedObject *)value;
- (void)removeScreenshotLinksObject:(NSManagedObject *)value;
- (void)addScreenshotLinks:(NSSet *)values;
- (void)removeScreenshotLinks:(NSSet *)values;

@end
