//
//  BBViewController.m
//  BloodBot
//
//  Created by Lee Danilek on 3/5/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBViewController.h"
#import "BBMyScene.h"

@interface BBViewController ()

@property BOOL opened;
@property BBMyScene *scene;
@property BBLevelType levelType;

@property BOOL leaving;

@end

@implementation BBViewController

- (void)playerGone {
    if (!self.leaving) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        self.leaving=YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerGone) name:PLAYER_DESTROYED object:self.scene];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scene viewDidAppear];
}

- (void)viewDidLayoutSubviews {
    if (!self.opened) {
        // Configure the view.
        SKView * skView = (SKView *)self.view;
        
        //I think these are for debugging
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        self.scene = [BBMyScene sceneWithSize:skView.bounds.size];
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        self.scene.levelType=self.levelType;
        
        // Present the scene.
        [skView presentScene:self.scene];
    }
    self.opened=YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
