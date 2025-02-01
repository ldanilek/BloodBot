//
//  BBMenuViewController.h
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBButtonView.h"
#import <iAd/ADBannerView.h>

@interface BBMenuViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *personLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *pathogenLabel;
@property (nonatomic, weak) IBOutlet UILabel *highScoreLabel;

@property (nonatomic, weak) IBOutlet UIScrollView *tutorialsView;

@property (strong, nonatomic) ADBannerView *adView;

@end
