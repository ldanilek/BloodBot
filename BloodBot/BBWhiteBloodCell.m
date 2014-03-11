//
//  BBWhiteBloodCell.m
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#define UNLOCK_BBOBJECT_PROTECTED
#import "BBWhiteBloodCell.h"

@interface BBWhiteBloodCell ()

@property SKSpriteNode *node;

@end

@implementation BBWhiteBloodCell

@dynamic node;

- (NSString *)imageName {
    return @"WBC.png";
}

- (CGPoint *)outline:(int *)count {
    static CGPoint outline[8];
    int size = 29;
    outline[0]=CGPointMake(-13, size);
    outline[1]=CGPointMake(-size, 13);
    outline[2]=CGPointMake(-size, -13);
    outline[3]=CGPointMake(-13, -size);
    outline[4]=CGPointMake(13, -size);
    outline[5]=CGPointMake(size, -13);
    outline[6]=CGPointMake(size, 13);
    outline[7]=CGPointMake(13, size);
    *count=8;
    return outline;
}

- (instancetype)init {
    if (self=[super init]) {
        self.node.physicsBody.restitution=0;
        self.node.physicsBody.linearDamping=.2;
        self.node.physicsBody.contactTestBitMask=2;
    }
    return self;
}

@end
