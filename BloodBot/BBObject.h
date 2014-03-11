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
    BBLevelVein,
    BBLevelArtery,
} BBLevelType;


//abstract class
//do not interact with this class directly

@protocol BBObjectDelegate <NSObject>

- (BBLevelType)levelType;

@end

@interface BBObject : NSObject

@property id <BBObjectDelegate> delegate;

//designated initializer is init

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

#endif

@end
