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

@interface BBMenuViewController () <BBButtonDelegate>

@property BOOL loaded;

@end

@implementation BBMenuViewController

- (void)buttonPressed:(BBButtonView *)button {
    [self performSegueWithIdentifier:@"Play" sender:button];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIView *)sender {
    [segue.destinationViewController setLevelType:sender.tag];
}

- (void)makeButton:(NSString *)buttonText center:(CGPoint)center type:(BBLevelType)levelType {
    int buttonHeight=40;
    int buttonWidth = 150;
    BBButtonView *button = [[BBButtonView alloc] initWithFrame:CGRectMake(center.x-buttonWidth/2, center.y-buttonHeight/2, buttonWidth, buttonHeight)];
    button.delegate=self;
    button.text=buttonText;
    button.buttonColor=[UIColor brownColor];//redColor];
    button.textColor=[UIColor whiteColor];
    button.tag=levelType;
    [self.view addSubview:button];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.loaded) {
        self.loaded=YES;
        int veinCenter = self.view.bounds.size.width/4;
        int arteryCenter = veinCenter*3;
        CGSize labelSize = CGSizeMake(100, 50);
        UILabel *veinLabel = [[UILabel alloc] initWithFrame:CGRectMake(veinCenter-labelSize.width/2, 30, labelSize.width, labelSize.height)];
        veinLabel.text=@"Vein";
        veinLabel.font=[UIFont fontWithName:BBFONT size:30];
        veinLabel.textAlignment=NSTextAlignmentCenter;
        [self.view addSubview:veinLabel];
        UILabel *arteryLabel = [[UILabel alloc] initWithFrame:CGRectMake(arteryCenter-labelSize.width/2, 30, labelSize.width, labelSize.height)];
        arteryLabel.text=@"Artery";
        [self.view addSubview:arteryLabel];
        arteryLabel.font=[UIFont fontWithName:BBFONT size:30];
        arteryLabel.textAlignment=NSTextAlignmentCenter;
        
        [self makeButton:@"HIV" center:CGPointMake(veinCenter, 100) type:BBLevelVeinHIV];
        [self makeButton:@"Bacteria" center:CGPointMake(veinCenter, 160) type:BBLevelVeinBacteria];
        [self makeButton:@"HIV" center:CGPointMake(arteryCenter, 100) type:BBLevelArteryHIV];
        [self makeButton:@"Bacteria" center:CGPointMake(arteryCenter, 160) type:BBLevelArteryBacteria];
        [self makeButton:@"Bacteria Sickle" center:CGPointMake(veinCenter, 220) type:BBLevelVeinBacteriaSickle];
        [self makeButton:@"HIV Sickle" center:CGPointMake(veinCenter, 280) type:BBLevelVeinHIVSickle];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
