//
//  Helper.m
//  MyAppStore
//
//  Created by Rob Timpone on 4/30/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//
//  This is a utility class designed to reduce repetition and make code more readable.  It has helper methods
//  for getting a reference to core data's managedObjectContext, getting images, and determining what type of
//  device the user is using.

#import "Helper.h"
#import "AppDelegate.h"

@implementation Helper

// Returns YES if the user is using an iPad, NO if not
+ (BOOL)deviceIsPad
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

// Gets a reference to the shared managedObjectContext found in the AppDelegate
+ (NSManagedObjectContext *)managedObjectContext
{
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

// Returns the appropriate star image (i.e. 5 stars, 4 stars, etc.) depending on the NSNumber parameter
+ (UIImage *)starImageForNumberOfStars:(NSNumber *)stars
{
    // the star images I made are formatted as '#_stars.png' for whole numbers, '#-#_stars.png' for numbers with a decimal place
    NSString *starsString = [NSString stringWithFormat:@"%.1f",[stars floatValue]];
    if ([starsString characterAtIndex:2] == '5') {
        starsString = [NSString stringWithFormat:@"%c-%c",[starsString characterAtIndex:0],[starsString characterAtIndex:2]];
    }
    else {
        starsString = [NSString stringWithFormat:@"%c",[starsString characterAtIndex:0]];
    }
    
    // gets a reference to the correct image and returns it
    NSString *filename = [NSString stringWithFormat:@"%@_stars.png",starsString];
    return [UIImage imageNamed:filename];
}

// Returns a price formatted as a string depending on the NSNumber parameter
+ (NSString *)priceTextForPrice:(NSNumber *)price
{
    NSString *priceText;
    
    if ([price floatValue] == 0) {
        priceText = @"Free";
    }
    else {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        priceText = [formatter stringFromNumber:[NSNumber numberWithFloat:[price floatValue]]];
    }
    
    return priceText;
}

@end
