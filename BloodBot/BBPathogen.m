//
//  BBPathogen.m
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#define UNLOCK_BBOBJECT_PROTECTED
#import "BBPathogen.h"

@interface BBPathogen ()

@property SKSpriteNode *node;

@end

@implementation BBPathogen

- (BOOL)nodeIs:(SKNode *)node {
    return node==self.node;
}

@dynamic node;

- (NSString *)imageName {
    return @"diamond.png";
}

- (CGPoint *)outline:(int *)count {
    static CGPoint points[4];
    points[0]=CGPointMake(15, 0);
    points[1]=CGPointMake(0, 15);
    points[2]=CGPointMake(-15, 0);
    points[3]=CGPointMake(0, -15);
    *count=4;
    return points;
}

- (instancetype)init {
    if (self=[super init]) {
        self.node.physicsBody.restitution=0;
        self.node.physicsBody.linearDamping=.05;
    }
    return self;
}

@end
