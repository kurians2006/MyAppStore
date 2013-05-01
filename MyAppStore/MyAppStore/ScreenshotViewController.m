//
//  ScreenshotViewController.m
//  MyAppStore
//
//  Created by Rob Timpone on 4/30/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//
//  This is a simple class that appears modally onscreen and displays an image.  On an iPhone/iPad, it will use
//  a crossfade transition and will appear fullscreen.  On an iPad, it will appear using the cross dissolve
//  transition along with the page sheet presentation style, which will grey out part of the background.  The
//  view controller has a tap gesture detector on it, which will dismiss the view controller when the user taps
//  anywhere on it.

#import "ScreenshotViewController.h"

@interface ScreenshotViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ScreenshotViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // the image that is displayed
    self.imageView.image = self.screenshot;
}

// dismisses the view controller when a tap is detected
- (IBAction)tapDetected:(id)sender
{
    NSLog(@"Tap detected, dismissing screenshot");
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
