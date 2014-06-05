//
//  BBMenuViewController.m
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBMenuViewController.h"
#import "BBMyScene.h"
#import "BBButtonView.h"

#import "BBChooserViewController.h"

@interface BBMenuViewController () <BBButtonDelegate, BBChooserDelegate>

@property BOOL loaded;

@property BBPerson personSelected;
@property BBPathogenType pathogenSelected;
@property BBLocation locationSelected;

@end

@implementation BBMenuViewController

- (void)chooser:(BBChooserViewController *)chooser chose:(int)chosen named:(NSString *)choiceName {
    if (chooser.chooserType==BBPersonChooser) {
        self.personSelected=chosen;
        self.personLabel.text=choiceName;
    } else if (chooser.chooserType==BBLocationChooser) {
        self.locationSelected=chosen;
        self.locationLabel.text=choiceName;
    } else if (chooser.chooserType==BBPathogenChooser) {
        self.pathogenSelected=chosen;
        self.pathogenLabel.text=choiceName;
    }
}

- (void)buttonPressed:(BBButtonView *)button {
    [self performSegueWithIdentifier:button.text sender:button];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIView *)sender {
    if ([segue.identifier isEqualToString:@"Play"]) {
        BBLevelType levelType;
        levelType.person=self.personSelected;
        levelType.pathogenType=self.pathogenSelected;
        levelType.location=self.locationSelected;
        [segue.destinationViewController setLevelType:levelType];
    } else {
        BBChooserViewController *chooser = segue.destinationViewController;
        chooser.chooserType=(BBChooserType)sender.tag;
        chooser.delegate=self;
        switch ((BBChooserType)sender.tag) {
            case BBPathogenChooser:
            chooser.currentChoice=self.pathogenSelected;
            break;
            
            case BBLocationChooser:
            chooser.currentChoice=self.locationSelected;
            break;
            
            case BBPersonChooser:
            chooser.currentChoice=self.personSelected;
            break;
            
            default:
            break;
        }
    }
}

- (BBButtonView *)makeButton:(NSString *)buttonText center:(CGPoint)center type:(BBChooserType)levelType {
    int buttonHeight=40;
    int buttonWidth = 150;
    BBButtonView *button = [[BBButtonView alloc] initWithFrame:CGRectMake(center.x-buttonWidth/2, center.y-buttonHeight/2, buttonWidth, buttonHeight)];
    button.delegate=self;
    button.text=buttonText;
    button.buttonColor=[UIColor brownColor];//redColor];
    button.textColor=[UIColor whiteColor];
    button.tag=levelType;
    [self.view addSubview:button];
    return button;
}

#define CHOICE_CENTER 100

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.loaded) {
        self.loaded=YES;
        int size = self.view.bounds.size.width;
        self.personSelected=BBPersonAverage;
        self.locationSelected=BBLocationVein;
        self.pathogenSelected=BBPathogenBacteria;
        [self makeButton:@"Play" center:CGPointMake(size/2, CHOICE_CENTER+100) type:0];
    }
    [self.view layoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
