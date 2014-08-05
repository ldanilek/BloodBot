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
#import <iAd/iAd.h>
#import "BBChooserViewController.h"
#import "BBViewController.h"

#define HIGH_SCORE_KEY @"High scores for each level"

@interface BBMenuViewController () <BBButtonDelegate, BBChooserDelegate, BBGameDelegate>

@property BOOL loaded;

@property BBPerson personSelected;
@property BBPathogenType pathogenSelected;
@property BBLocation locationSelected;

@end

@implementation BBMenuViewController

- (void)gameOver:(BBViewController *)vc {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)gameHasScore:(int)score {
    [self scoreAchieved:score];
}

- (NSString *)levelHash {
    BBLevelType levelType;
    levelType.person=self.personSelected;
    levelType.pathogenType=self.pathogenSelected;
    levelType.location=self.locationSelected;
    return [[NSNumber numberWithInteger:levelHash(levelType)] description];
}

//for current level
- (void)scoreAchieved:(int)score {
    if (score>[self highScore]) {
        NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:HIGH_SCORE_KEY] mutableCopy];
        if (!dict) dict = [NSMutableDictionary dictionary];
        [dict setObject:[NSNumber numberWithInt:score] forKey:self.levelHash];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:HIGH_SCORE_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.highScoreLabel.text=[NSString stringWithFormat:@"High score for these settings: %d", [self highScore]];
    }
}

//for current level
- (int)highScore {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:HIGH_SCORE_KEY];
    return [[dict objectForKey:self.levelHash] intValue];
}

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
    self.highScoreLabel.text=[NSString stringWithFormat:@"High score for these settings: %d", [self highScore]];
}

- (void)buttonPressed:(BBButtonView *)button {
    [self performSegueWithIdentifier:@"Play" sender:button];
}

#define TUTORIALS @[@"Navigation", @"Obstacles", @"Pathogens"]

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(BBButtonView *)sender {
    if ([segue.identifier isEqualToString:@"Play"]) {
        BBLevelType levelType;
        levelType.person=self.personSelected;
        levelType.pathogenType=self.pathogenSelected;
        levelType.location=self.locationSelected;
        [segue.destinationViewController setLevelType:levelType];
        [(BBViewController *)segue.destinationViewController setDelegate:self];
        if ([TUTORIALS containsObject:sender.text]) {
            [segue.destinationViewController setTutorialName:sender.text];
        }
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
        self.locationSelected=BBLocationVenaCava;
        self.pathogenSelected=BBPathogenTB;
        [self makeButton:@"Play" center:CGPointMake(size/2, CHOICE_CENTER+100) type:0];
        ADBannerView *ad = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        [self.view addSubview:ad];
        ad.bounds = CGRectMake(0, 0, 66, 1024);
        ad.center = CGPointMake(size/2, self.view.bounds.size.height-33);
        self.highScoreLabel.text=[NSString stringWithFormat:@"High score for these settings: %d", [self highScore]];
        
        int tutorialIndex = 0;
        int TUTORIAL_WIDTH = 150;
        int TUTORIAL_PAD = 20;
        int startX = self.view.bounds.size.width/2-(TUTORIAL_WIDTH*TUTORIALS.count+TUTORIAL_PAD*(TUTORIALS.count-1))/2;
        for (NSString *tutorialName in TUTORIALS) {
            CGRect frame = CGRectMake(startX + tutorialIndex*(TUTORIAL_WIDTH+TUTORIAL_PAD), 10, TUTORIAL_WIDTH, 50);
            BBButtonView *tutorialButton = [[BBButtonView alloc] initWithFrame:frame];
            tutorialButton.text=tutorialName;
            [self.tutorialsView addSubview:tutorialButton];
            tutorialButton.buttonColor=[UIColor redColor];
            tutorialButton.textColor=[UIColor whiteColor];
            tutorialButton.delegate=self;
            tutorialIndex++;
        }
    }
    [self.view layoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
