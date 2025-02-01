//
//  BBViewController.h
//  BloodBot
//

//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@class BBViewController;

@protocol BBGameDelegate <NSObject>

- (void)gameOver:(BBViewController *)vc;
- (void)gameHasScore:(int)score;
- (BOOL)scoreIsHighscore:(int)score;

@end


@interface BBViewController : UIViewController

@property (weak) id <BBGameDelegate> delegate;
@property (strong, nonatomic) NSString *tutorialName;

@end
