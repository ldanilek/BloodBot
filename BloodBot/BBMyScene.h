//
//  BBMyScene.h
//  BloodBot
//

//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BBMyScene : SKScene

@property (strong, nonatomic) SKSpriteNode *player;
@property (strong, nonatomic) SKSpriteNode *plasma;//blood plasma. contains all nodes in plasma. moves.

@end
