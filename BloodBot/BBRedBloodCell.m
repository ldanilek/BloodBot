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

- (void)setOxygenated:(BOOL)oxygenated sickled:(BOOL)sickled {
    static SKTexture *deoxygenatedTexture;
    if (!deoxygenatedTexture) {
        deoxygenatedTexture=[SKTexture textureWithImageNamed:@"Blue.png"];
    }
    static SKTexture *oxygenatedTexture;
    if (!oxygenatedTexture) {
        oxygenatedTexture=[SKTexture textureWithImageNamed:@"red-circle-hi.png"];
    }
    static SKTexture *deoxygenatedSickleTexture;
    if (!deoxygenatedSickleTexture) {
        deoxygenatedSickleTexture=[SKTexture textureWithImageNamed:@"blueSickle.png"];
    }
    static SKTexture *oxygenatedSickleTexture;
    if (!oxygenatedSickleTexture) {
        oxygenatedSickleTexture=[SKTexture textureWithImageNamed:@"redSickle.png"];
    }
    if (oxygenated&&sickled) self.node.texture=oxygenatedSickleTexture;
    else if (oxygenated) self.node.texture=oxygenatedTexture;
    else if (sickled) self.node.texture=deoxygenatedSickleTexture;
    else self.node.texture=deoxygenatedTexture;
}

- (void)setOxygenated:(BOOL)oxygenated {
    _oxygenated=oxygenated;
    [self setOxygenated:oxygenated sickled:self.sickled];
}

- (void)setSickled:(BOOL)sickled {
    _sickled=sickled;
    [self setOxygenated:self.oxygenated sickled:sickled];
}

+ (double)powerForLevelType:(BBLevelType)levelType {
    double powerBasedOnDevice = 7000;
    if (UIUserInterfaceIdiomPhone==UI_USER_INTERFACE_IDIOM()) {
        powerBasedOnDevice= 1000;
    }
    double power = powerBasedOnDevice;
    if (isSickle(levelType)) {
        power/=2;
    }
    return power;
}

@dynamic node;

- (NSString *)imageName {
    return nil;
}

- (double)radius {
    return 5;
}

- (instancetype)init {
    if (self=[self initOxygenated:YES sickle:NO]) {
        
    }
    return self;
}

- (instancetype)initOxygenated:(BOOL)oxygenated sickle:(BOOL)sickled {
    if (self=[super init]) {
        self.oxygenated=oxygenated;
        self.sickled=sickled;
        self.node.physicsBody.restitution=1;
        self.node.physicsBody.linearDamping=.3;
    }
    return self;
}

@end
