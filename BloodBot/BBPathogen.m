//
//  BBPathogen.m
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#define UNLOCK_BBOBJECT_PROTECTED
#import "BBPathogen.h"

@interface BBPathogen ()

@property SKSpriteNode *node;

@end

@implementation BBPathogen

- (instancetype)initWithType:(BBPathogenType)pathogenType {
    if (self=[super init]) {
        self.pathogenType=pathogenType;
        self.node.physicsBody.restitution=0;
        self.node.physicsBody.linearDamping=.05;
        self.node.physicsBody.contactTestBitMask=3;
    }
    return self;
}

- (id)init {
    if (self=[self initWithType:BBPathogenBacteria]) {
        
    }
    return self;
}

@dynamic node;

- (NSString *)imageName {
    if (self.pathogenType==BBPathogenHIV) return @"diamond.png";
    else if (self.pathogenType==BBPathogenBacteria) return @"bacteria.png";
    else if (self.pathogenType==BBPathogenMalaria) return @"malaria.png";
    return nil;
}

- (CGPoint *)outline:(int *)count {
    //remember (0,0) is at center of image
    //up y is positive
    //go counterclockwise
    if (self.pathogenType==BBPathogenHIV) {
        static CGPoint points[4];
        points[0]=CGPointMake(15, 0);
        points[1]=CGPointMake(0, 15);
        points[2]=CGPointMake(-15, 0);
        points[3]=CGPointMake(0, -15);
        *count=4;
        return points;
    } else if (self.pathogenType==BBPathogenBacteria) {
        static CGPoint points[6];
        points[0]=CGPointMake(-12.5, 7.5);
        points[1]=CGPointMake(-22.5, 0);
        points[2]=CGPointMake(-12.5, -7.5);
        points[3]=CGPointMake(14.5, -7.5);
        points[4]=CGPointMake(22.5, 0);
        points[5]=CGPointMake(14.5, 7.5);
        *count=6;
        return points;
    }
    return NULL;
}

- (SKPhysicsBody *)physicsBody {
    if (self.pathogenType==BBPathogenBacteria||self.pathogenType==BBPathogenHIV) {
        return [super physicsBody];
    }
    int sqcount = 4;
    CGPoint sqoutline[4];
    int size=9;
    sqoutline[0]=CGPointMake(-size, size);
    sqoutline[1]=CGPointMake(-size, -size);
    sqoutline[2]=CGPointMake(size, -size);
    sqoutline[3]=CGPointMake(size, size);
    CGMutablePathRef sqref = CGPathCreateMutable();
    CGPathMoveToPoint(sqref, NULL, sqoutline[sqcount-1].x, sqoutline[sqcount-1].y);
    CGPathAddLines(sqref, NULL, sqoutline, sqcount);
    CGPathRef sqpath = CGPathCreateCopy(sqref);
    SKPhysicsBody *square = [SKPhysicsBody bodyWithPolygonFromPath:sqpath];
    
    int dicount = 4;
    CGPoint dioutline[4];
    size=12;
    dioutline[0]=CGPointMake(0, size);
    dioutline[1]=CGPointMake(-size, 0);
    dioutline[2]=CGPointMake(0, -size);
    dioutline[3]=CGPointMake(size, 0);
    CGMutablePathRef diref = CGPathCreateMutable();
    CGPathMoveToPoint(diref, NULL, dioutline[dicount-1].x, dioutline[dicount-1].y);
    CGPathAddLines(diref, NULL, dioutline, dicount);
    CGPathRef dipath = CGPathCreateCopy(diref);
    SKPhysicsBody *diamond = [SKPhysicsBody bodyWithPolygonFromPath:dipath];
    
    return [SKPhysicsBody bodyWithBodies:@[square, diamond]];
}

@end
