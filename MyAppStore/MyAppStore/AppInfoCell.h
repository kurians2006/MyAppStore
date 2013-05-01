//
//  AppInfoCell.h
//  MyAppStore
//
//  Created by Rob Timpone on 4/29/13.
//  Copyright (c) 2013 Rob Timpone. All rights reserved.
//
//  This is a custom CollectionViewCell with outlets for the text and images that appear on each cell.
//  See the SearchViewController class for more information on how data is assigned to these outlets.  

#import <UIKit/UIKit.h>

@interface AppInfoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconThumbnail;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *developerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *starsImage;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *notRatedLabel;

@end
