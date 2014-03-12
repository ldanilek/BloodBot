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
    if ([[button text] isEqualToString:@"Vein"]) {
        [self performSegueWithIdentifier:@"Play" sender:button];
    } else if ([[button text] isEqualToString:@"Artery"]) {
        [self performSegueWithIdentifier:@"Play" sender:button];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BBLevelType level = BBLevelVein;
    if ([[sender currentTitle] isEqualToString:@"Artery"]) {
        level=BBLevelArtery;
    }
    [segue.destinationViewController setLevelType:level];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.loaded) {
        self.loaded=YES;
        int buttonHeight=30;
        int buttonWidth = 150;
        BBButtonView *vein = [[BBButtonView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds)-buttonWidth/2, 40, buttonWidth, buttonHeight)];
        vein.delegate=self;
        vein.text=@"Vein";
        vein.buttonColor=[UIColor redColor];
        vein.textColor=[UIColor whiteColor];
        BBButtonView *artery = [[BBButtonView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds)-buttonWidth/2, 70+buttonHeight, buttonWidth, buttonHeight)];
        artery.delegate=self;
        artery.text=@"Artery";
        artery.buttonColor=[UIColor redColor];
        artery.textColor=[UIColor whiteColor];
        [self.view addSubview:vein];
        [self.view addSubview:artery];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
