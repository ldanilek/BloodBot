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
    double size = 29;
    double corner = 13;
    /*if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        size/=2;
        corner/=2;
    }*/
    outline[0]=CGPointMake(-corner, size);
    outline[1]=CGPointMake(-size, corner);
    outline[2]=CGPointMake(-size, -corner);
    outline[3]=CGPointMake(-corner, -size);
    outline[4]=CGPointMake(corner, -size);
    outline[5]=CGPointMake(size, -corner);
    outline[6]=CGPointMake(size, corner);
    outline[7]=CGPointMake(corner, size);
    *count=8;
    return outline;
}

- (instancetype)init {
    if (self=[super init]) {
        self.node.physicsBody.restitution=1;
        self.node.physicsBody.linearDamping=.2;
        self.node.physicsBody.contactTestBitMask=2;
        if (UIUserInterfaceIdiomPhone==UI_USER_INTERFACE_IDIOM())[self.node runAction:[SKAction scaleTo:.5 duration:.01]];
    }
    return self;
}

@end
