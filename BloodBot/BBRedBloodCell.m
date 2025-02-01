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
@property BOOL malaria;

@end

@implementation BBRedBloodCell

- (BOOL)infectedMalaria {
    return self.malaria && self.displayed;
}

- (void)infectWithMalaria {
    if (!self.sickled && !self.malaria) {
        self.malaria=YES;
        self.oxygenated=NO;
        static SKTexture *malarialTexture;
        if (!malarialTexture) {
            malarialTexture=[SKTexture textureWithImageNamed:@"malariaRed.png"];
        }
        self.node.texture=malarialTexture;
        self.node.physicsBody.mass=.02;
    }
}

#define OXYGENATED_MASS .0035
#define DEOXYGENATED_MASS .002

- (void)setOxygenated:(BOOL)oxygenated sickled:(BOOL)sickled {
    if (!self.malaria) {
        static SKTexture *deoxygenatedTexture;
        if (!deoxygenatedTexture) {
            deoxygenatedTexture=[SKTexture textureWithImageNamed:@"Blue.png"];
        }
        static SKTexture *oxygenatedTexture;
        if (!oxygenatedTexture) {
            oxygenatedTexture=[SKTexture textureWithImageNamed:@"Red.png"];
        }
        static SKTexture *deoxygenatedSickleTexture;
        if (!deoxygenatedSickleTexture) {
            deoxygenatedSickleTexture=[SKTexture textureWithImageNamed:@"sickledBlue.png"];
        }
        static SKTexture *oxygenatedSickleTexture;
        if (!oxygenatedSickleTexture) {
            oxygenatedSickleTexture=[SKTexture textureWithImageNamed:@"sickledRed.png"];
        }
        if (oxygenated&&sickled) self.node.texture=oxygenatedSickleTexture;
        else if (oxygenated) self.node.texture=oxygenatedTexture;
        else if (sickled) self.node.texture=deoxygenatedSickleTexture;
        else self.node.texture=deoxygenatedTexture;
    }
}

- (void)setOxygenated:(BOOL)oxygenated {
    _oxygenated=oxygenated;
    [self setOxygenated:oxygenated sickled:self.sickled];
    if (oxygenated) {
        self.node.physicsBody.mass=OXYGENATED_MASS;
    } else {
        self.node.physicsBody.mass=DEOXYGENATED_MASS;
    }
}

- (void)setSickled:(BOOL)sickled {
    _sickled=sickled;
    [self setOxygenated:self.oxygenated sickled:sickled];
}

+ (double)powerForLevelType:(BBLevelType)levelType {
    double power = 40000;
    if (isSickle(levelType.person)) {
        power/=2;
    }
    return power;
}

@dynamic node;

- (NSString *)imageName {
    return nil;
}

- (double)radius {
    if (self.sickled) return 0;
    return 15;
}

#define SIZE_MULTIPLIER 1.0
- (CGSize)imageSize {
    if (self.sickled) {
        return CGSizeMake(20*SIZE_MULTIPLIER, 30*SIZE_MULTIPLIER);
    }
    return CGSizeMake(30, 30);
}

#define EVENTUAL_HEIGHT 30*SIZE_MULTIPLIER
#define EVENTUAL_WIDTH 20*SIZE_MULTIPLIER
#define SICKLE_HEIGHT 187.0
#define SICKLE_WIDTH 125.0
#define SCALE_DOWN_FACTOR EVENTUAL_HEIGHT/SICKLE_HEIGHT
#define CENTER_DIFF 72.0-10.0
#define SICKLE_RADIUS ((SICKLE_HEIGHT/2.0)-5.0)
#define OUTER_CENTER_X ((SICKLE_HEIGHT/2.0)-(SICKLE_WIDTH/2.0))
#define INNER_CENTER_X ((SICKLE_HEIGHT/2.0)-(SICKLE_WIDTH/2.0)+CENTER_DIFF)
#define TIP_HEIGHT 86.0
#define TIP_OFFSET (72.0/2)-3

#define MAX_POINTS 100
- (CGPoint *)outline:(int *)count {
    if (self.sickled) {
        static CGPoint *initialPoint;
        static int totalCount = 0;
        if (!initialPoint) {
            __block CGPoint *points = malloc(sizeof(CGPoint)*MAX_POINTS);
            initialPoint = points;
            __block int runningCount = 0;
            //const float heightAtTips = sqrtf(SICKLE_RADIUS*SICKLE_RADIUS - CENTER_DIFF*CENTER_DIFF/4.0);
            //start with outside ring
            //all points input to this block are in uncompressed coordinates, with origin at center of image
            void(^goToPoint)(float, float) = ^(float x, float y) {
                *points = CGPointMake(x*SCALE_DOWN_FACTOR, y*SCALE_DOWN_FACTOR);
                points++;
                runningCount++;
            };
            void(^goToOuterAngle)(float) = ^(float angle) {
                goToPoint(OUTER_CENTER_X+SICKLE_RADIUS*cosf(angle), SICKLE_RADIUS*sinf(angle));
            };
            void(^goToInnerAngle)(float) = ^(float angle) {
                goToPoint(INNER_CENTER_X+SICKLE_RADIUS*cosf(angle), SICKLE_RADIUS*sinf(angle));
            };
            //outside ring starts at angle from (outer_center, sickle_radius) to (outer_center+center_diff/2, sickle_radius+heightAtTips)
            float startingAngle = atan2f(TIP_HEIGHT, TIP_OFFSET);
            float endingAngle = -startingAngle+2*M_PI;
            for (double angle = startingAngle; angle<endingAngle-0.05; angle+=0.5) {
                goToOuterAngle(angle);
            }
            //now do the inside ring. go from negative to positive
            endingAngle = M_PI-startingAngle;
            startingAngle = 2*M_PI-endingAngle;
            for (double angle=startingAngle; angle>endingAngle+0.05; angle-=.3) {
                goToInnerAngle(angle);
            }
            totalCount=runningCount;
        }
        *count=totalCount;
        assert(totalCount<MAX_POINTS);
        return initialPoint;
    }
    return NULL;
}

- (instancetype)init {
    if (self=[self initOxygenated:YES sickle:NO]) {
        
    }
    return self;
}

- (instancetype)initOxygenated:(BOOL)oxygenated sickle:(BOOL)sickled {
    if (self=[super init]) {
        _oxygenated=oxygenated;
        _sickled=sickled;
        self.oxygenated=oxygenated;
        self.sickled=sickled;
        self.node.physicsBody.restitution=1;
        self.node.physicsBody.linearDamping=.3;
    }
    return self;
}

@end
