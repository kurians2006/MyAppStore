//
//  DetailViewController.m
//  MyAppStore
//
//  Created by Rob Timpone on 4/29/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//
//  The detail view controller displays further details about an app to the user.  It behaves very differently depending on whether
//  the user is using an iPhone/iPod or an iPad.  If the user is using an iPhone, this controller will display modally and will
//  have a 'back' button to return to the SearchViewController.  If the user is using an iPad, the DetailViewController will already
//  be displayed in the detail section of the SplitViewController, and cards will animate on/off the screen as the user selects apps
//  in the SearchViewController on the left side of the SplitViewController.
//
//  In addition to all of the informatino found on a cell in the SearchViewController, the DetailViewController displays an app's
//  description and screenshot images.  The description can be scrolled using an onscreen UITextView and the screenshots can be
//  enlarged by tapping on them, which will bring up an instance of ScreenshotViewController.
//
//  This class also handles the adding/removing of apps to the user's favorites list, which (per the professor's instructions) is
//  stored using Core Data.  

#import "DetailViewController.h"
#import "ScreenshotViewController.h"
#import "Helper.h"
#import "FavApp.h"
#import "LinkToScreenshot.h"
#import <QuartzCore/QuartzCore.h>


@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *whiteBackgroundView;    // the 'card' contains the app's labels, images, etc.

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *developerLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *notRatedLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;

@property (weak, nonatomic) IBOutlet UIButton *screenshot1;
@property (weak, nonatomic) IBOutlet UIButton *screenshot2;
@property (weak, nonatomic) IBOutlet UIButton *screenshot3;
@property (weak, nonatomic) IBOutlet UIButton *screenshot4;
@property (weak, nonatomic) IBOutlet UIButton *screenshot5;

@property (strong, nonatomic) NSArray *screenshotOutlets;    // an array to hold the 5 UIButton outlets
    
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favoritesButton;

@property (nonatomic) BOOL cardIsOnScreen;    // a boolean to indicate whether a card is on the screen (used for iPad)

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end


@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = [Helper managedObjectContext];
    
    // puts all of the screenshot button outlets in an array
    self.screenshotOutlets = @[self.screenshot1, self.screenshot2, self.screenshot3, self.screenshot4, self.screenshot5];
    
    // sets the view background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pool_table"]];
    
    // gives the white 'card' rounded corners
    self.whiteBackgroundView.layer.cornerRadius = 15;
    self.whiteBackgroundView.layer.masksToBounds = NO;

    [self updateOutlets];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // if the user is using an iPad, moves the card offscreen (as an app has not yet been selected)
    if ([Helper deviceIsPad]) {
        self.whiteBackgroundView.center = CGPointMake(351, 1100);
        self.cardIsOnScreen = NO;
    }
}

// Updates text and image outlets with information from the App object
- (void)updateOutlets
{
    // updates the title text of the favorites button accordingly
    self.favoritesButton.title = [self appIsInFavoritesList] ? @"Remove from Favorites" : @"Add to Favorites";
    
    // updates text fields
    self.nameLabel.text = self.app.name;
    self.developerLabel.text = self.app.developer;
    self.priceLabel.text = [Helper priceTextForPrice:self.app.price];
    self.descriptionTextView.text = self.app.appDescription;
    
    // if an app has 0 stars, the 'not rated' text label will say 'Not Rated'
    // if an app has more than 0 stars, the 'not rated' text label will be blank and an image with stars will appear
    self.notRatedLabel.text = [self.app.stars intValue] == 0 ? @"Not Rated" : @"";
    self.ratingImageView.image = [Helper starImageForNumberOfStars:self.app.stars];
    
    // updates the app's icon image (which was already downloaded in the SearchViewController)
    self.iconImageView.image = self.app.icon;
    
    // screenshot buttons are disabled by default and enabled once an image is loaded (in case an app does not have 5 screenshots)
    for (UIButton *button in self.screenshotOutlets) {
        button.enabled = NO;
    }
    
    // loads the screenshots asynchronously
    int counter = 0;
    for (NSString *urlString in self.app.screenshotUrls) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
            // image downloads are done on a different thread
            NSLog(@"Loading screenshot...");
            NSURL *url = [NSURL URLWithString:urlString];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {

                // UI updates on the main thread when the image has been downloaded
                NSLog(@"Screenshot loaded");
                UIButton *screenshot = self.screenshotOutlets[counter];
                screenshot.enabled = YES;
                [screenshot setBackgroundImage:image forState:UIControlStateNormal];
                
            });
        });
        counter++;
    }
}

// Refreshes the UI depending on whether the user is using an iPad or an iPhone/iPod
- (void)refreshUI
{
    // if user is using an iPad, some animation takes place along with the outlet updates
    if ([Helper deviceIsPad]) {
        [self animateOutletsUpdate];
    }
    
    // if the user is using an iPhone, there is no need for animations
    else {
        [self updateOutlets];
    }
}

// If a card is currently showing on the screen, moves it offscreen to the right
- (void)animateOutletsUpdate
{
    if (self.cardIsOnScreen) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(void) {
                             self.whiteBackgroundView.center = CGPointMake(1200, 372);
                         }
                         completion:^(BOOL finished) {
                             
                             // calls the next animation block
                             NSLog(@"View moved off screen to the right");
                             [self animateNewCardMoveUpFromBottom];
                         }];
    }
    else {
        [self animateNewCardMoveUpFromBottom];
    }
}

// Moves a card from the bottom of the screen up to the center of the screen
- (void)animateNewCardMoveUpFromBottom
{
    self.whiteBackgroundView.center = CGPointMake(351, 1100);
    [self updateOutlets];
    
    // resets the screenshot images to avoid any artifact images from previously used cells
    for (UIButton *button in self.screenshotOutlets) {
        [button setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         self.whiteBackgroundView.center = CGPointMake(352, 372);
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"View arrived at center");
                         self.cardIsOnScreen = YES;
                     }];
}


#pragma mark - Button methods

// Dismisses the view controller modally (the back button is only shown on the iPhone version)
- (IBAction)backButtonTapped:(id)sender
{
    NSLog(@"Back button tapped");
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Attempts to add or remove an app from the user's favorite apps list
- (IBAction)favoritesButtonTapped:(id)sender
{
    NSLog(@"Add/remove from favorites button tapped");
    [self addOrRemoveFromFavorites];
}

// Opens a link to the app's page in the App Store (note that this will only work on actual devices, not on the simulator)
- (IBAction)buyAppButtonTapped:(id)sender
{
    NSLog(@"Buy app button tapped");
    NSString *appStoreLink = [@"https://itunes.apple.com/us/app/id" stringByAppendingString:self.app.appID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink]];
}

// Displays the screenshot the user tapped on using a ScreenshotViewController
- (IBAction)screenshotButtonTapped:(id)sender
{
    NSLog(@"Screenshot button tapped");
    
    // gets a reference to the storyboard depending on the type of device the user is using
    NSString *storyboardName = [Helper deviceIsPad] ? @"iPad_Storyboard" : @"iPhone_Storyboard";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];

    // creates a new ScreenshotViewController instance from the storyboard
    ScreenshotViewController *svc = [storyboard instantiateViewControllerWithIdentifier:@"ScreenshotViewController"];
    
    // sets the ScreenshotViewController's image to the button's background (which is the screenshot image the user selected)
    UIButton *button = (UIButton *)sender;
    svc.screenshot = [button backgroundImageForState:UIControlStateNormal];
    
    [self presentViewController:svc animated:YES completion:nil];
}


#pragma mark - Selected app delegate methods

// This is the delegate method used in the iPad version of the app.  Whenever a user selects a cell in the SearchViewController,
// it activates this method for its delegate.  In this case, the DetailViewController receives a reference to the App object
// that the user selected, and the UI is updated.
- (void)selectedApp:(App *)app
{
    NSLog(@"Delegate received '%@'",app.name);
    self.app = app;
    [self refreshUI];
}


#pragma mark - Core data methods

// Gets an array of core data objects that match the appID number specified by the app in self.app
// (expected number of objects in array is 1)
- (NSArray *)fetchAppFromCoreData
{
    // standard core data request setup
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FavApp" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    // app ID must match the app ID of the App object being stored in self.app
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appID == %@",self.app.appID];
    [request setPredicate:predicate];
    
    // execute the fetch request
    NSError *error = nil;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    return fetchResults;
}

// A boolean helper method to determine whether the app in self.app was found in core data
- (BOOL)appIsInFavoritesList
{
    return [[self fetchAppFromCoreData] count] > 0;
}

// Attempts to add or remove an app from the user's favorite list depending on the current text of the favorites button
- (void)addOrRemoveFromFavorites
{
    if ([self.favoritesButton.title isEqualToString:@"Add to Favorites"]) {
        [self addAppToFavorites];
    }
    
    if ([self.favoritesButton.title isEqualToString:@"Remove from Favorites"]) {
        [self removeAppFromFavorites];
    }
}

// Attempts to add an app to the user's favorite apps list in core data
- (void)addAppToFavorites
{
    // checks to see if the app is already in the user's favorite apps list
    if ([self appIsInFavoritesList]) {
        [self showAlreadyInFavoritesListAlertView];
    }
    
    else {
        NSLog(@"Adding '%@' to favorites",self.app.name);
    
        // creates a new FavApp core data object which will be added to core data
        FavApp *favApp = [NSEntityDescription insertNewObjectForEntityForName:@"FavApp" inManagedObjectContext:self.managedObjectContext];
        
        favApp.appName = self.app.name;
        favApp.developer = self.app.developer;
        favApp.price = self.app.price;
        favApp.stars = self.app.stars;
        favApp.appID = [NSNumber numberWithInt:[self.app.appID integerValue]];
        favApp.appDescription = self.app.appDescription;
        favApp.iconUrl = self.app.iconUrl;
        favApp.dateFavorited = [NSDate date];
        
        // creates LinkToScreenshot core data objects that will be linked to the FavApp core data object
        for (NSString *screenshotUrl in self.app.screenshotUrls) {
            LinkToScreenshot *link = [NSEntityDescription insertNewObjectForEntityForName:@"LinkToScreenshot" inManagedObjectContext:self.managedObjectContext];
            link.screenshotLink = screenshotUrl;
            [favApp addScreenshotLinksObject:link];
        }
        
        // adds the FavApp object to core data
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        
        // lets the user know that the app has been added to their favorites list
        [self showAppAddedToFavoritesAlertView];
    }
}

// Attempts to remove an app from the user's favorite apps list in core data
- (void)removeAppFromFavorites
{
    // checks to see if the app has already been removed from their favorites list
    if (![self appIsInFavoritesList]) {
        [self showAppAlreadyRemovedAlertView];
    }
    
    else {
        NSLog(@"Removing '%@' from favorites",self.app.name);
        
        // gets a core data reference to the app currently in self.app
        NSManagedObject *appToRemove = [[self fetchAppFromCoreData] objectAtIndex:0];
        
        // deletes it from core data
        [self.managedObjectContext deleteObject:appToRemove];
        
        // saves the changes
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        
        // lets the user know that the app has been removed from their favorites list
        [self showAppRemovedFromFavoritesAlertView];
    }
}

- (void)showAlreadyInFavoritesListAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already in Favorites"
                                                    message:@"This app has already been added to your favorites list"
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)showAppAddedToFavoritesAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Added"
                                                    message:[NSString stringWithFormat:@"%@ has been added to your favorites",self.app.name]
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)showAppAlreadyRemovedAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already Removed"
                                                    message:@"This app has already been removed from your favorites list"
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)showAppRemovedFromFavoritesAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Removed"
                                                    message:[NSString stringWithFormat:@"%@ has been removed from your favorites",self.app.name]
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
}


@end
