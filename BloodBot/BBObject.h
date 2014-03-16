//
//  BBRobot.h
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

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

static BOOL isArtery(BBLevelType levelType) {
    return levelType==BBLevelArteryBacteria || levelType==BBLevelArteryHIV;
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

#ifdef UNLOCK_BBOBJECT_PROTECTED //only define this in implementation files of subclasses

//implement in subclasses
- (CGPoint *)outline:(int *)count;//counterclockwise and not self-intersecting
- (NSString *)imageName;
- (double)radius;//for physicsbody only. if 0 (default), not circular

@property (strong, nonatomic) SKNode *node;
- (SKPhysicsBody *)physicsBody;

#endif

@end
