//
//  Helper.h
//  MyAppStore
//
//  Created by Rob Timpone on 4/30/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject

+ (BOOL)deviceIsPad;
+ (NSManagedObjectContext *)managedObjectContext;
+ (UIImage *)starImageForNumberOfStars:(NSNumber *)stars;
+ (NSString *)priceTextForPrice:(NSNumber *)price;

@end
