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

- (void)setOxygenated:(BOOL)oxygenated {
    _oxygenated=oxygenated;
    static SKTexture *deoxygenatedTexture;
    if (!deoxygenatedTexture) {
        deoxygenatedTexture=[SKTexture textureWithImageNamed:@"Blue.png"];
    }
    static SKTexture *oxygenatedTexture;
    if (!oxygenatedTexture) {
        oxygenatedTexture=[SKTexture textureWithImageNamed:@"red-circle-hi.png"];
    }
    if (oxygenated) self.node.texture=oxygenatedTexture;
    else self.node.texture=deoxygenatedTexture;
    
}

+ (double)power {
    if (UIUserInterfaceIdiomPhone==UI_USER_INTERFACE_IDIOM()) {
        return 1000;
    }
    return 8000;
}

@dynamic node;

- (NSString *)imageName {
    return nil;
}

- (double)radius {
    return 5;
}

- (instancetype)init {
    if (self=[self initOxygenated:YES]) {
        
    }
    return self;
}

- (instancetype)initOxygenated:(BOOL)oxygenated {
    if (self=[super init]) {
        self.oxygenated=oxygenated;
        self.node.physicsBody.restitution=1;
        self.node.physicsBody.linearDamping=.3;
    }
    return self;
}

@end
