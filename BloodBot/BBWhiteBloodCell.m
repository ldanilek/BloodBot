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
    return @"th.png";
}

- (double)radius {
    return 18;
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
