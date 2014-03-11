//
//  BBRobot.m
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#define UNLOCK_BBOBJECT_PROTECTED
#import "BBObject.h"

@interface BBObject ()

@end

@implementation BBObject

- (double)angularVelocity {
    return self.node.physicsBody.angularVelocity;
}

- (void)setAngularVelocity:(double)angularVelocity {
    self.node.physicsBody.angularVelocity=angularVelocity;
}

- (CGPoint)position {
    return self.node.position;
}

- (void)setPosition:(CGPoint)position {
    self.node.position=position;
}

- (CGVector)velocity {
    return self.node.physicsBody.velocity;
}

- (void)setVelocity:(CGVector)velocity {
    self.node.physicsBody.velocity=velocity;
}

- (SKNode *)node {
    if (!_node) {
        _node = [[SKSpriteNode alloc] initWithImageNamed:[self imageName]];
        if ([self radius]) {
            _node.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius:[self radius]];
        } else {
            int count;
            CGPoint *outline = [self outline:&count];
            CGMutablePathRef ref = CGPathCreateMutable();
            CGPathMoveToPoint(ref, NULL, outline[count-1].x, outline[count-1].y);
            CGPathAddLines(ref, NULL, outline, count);
            CGPathRef path = CGPathCreateCopy(ref);
            _node.physicsBody=[SKPhysicsBody bodyWithPolygonFromPath:path];
        }
    }
    return _node;
}

- (BBObject *)otherObjectInCollision:(SKPhysicsContact *)collision possibleObjects:(NSSet *)objects {
    SKNode *otherNode;
    if (collision.bodyA.node==self.node) {
        otherNode = collision.bodyB.node;
    } else if (collision.bodyB.node==self.node) {
        otherNode = collision.bodyA.node;
    }
    for (BBObject *obj in objects) {
        if (obj.node==otherNode) {
            return obj;
        }
    }
    return nil;
}

- (BOOL)partOfCollision:(SKPhysicsContact *)collision {
    return self.node==collision.bodyA.node || self.node==collision.bodyB.node;
}

- (void)addToNode:(SKNode *)node {
    [node addChild:self.node];
}

- (void)remove {
    [self.node removeFromParent];
}

- (CGPoint *)outline:(int *)count { //counterclockwise and not self-intersecting
    abort();
}
- (NSString *)imageName {
    abort();
}
- (double)radius {
    return 0;
}

@end
