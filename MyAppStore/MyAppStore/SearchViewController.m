//
//  SearchViewController.m
//  MyAppStore
//
//  Created by Rob Timpone on 4/29/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//
//  The SearchViewController's main functions are to process App Store API searches initiated by the user and to handle
//  the sorting and display of search results in a UICollectionView.  The user can also display a list of their favorite
//  apps in the collection view by tapping the 'Favorites' button.  Per the professor's instructions, the list of the
//  user's favorite apps is stored using Core Data.  This is a universal app, so this class has methods such as
//  didSelectItemAtIndexPath that adjust depending on whether the user is using an iPad or iPhone.  


#import "SearchViewController.h"
#import "AppInfoCell.h"
#import "App.h"
#import "Helper.h"
#import "DetailViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "FavApp.h"
#import "LinkToScreenshot.h"
#import "SortViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SearchViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSCache *cache;

@end


@implementation SearchViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // sets background image
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pool_table"]];
}

// Lazy instantiation for the class's cache
- (NSCache *)cache
{
    if (!_cache) _cache = [[NSCache alloc] init];
    return _cache;
}


#pragma mark - UICollectionView data source methods

// The number of cells that will be displayed
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.searchResults count];
}

// When the collection view asks for cells, this method gets an App object from the searchResults array, creates an AppInfoCell,
// sets up the cell's labels, asynchronously downloads the app's icon image, and styles the cell with rounded corners and a
// drop shadow
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AppInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    App *app = (App *)self.searchResults[indexPath.row];
    
    // assigning the cell's labels/images
    cell.nameLabel.text = app.name;
    cell.developerLabel.text = app.developer;
    cell.priceLabel.text = [Helper priceTextForPrice:app.price];
    
    // if an app has 0 stars, the 'not rated' text label will say 'Not Rated'
    // if an app has more than 0 stars, the 'not rated' text label will be blank and an image with stars will appear
    cell.notRatedLabel.text = [app.stars intValue] == 0 ? @"Not Rated" : @"";
    cell.starsImage.image = [Helper starImageForNumberOfStars:app.stars];
    
    // resets the cell's icon image (to avoid any artifact images on reused cells)
    cell.iconThumbnail.image = nil;
    
    // sets up the icon image's rounded corners
    cell.iconThumbnail.layer.cornerRadius = 15;
    cell.iconThumbnail.clipsToBounds = YES;
    
    // asynchronously downloads the app's icon image, which dramatically decreases waiting time for the user
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        // this is what's done in a different thread
        NSURL *url = [NSURL URLWithString:app.iconUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        app.icon = image;
        
        // this is what's called when the image has been downloaded
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            cell.iconThumbnail.image = app.icon;
        });
    });
    
    // sets up the cell's rounded corners
    cell.layer.cornerRadius = 15;
    cell.layer.masksToBounds = NO;
    
    // sets up drop shadow for cell
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:cell.layer.cornerRadius].CGPath;
    cell.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.layer.shadowOpacity = 0.5;
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    
    // gives the cell a border
    [cell.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [cell.layer setBorderWidth:1];
    
    return cell;
}


#pragma mark - UICollectionViewFlowLayout delegate methods

// This method gets called when a user taps on a cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // the app that the user selected
    App *selectedApp = self.searchResults[indexPath.row];
    
    // if the delegate is set (this will only happen if the user is using an iPad), sends app information to the delegate
    if (self.delegate) {
        NSLog(@"Sending data for '%@' to delegate",selectedApp.name);
        [self.delegate selectedApp:selectedApp];
    }
    
    // if the delegate is not set (user is using an iPhone), the detail view controller is presented modally
    else {
        
        // Creates an instance from the iPhone storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone_Storyboard" bundle:[NSBundle mainBundle]];
        DetailViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
        
        // passes app information to the detail view controller
        dvc.app = self.searchResults[indexPath.row];
        
        [self presentViewController:dvc animated:YES completion:^(void){NSLog(@"presented");}];
    }
}

// Controls the spacing between the cells and the header, footer, and sides
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

// Controls the spacing between each line of cells
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}


#pragma mark - Button methods

// When the user taps the 'Favorites' button, the search results are reset to a list of apps they have marked as a favorite
- (IBAction)favoritesButtonTapped:(id)sender
{
    NSLog(@"Favorites button tapped");
    self.searchResults = [self favoriteAppsList];
    [self.collectionView reloadData];
}


#pragma mark - Sorting methods

// This is the method that fires when the Sort View Controller unwinds - it is an 'exit' unwind segue that was set up on the
// storyboard.  It gets the sorting selection from the SortViewController that is unwinding, creates an NSSortDescriptor, and
// performs the sort on the searchResults array.  
- (IBAction)unwindFromSortSelection:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"unwindSegue"]) {
     
        // the view controller that is unwinding
        SortViewController *svc = (SortViewController *)[segue sourceViewController];
        
        // creates a sort descriptor based on the user's selection
        NSLog(@"Sorting by %@",svc.sortingChoice);
        BOOL ascending = [svc.sortingChoice isEqualToString:@"stars"] ? NO : YES;
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:svc.sortingChoice ascending:ascending];
        
        // sorts the search results array and reloads the collection view
        NSArray *sortedArray = [self.searchResults sortedArrayUsingDescriptors:@[sortDescriptor]];
        self.searchResults = sortedArray;
        [self.collectionView reloadData];
    }
}


#pragma mark - Search Bar Methods

// Called when the user taps the 'Search' button on the keyboard - sends a search request to the Apple API (if necessary)
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search button tapped");
    
    // clears out the old search results
    self.searchResults = nil;
    [self.collectionView reloadData];
    
    // hides keyboard
    [self.searchBar resignFirstResponder];
    
    // shows a progress spinner
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Searching app store...";

    // reformats search term by replacing spaces with plus signs and sends it to the sendSearchRequestToApple: method
    NSString *searchTerm = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [self sendSearchRequestToApple:searchTerm];
}

// Hides the keyboard when the 'cancel' search bar button is tapped
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Cancel button tapped");
    [self.searchBar resignFirstResponder];
}

// Shows the 'cancel' search bar button when the user starts typing in the search bar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
}

// Hides the 'cancel' search bar button when the user is finished editing their search text
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;
}


#pragma mark - AFNetworking methods

// Sends a search request to the Apple API, but first checks a cache to see if the search was already recently completed
- (void)sendSearchRequestToApple:(NSString *)searchTerm
{
    // sets search term to lower case to standardize searches
    searchTerm = [searchTerm lowercaseString];
    
    // checks to see if search term is in cache - if it is, then the API does not need to be called
    if ([self searchTermResultsAreInCache:searchTerm]) {
        
        NSLog(@"Search term found in cache, no API call needed");
        
        // gets previous search results from cache and displays them in the collection view
        self.searchResults = [self.cache objectForKey:searchTerm];
        [self.collectionView reloadData];
        
        // API does not need to be called, method returns
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    
    NSLog(@"Sending search to Apple API for '%@'",searchTerm);
    
    // prepares a JSON request using AFNetworking methods
    NSString *urlString = [NSString stringWithFormat: @"https://itunes.apple.com/search?term=%@&country=us&entity=software",searchTerm];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request

    // called if response is successfully received
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        // parses the JSSON data
        NSLog(@"Response from API received successfully");
        [self parseRawData:(NSDictionary *)JSON fromSearchTerm:searchTerm];
    }
                                         
    // called if there is an error getting a response
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving data from API"
                                                            message:[NSString stringWithFormat:@"%@",error]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }];
    
    // this is what actually fires off the API call that was created in the variable 'operation'
    [operation start];
}

// A boolean helper method to indicate whether a set of search results is being stored in the cache
- (BOOL)searchTermResultsAreInCache:(NSString *)searchTerm
{
    return [self.cache objectForKey:searchTerm] ? YES : NO;
}

// Parses data from the API response and creates an App object from it
- (void)parseRawData:(NSDictionary *)rawData fromSearchTerm:(NSString *)searchTerm
{
    // gets the array of apps (represented as dictionaries) from the JSON data
    NSArray *results = rawData[@"results"];
    
    // shows an alert if there are no results for the search term
    if ([results count] == 0) {
        [self showAlertForSearchTerm:searchTerm];
    }
    
    else {
        
        NSLog(@"Parsing JSON data for '%@'",searchTerm);
        
        // an array that will hold the newly created App objects
        NSMutableArray *apps = [@[] mutableCopy];
        
        // creates an App object using data parsed from each dictionary inside 'results'
        for (NSDictionary *dict in results) {
            
            App *app = [[App alloc] init];
            
            app.name = dict[@"trackName"];
            app.developer = dict[@"artistName"];
            app.price = [NSNumber numberWithFloat:[dict[@"price"] floatValue]];
            app.stars = [NSNumber numberWithFloat:[dict[@"averageUserRatingForCurrentVersion"] floatValue]];
            app.appID = [NSString stringWithFormat:@"%d",[dict[@"trackId"] intValue]];
            app.appDescription = dict[@"description"];
            app.screenshotUrls = dict[@"screenshotUrls"];   // note that this is an array
            app.iconUrl = dict[@"artworkUrl60"];
            
            [apps addObject:app];
        }
        
        // puts the completed search results in the cache
        [self.cache setObject:apps forKey:searchTerm];
        
        // sets the completed search results to the searchResults array and reloads the collection view
        NSLog(@"Finished parsing JSON data for '%@'",searchTerm);
        self.searchResults = apps;
        [self.collectionView reloadData];        
    }
    
    // turns off progress spinner
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

// This is the alert view that is shown if a search request returns 0 results
- (void)showAlertForSearchTerm:(NSString *)searchTerm
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No results"
                                                    message:[NSString stringWithFormat:@"No results were found matching '%@'",searchTerm]
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
}


#pragma mark - Core data methods

// Queries Core Data to get an array of App objects for the apps the user has marked as a favorite
- (NSArray *)favoriteAppsList
{
    NSLog(@"Fetching favorite apps list from core data");
    
    // standard setup for a core data fetch request
    NSManagedObjectContext *managedObjectContext = [Helper managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FavApp" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    // results will be sorted in the order that they were favorited by the user
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateFavorited" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    // performs the fetch
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    
    // an array that will hold App objects created from 'FavApp' core data objects
    NSMutableArray *favoriteAppsList = [@[] mutableCopy];
    
    // gets data from each core data object to create App objects
    for (FavApp *favapp in fetchResults) {
        
        App *app = [[App alloc] init];
        
        app.name = favapp.appName;
        app.developer = favapp.developer;
        app.price = favapp.price;
        app.stars = favapp.stars;
        app.appID = [NSString stringWithFormat:@"%@",favapp.appID];
        app.appDescription = favapp.appDescription;
        app.iconUrl = favapp.iconUrl;
        
        NSMutableArray *screenshotUrls = [@[] mutableCopy];
        for (LinkToScreenshot *link in favapp.screenshotLinks) {
            [screenshotUrls addObject:link.screenshotLink];
        }
        app.screenshotUrls = screenshotUrls;
        
        [favoriteAppsList addObject:app];
    }
    
    // returns the array of App objects created from the core data FavApp objects
    return favoriteAppsList;
}


@end
