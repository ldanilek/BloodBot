//
//  BBRobot.h
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
/*
typedef enum {
    BBLevelVeinHIV,
    BBLevelVeinBacteria,
    BBLevelArteryHIV,
    BBLevelArteryBacteria,
    BBLevelVeinHIVSickle,
    BBLevelVeinBacteriaSickle,
    BBLevelVeinMalaria,
    BBLevelVeinMalariaSickle,
} BBLevelType;
*/
typedef enum {
    BBLocationVenaCava,
    BBLocationPulmonaryArtery,
    BBLocationPulmonaryVein,
    BBLocationCarotidArtery,
} BBLocation;

#define LOCATIONS 4

typedef enum {
    BBPersonAverage,
    BBPersonSickle
} BBPerson;

#define PEOPLE 2

typedef enum {
    BBPathogenTB,
    BBPathogenHIV,
    BBPathogenMalaria,
} BBPathogenType;

#define PATHOGENS 3

//range of 0 to 5
static double bloodSpeed(BBLocation location) {
    switch (location) {
        case BBLocationCarotidArtery://from the left ventricle. strongest
            return 5;
            break;
            
        case BBLocationPulmonaryArtery://from the right ventricle. strong
            return 4;
            break;
            
        case BBLocationPulmonaryVein://from the lungs. not too strong
            return 3;
            break;

        case BBLocationVenaCava://from the body. not strong at all
            return 1;
            break;

        default:
            break;
    }
    return 0;
}
static BOOL isOxygenated(BBLocation location) {
    return location==BBLocationPulmonaryVein||location==BBLocationCarotidArtery;
}

typedef struct {
    BBPerson person;
    BBLocation location;
    BBPathogenType pathogenType;
} BBLevelType;

#define PRIME_NUM 31 //must be bigger than PATHOGENS, LOCATIONS, and PEOPLE (bigger than each)
static NSUInteger levelHash(BBLevelType levelType) {
    return levelType.person*PRIME_NUM*PRIME_NUM + levelType.location*PRIME_NUM + levelType.pathogenType;
}

static BBLevelType unhashLevel(NSUInteger hash) {
    BBLevelType level;
    level.pathogenType = hash % PRIME_NUM;
    hash /= PRIME_NUM;
    level.location = hash % PRIME_NUM;
    level.person = hash/PRIME_NUM;
    return level;
}

//abstract class
//do not interact with this class directly

@protocol BBObjectDelegate <NSObject>

- (BBLevelType)levelType;

@end

@interface BBObject : NSObject

@property BOOL displayed;

- (BOOL)nodeIs:(SKNode *)node;

@property id <BBObjectDelegate> delegate;

//designated initializer is init
//init does not create node or physics body, but they are lazily instantiated.

- (void)addToNode:(SKNode *)node;
- (void)remove;
@property (nonatomic) CGPoint position;
@property (nonatomic) CGVector velocity;//this is calculated every time called so don't call it more than necessary
@property (nonatomic) double angularVelocity;

- (BBObject *)otherObjectInCollision:(SKPhysicsContact *)collision possibleObjects:(NSSet *)objects;
- (BOOL)partOfCollision:(SKPhysicsContact *)collision;
- (void)absorbObject:(BBObject *)other;

- (void)grow;

#ifdef UNLOCK_BBOBJECT_PROTECTED //only define this in implementation files of subclasses

//implement in subclasses
- (CGPoint *)outline:(int *)count;//counterclockwise and not self-intersecting
- (NSString *)imageName;
- (double)radius;//for physicsbody only. if 0 (default), not circular

@property (strong, nonatomic) SKNode *node;
- (SKPhysicsBody *)physicsBody;

#endif

@end
