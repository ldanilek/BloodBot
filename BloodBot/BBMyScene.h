//
//  BBMyScene.h
//  BloodBot
//

//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BBObject.h"
#import "BBRobot.h"
#import "BBWhiteBloodCell.h"
#import "BBRedBloodCell.h"
#import "BBPathogen.h"

#define PLAYER_DESTROYED @"Player Gone"

#define ARTERY_SPEED_MULTIPLIER 4 //also multiply frequencies

@interface BBMyScene : SKScene <BBObjectDelegate>

@property (strong, nonatomic) BBRobot *player;
@property (strong, nonatomic) SKSpriteNode *plasma;//blood plasma. contains all nodes in plasma. moves.
- (void)viewDidAppear;

@property (nonatomic) BBLevelType levelType;
@property (strong, nonatomic) NSString *tutorialName;

@property (nonatomic) BOOL stopped;

@property int touches;
- (int)score;

@end
