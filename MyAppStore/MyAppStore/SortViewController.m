//
//  SortViewController.m
//  MyAppStore
//
//  Created by Rob Timpone on 5/1/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//
//  This view controller presents the user with four buttons, each of which indicates a different method
//  for sorting search results.  When the user taps on one of the buttons, the public property
//  'sortingChoice' is set.
//
//  An 'unwind segue' has been established in the storyboards by control-dragging from the 'Sort by Name'
//  button to the green 'exit' symbol on the view controller.  This segue is named 'unwindSegue', and it
//  is linked to the unwindFromSortSelection: method in the SearchViewController class.
// 
//  The other three buttons are wired to an IBAction method below, which performs the unwindSegue
//  programatically.  The end result is that this ViewController can be presented modally, then have its
//  public fields accessable to whichever view controller it unwinds to.  In this case, the public field
//  is 'sortingChoice', which is accessed by the SearchViewController.


#import "SortViewController.h"

@interface SortViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;    // an array of outlets to the 4 buttons

@end


@implementation SortViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // sets up background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_carbonfiber"]];    
    
    // custom button images
    UIImage *blackButton = [[UIImage imageNamed:@"blackButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *blackButtonHighlight = [[UIImage imageNamed:@"blackButtonHighlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // assigns custom buttom images to all four buttons
    for (UIButton *button in self.buttons) {
        [button setBackgroundImage: blackButton forState:UIControlStateNormal];
        [button setBackgroundImage: blackButtonHighlight forState:UIControlStateHighlighted];
    }
}

// A button action for the developer, price, and rating buttons, that performs the unwind segue established by the
// 'Sort by Name' button on the storyboard
- (IBAction)sortingButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"unwindSegue" sender:sender];
}

// Parses the key word from each button and sets it to the public field 'sortingChoice', which can be accessed by
// whichever view controller this controller is unwinding to
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"unwindSegue"]) {
        
        NSLog(@"Performing unwind segue");
        
        // parses which button was pressed from the button's title text
        UIButton *button = (UIButton *)sender;
        NSString *buttonTitle = button.titleLabel.text;
        NSArray *words = [buttonTitle componentsSeparatedByString:@" "];
        
        // gets the button's third word, which indicates the user's sorting choice
        NSString *keyword = [words[2] lowercaseString];
        
        // the keyword for Rating is actually 'stars', so the replacement is made if necessary
        if ([keyword isEqualToString:@"rating"]) {
            keyword = @"stars";
        }
        
        // sets the sorting choice to the public field sortingChoice
        self.sortingChoice = keyword;
    }
}


@end
