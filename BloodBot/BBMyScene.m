//
//  BBMyScene.m
//  BloodBot
//
//  Created by Lee Danilek on 3/5/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBMyScene.h"

/*
//this is an object on the screen. it moves with the background.
//coordinates (relative), graphics (UIImage), scale (relative), rotation (angle)
//this is an abstract class
//it responds to playerTouched:(player)
//objects move around when move: is called
//interactWithObjects: is called frequently. check for collisions here and change internal state accordingly.
 
@interface BBObject : NSObject

@property double x;
@property double y;
@property double angle;
@property double scale;
@property UIImage *graphics;

- (void)interactWithObjects:(NSOrderedSet *)objects;
- (void)move:(double)time;

//only to be used in subclasses
@property double vx;
@property double vy;

@end
*/

static double uniform(double min, double max) {
    return (max-min)*rand()/RAND_MAX+min;
}

@interface BBMyScene () <SKPhysicsContactDelegate>

@property BOOL driving;
@property double targetAngle;
@property (strong, nonatomic) NSMutableSet *redBloodCells;//set of SKNodes
@property (strong, nonatomic) NSMutableSet *whiteBloodCells;
@property (strong, nonatomic) NSMutableSet *pathogens;

@end

@implementation BBMyScene

- (NSMutableSet *)redBloodCells {
    if (!_redBloodCells) {
        _redBloodCells=[NSMutableSet set];
    }
    return _redBloodCells;
}

- (NSMutableSet *)whiteBloodCells{
    if (!_whiteBloodCells) {
        _whiteBloodCells=[NSMutableSet set];
    }
    return _whiteBloodCells;
}

- (NSMutableSet *)pathogens {
    if (!_pathogens) {
        _pathogens=[NSMutableSet set];
    }
    return _pathogens;
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKNode *objTouchedByPlayer;
    if (contact.bodyA.node==self.player) {
        objTouchedByPlayer=contact.bodyB.node;
    } else if (contact.bodyB.node==self.player) {
        objTouchedByPlayer=contact.bodyA.node;
    }
    
    if (objTouchedByPlayer) {
        if ([self.redBloodCells containsObject:objTouchedByPlayer]) {
            [self.redBloodCells removeObject:objTouchedByPlayer];
            [objTouchedByPlayer removeFromParent];
        } else if ([self.pathogens containsObject:objTouchedByPlayer]) {
            [objTouchedByPlayer removeFromParent];
        }
    }
    
    SKNode *objTouchedByWBC;
    if ([self.whiteBloodCells containsObject:contact.bodyA.node]) {
        objTouchedByWBC=contact.bodyB.node;
    } else if ([self.whiteBloodCells containsObject:contact.bodyB.node]) {
        objTouchedByWBC=contact.bodyA.node;
    }
    if (objTouchedByWBC) {
        if ([self.pathogens containsObject:objTouchedByWBC]) {
            [objTouchedByWBC removeFromParent];
        } else if (objTouchedByWBC==self.player) {
            [self.player removeFromParent];
        }
    }
}

- (SKSpriteNode *)player {
    if (!_player) {
        _player = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(30,10)];
        _player.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));//or screen center or something else
        _player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_player.size];
        _player.physicsBody.dynamic=YES;
        _player.physicsBody.contactTestBitMask=1;
        _player.physicsBody.angularDamping=1;
    }
    return _player;
}

- (SKSpriteNode *)plasma {
    if (!_plasma) {
        _plasma = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(self.frame.size.width*10, self.frame.size.height)];
        _plasma.anchorPoint=CGPointMake(0, 0);
        _plasma.position=CGPointMake(0, 0);
        [_plasma runAction:[SKAction repeatActionForever:[SKAction moveBy:CGVectorMake(-100, 0) duration:10]]];
    }
    return _plasma;
}

- (CGPoint)randomRightPlasmaLocation {
    return CGPointMake(self.frame.size.width-self.plasma.position.x, uniform(CGRectGetMinY(self.frame), CGRectGetMaxY(self.frame)));
}

- (void)addRedBloodCell {
    SKSpriteNode *red = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(10, 10)];
    red.position=[self randomRightPlasmaLocation];
    red.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:red.size];
    red.physicsBody.restitution=1;
    red.physicsBody.linearDamping=.3;//go with the flow
    //get it going.
    //change momentum. starting momentum is 0. calculate ending momentum
    //vx is between -1 and -4 m/s
    //vy is between -3 and 3 m/s
    //how do meters map to pixels? I had to fudge the numbers for this one
    
    [self.plasma addChild:red];
    [self.redBloodCells addObject:red];
    
    [red.physicsBody applyImpulse:CGVectorMake(uniform(-10, -30)*red.physicsBody.mass, uniform(-30, 30)*red.physicsBody.mass)];
}

- (void)addWhiteBloodCell {
    SKSpriteNode *white = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(15, 15)];
    white.position=[self randomRightPlasmaLocation];
    white.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:white.size];
    white.physicsBody.restitution=0;
    white.physicsBody.linearDamping=.2;
    
    [self.plasma addChild:white];
    [self.whiteBloodCells addObject:white];
    white.physicsBody.contactTestBitMask=2;
    
    [white.physicsBody applyImpulse:CGVectorMake(uniform(-50, -80)*white.physicsBody.mass, uniform(-50, 50)*white.physicsBody.mass)];
}

- (void)addPathogen {
    SKSpriteNode *pathogen = [[SKSpriteNode alloc] initWithColor:[SKColor orangeColor] size:CGSizeMake(12,12)];
    pathogen.position=[self randomRightPlasmaLocation];
    pathogen.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:pathogen.size];
    pathogen.physicsBody.restitution=0;
    pathogen.physicsBody.linearDamping=.05;
    
    [self.plasma addChild:pathogen];
    [self.pathogens addObject:pathogen];
    
    [pathogen.physicsBody applyImpulse:CGVectorMake(uniform(-60, -100)*pathogen.physicsBody.mass, uniform(-40, 40)*pathogen.physicsBody.mass)];
}

- (void)createObjects {
    [self addRedBloodCell];
    if (rand()%4==0)[self addWhiteBloodCell];
    if (rand()%5==0) {
        [self addPathogen];
    }
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];
        /*
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:myLabel];
        */
        [self addChild:self.plasma];
        [self.plasma addChild:self.player];
        
        
        //create bottom wall
        SKSpriteNode *bottomWall = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(size.width, 10)];
        bottomWall.position = CGPointMake(CGRectGetMidX(self.frame),
                                          CGRectGetMidY(self.frame)-110);//CGPointMake(size.width/2, size.height-30);
        bottomWall.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:bottomWall.size];
        bottomWall.physicsBody.dynamic=NO;
        [self addChild:bottomWall];
        
        //create top wall
        SKSpriteNode *topWall = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(size.width, 10)];
        topWall.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+110);
        topWall.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:topWall.size];
        topWall.physicsBody.dynamic=NO;
        [self addChild:topWall];
        
        self.physicsWorld.gravity=CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate=self;
        
        //create run loop for creating new objects
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:.5], [SKAction performSelector:@selector(createObjects) onTarget:self]]]]];
    }
    return self;
}

- (void)pointTowardsPoint:(CGPoint)point {
    self.targetAngle=atan2(point.y-self.player.position.y, point.x-self.player.position.x);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    //start moving player up
    self.driving=YES;
    [self pointTowardsPoint:[[touches anyObject] locationInNode:self.plasma]];
    
    //SKAction *moveUpAction = [SKAction moveBy:CGVectorMake(0, 1000) duration:1];
    //[self.player runAction:[SKAction repeatActionForever:moveUpAction] withKey:@"move up"];
    /*
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        sprite.position = location;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }*/
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.driving=NO;
    //[self.player removeActionForKey:@"move up"];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.driving) {
        [self pointTowardsPoint:[[touches anyObject] locationInNode:self.plasma]];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (self.driving) {
        /*double angleChangeRequired = self.targetAngle - self.player.zRotation;
        if (self.player.zRotation<self.targetAngle) {
            [self.player.physicsBody applyAngularImpulse:angleChangeRequired/10000];
        } else {
            [self.player.physicsBody applyAngularImpulse:angleChangeRequired/10000];
        }*/
        CGFloat forceAngle = self.targetAngle;
        CGFloat forceMagnitude = 60*self.player.physicsBody.mass;
        CGPoint forcePoint = [self convertPoint:self.player.position fromNode:self.plasma];
        forcePoint.x+=15*cos(self.player.zRotation);
        forcePoint.y+=15*sin(self.player.zRotation);
        [self.player.physicsBody applyForce:CGVectorMake(forceMagnitude*cos(forceAngle), forceMagnitude*sin(forceAngle)) atPoint:forcePoint];
    }
    
    //remove off-screen objects
    NSArray *inPlasma = [self.plasma.children copy];
    for (SKNode *node in inPlasma) {
        if (node.position.x+self.plasma.position.x<-10) {
            [node removeFromParent];
        }
    }
}

@end
