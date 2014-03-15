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

- (instancetype)initWithType:(BBPathogenType)pathogenType {
    if (self=[super init]) {
        self.pathogenType=pathogenType;
        self.node.physicsBody.restitution=0;
        self.node.physicsBody.linearDamping=.05;
        self.node.physicsBody.contactTestBitMask=3;
    }
    return self;
}

- (id)init {
    if (self=[self initWithType:BBPathogenBacteria]) {
        
    }
    return self;
}

@dynamic node;

- (NSString *)imageName {
    if (self.pathogenType==BBPathogenHIV) return @"diamond.png";
    else if (self.pathogenType==BBPathogenBacteria) return @"bacteria.png";
    return nil;
}

- (CGPoint *)outline:(int *)count {
    if (self.pathogenType==BBPathogenHIV) {
        static CGPoint points[4];
        points[0]=CGPointMake(15, 0);
        points[1]=CGPointMake(0, 15);
        points[2]=CGPointMake(-15, 0);
        points[3]=CGPointMake(0, -15);
        *count=4;
        return points;
    } else {
        static CGPoint points[6];
        points[0]=CGPointMake(-12.5, 7.5);
        points[1]=CGPointMake(-22.5, 0);
        points[2]=CGPointMake(-12.5, -7.5);
        points[3]=CGPointMake(14.5, -7.5);
        points[4]=CGPointMake(22.5, 0);
        points[5]=CGPointMake(14.5, 7.5);
        *count=6;
        return points;
    }
}

@end
