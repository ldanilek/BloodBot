//
//  BBRobot.m
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#define UNLOCK_BBOBJECT_PROTECTED
#import "BBRobot.h"
//#import "BBObject.m"

@interface BBRobot ()

@property SKSpriteNode *node;

@end

@implementation BBRobot

@dynamic node;

- (NSString *)imageName {
    return @"capsule.png";
}

- (CGPoint *)outline:(int *)count {
    //note the static
    static CGPoint points[5];
    points[0]=CGPointMake(-25, -6);
    points[1]=CGPointMake(12, -6);
    points[2]=CGPointMake(25, 0);
    points[3]=CGPointMake(12, 6);
    points[4]=CGPointMake(-25, 6);
    *count=5;
    return points;
}

- (instancetype)init {
    if (self=[super init]) {
        self.node.physicsBody.contactTestBitMask=1;
        self.node.physicsBody.angularDamping=1;
    }
    return self;
}

- (void)applyAcceleration:(CGVector)acceleration {
    CGPoint accelerationPoint = [self.node.scene convertPoint:self.node.position fromNode:self.node.parent];
    accelerationPoint.x+=[(SKSpriteNode *)self.node size].height/2*cos(self.node.zRotation);
    accelerationPoint.y+=[(SKSpriteNode *)self.node size].height/2*sin(self.node.zRotation);
    [self.node.physicsBody applyForce:CGVectorMake(acceleration.dx*self.node.physicsBody.mass, acceleration.dy*self.node.physicsBody.mass) atPoint:accelerationPoint];
}

@end
