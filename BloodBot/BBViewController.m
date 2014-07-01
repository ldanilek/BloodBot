//
//  BBViewController.m
//  BloodBot
//
//  Created by Lee Danilek on 3/5/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBViewController.h"
#import "BBMyScene.h"
#import "BBGameOverViewController.h"

@interface BBViewController () <BBGameOverProtocol>

@property BOOL opened;
@property BBMyScene *scene;
@property BBLevelType levelType;

@property BOOL leaving;
@property UIImage *storedScreenshot;
@property NSString *storedMessage;

@end

@implementation BBViewController

//code from http://stackoverflow.com/questions/158914/cropping-a-uiimage
- (UIImage *)cropImage:(UIImage *)img toRect:(CGRect)rect {
    if (img.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * img.scale,
                          rect.origin.y * img.scale,
                          rect.size.width * img.scale,
                          rect.size.height * img.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(img.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:img.scale orientation:img.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

//code from http://stackoverflow.com/questions/13007512/how-to-take-a-round-screen-shot
- (UIImage *)screenShot
{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *croppedImage = viewImage;//[self cropImage:viewImage toRect:self.view.frame];
    return croppedImage;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"GameOver"] || [segue.identifier isEqualToString:@"Pause"]) {
        BBGameOverViewController *gameOver = segue.destinationViewController;
        [self.delegate gameHasScore:self.scene.score];
        gameOver.initialImage = self.storedScreenshot;
        gameOver.delegate=self;
        gameOver.justPaused = [segue.identifier isEqualToString:@"Pause"];
        gameOver.message = self.storedMessage;
    }
}

- (void)toMenu:(BBGameOverViewController *)vc {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate gameOver:self];
    }];
}

- (void)playerGone:(NSNotification *)gameOverNotification  {
    if (!self.leaving) {
        [self.delegate gameHasScore:self.scene.score];
        self.leaving=YES;
        self.scene.physicsWorld.speed=0;
        self.scene.speed=0;
        //present game over interface
        self.storedScreenshot=[self screenShot];
        self.storedMessage=gameOverNotification.object;
        [self performSegueWithIdentifier:@"GameOver" sender:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerGone:) name:PLAYER_DESTROYED object:nil];
    
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
        
        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
        tapper.numberOfTouchesRequired=2;
        [self.view addGestureRecognizer:tapper];
    }
    self.opened=YES;
}

- (void)showMenu:(UITapGestureRecognizer *)tapper {
    self.scene.stopped=!self.scene.stopped;
    [self.delegate gameHasScore:self.scene.score];
    self.scene.touches = 0;
    self.storedScreenshot=[self screenShot];
    [self performSegueWithIdentifier:@"Pause" sender:tapper];
}

- (void)resume:(BBGameOverViewController *)vc {
    [self dismissViewControllerAnimated:NO completion:^{
        self.scene.touches=0;
        self.scene.stopped=NO;
    }];
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
