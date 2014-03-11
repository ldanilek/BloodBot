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

@interface BBMyScene : SKScene

@property (strong, nonatomic) BBRobot *player;
@property (strong, nonatomic) SKSpriteNode *plasma;//blood plasma. contains all nodes in plasma. moves.
- (void)viewDidAppear;

@end
