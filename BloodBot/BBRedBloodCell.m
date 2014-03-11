//
//  BBRedBloodCell.m
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#define UNLOCK_BBOBJECT_PROTECTED
#import "BBRedBloodCell.h"

@interface BBRedBloodCell ()

@property SKSpriteNode *node;

@end

@implementation BBRedBloodCell

+ (double)power {
    if (UIUserInterfaceIdiomPhone==UI_USER_INTERFACE_IDIOM()) {
        return 2000;
    }
    return 10000;
}

@dynamic node;

- (NSString *)imageName {
    return @"red-circle-hi.png";
}

- (double)radius {
    return 5;
}

- (instancetype)init {
    if (self=[super init]) {
        self.node.physicsBody.restitution=1;
        self.node.physicsBody.linearDamping=.3;
    }
    return self;
}

@end
