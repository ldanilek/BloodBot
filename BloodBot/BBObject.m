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
        if ([self imageName]) {
            _node = [[SKSpriteNode alloc] initWithImageNamed:[self imageName]];
        } else {
            _node = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(30, 30)];
        }
        _node.physicsBody=[self physicsBody];
    }
    return _node;
}

- (SKPhysicsBody *)physicsBody {
    if ([self radius]) {
        return [SKPhysicsBody bodyWithCircleOfRadius:[self radius]];
    } else {
        int count;
        CGPoint *outline = [self outline:&count];
        CGMutablePathRef ref = CGPathCreateMutable();
        CGPathMoveToPoint(ref, NULL, outline[count-1].x, outline[count-1].y);
        CGPathAddLines(ref, NULL, outline, count);
        CGPathRef path = CGPathCreateCopy(ref);
        return [SKPhysicsBody bodyWithPolygonFromPath:path];
    }
}

- (BBObject *)otherObjectInCollision:(SKPhysicsContact *)collision possibleObjects:(NSSet *)objects {
    SKNode *otherNode;
    if (!self.displayed) {
        return nil;
    }
    if (collision.bodyA.node==self.node) {
        otherNode = collision.bodyB.node;
    } else if (collision.bodyB.node==self.node) {
        otherNode = collision.bodyA.node;
    }
    for (BBObject *obj in objects) {
        if (obj.node==otherNode && obj.displayed) {
            return obj;
        }
    }
    return nil;
}

- (BOOL)nodeIs:(SKNode *)node {
    return node==self.node;
}

- (void)absorbObject:(BBObject *)other {
    //self.node.physicsBody.mass+=other.node.physicsBody.mass;
}

- (void)grow {
    [self.node runAction:[SKAction scaleTo:2 duration:0]];
}

- (BOOL)partOfCollision:(SKPhysicsContact *)collision {
    if (!self.displayed) {
        return NO;
    }
    return self.node==collision.bodyA.node || self.node==collision.bodyB.node;
}

- (void)addToNode:(SKNode *)node {
    self.displayed=YES;
    [node addChild:self.node];
}

- (void)remove {
    [self.node runAction:[SKAction scaleTo:0 duration:.5] completion:^{
        self.displayed=NO;
        [self.node removeFromParent];
    }];
    
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
