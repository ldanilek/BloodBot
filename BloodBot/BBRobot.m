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
        self.node.physicsBody.angularDamping=8;//technically this should be between 0 and 1. higher is better, though
        if ([self.delegate levelType]==BBLevelArtery) {
            self.node.physicsBody.linearDamping=1;
        }
        self.node.anchorPoint=CGPointMake(0.5, .5);
    }
    return self;
}

- (void)applyAcceleration:(CGVector)acceleration {
    CGPoint center = [self.node.scene convertPoint:self.node.position fromNode:self.node.parent];
    CGPoint accelerationPoint = center;
    CGPoint fixedPoint = accelerationPoint;
    accelerationPoint.x+=[(SKSpriteNode *)self.node size].width*cos(self.node.zRotation)/2;
    accelerationPoint.y+=[(SKSpriteNode *)self.node size].width*sin(self.node.zRotation)/2;
    CGVector relativeLocationOfFixedPoint = CGVectorMake(-[(SKSpriteNode *)self.node size].width*cos(self.node.zRotation)/2, -[(SKSpriteNode *)self.node size].width*sin(self.node.zRotation)/2);
    fixedPoint.x+=relativeLocationOfFixedPoint.dx;
    fixedPoint.y+=relativeLocationOfFixedPoint.dy;
    //acceleration must be constant. do not maintain force with mass increase
    [self.node.physicsBody applyForce:CGVectorMake(acceleration.dx*self.node.physicsBody.mass, acceleration.dy*self.node.physicsBody.mass) atPoint:accelerationPoint];
    ////relative velocity of fixedPoint should be 0
    //CGVector relativeVelocity = CGVectorMake(fixedPoint.x, fixedPoint.y);
}

@end
