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
@property CGPoint targetPoint;
@property (strong, nonatomic) NSMutableSet *redBloodCells;//set of SKNodes
@property (strong, nonatomic) NSMutableSet *whiteBloodCells;
@property (strong, nonatomic) NSMutableSet *pathogens;

@property (nonatomic) int pathogensKilled;
@property (nonatomic) int pathogensMissed;
//@property (strong, nonatomic) SKSpriteNode *pathogenProportion;
@property (strong, nonatomic) SKLabelNode *pathogenLabel;

@property double playerPower;
@property (strong, nonatomic) SKLabelNode *powerLabel;

@end

@implementation BBMyScene

- (SKLabelNode *)powerLabel {
    if (!_powerLabel) {
        _powerLabel=[[SKLabelNode alloc] initWithFontNamed:@"Chalkboard"];
        _powerLabel.fontSize=15;
        [self addChild:_powerLabel];
        _powerLabel.position=CGPointMake(self.size.width-50, 30);
    }
    return _powerLabel;
}

- (SKLabelNode *)pathogenLabel {
    if (!_pathogenLabel) {
        _pathogenLabel=[[SKLabelNode alloc] initWithFontNamed:@"Chalkboard"];
        _pathogenLabel.fontSize=15;
        [self addChild:_pathogenLabel];
        _pathogenLabel.position=CGPointMake(self.size.width-50, 60);
    }
    return _pathogenLabel;
}

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
    //check for objects touched by player
    BBRedBloodCell *redCell = (BBRedBloodCell *)[self.player otherObjectInCollision:contact possibleObjects:self.redBloodCells];
    if (redCell && redCell.oxygenated) {
        self.playerPower+=[BBRedBloodCell power];
        redCell.oxygenated=NO;
        /*CGPoint cellPosition = redCell.position;
        
        //[self.player absorbObject:redCell];
        [redCell remove];
        BBRedBloodCell *deoxygenated = [[BBRedBloodCell alloc] init];
        [self.redBloodCells addObject:deoxygenated];
        deoxygenated.delegate=self;
        [deoxygenated addToNode:self.plasma];
        deoxygenated.position=cellPosition;*/
    }
    BBWhiteBloodCell *whiteCell = (BBWhiteBloodCell *)[self.player otherObjectInCollision:contact possibleObjects:self.whiteBloodCells];
    if (whiteCell) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_DESTROYED object:nil];
    }
    BBPathogen *pathogen = (BBPathogen *)[self.player otherObjectInCollision:contact possibleObjects:self.pathogens];
    if (pathogen) {
        self.pathogensKilled++;
        [self.player absorbObject:pathogen];
        [pathogen remove];
    }
    
    if (!whiteCell) {//white cell didn't touch player. check if it touched pathogen
        for (BBWhiteBloodCell *white in self.whiteBloodCells) {
            if ([white partOfCollision:contact]) {
                whiteCell=white;
            }
        }
        pathogen = (BBPathogen *)[whiteCell otherObjectInCollision:contact possibleObjects:self.pathogens];
        if (pathogen) {
            self.pathogensKilled++;
            [whiteCell absorbObject:pathogen];
            [pathogen remove];
        }
    }
    
    [self setPathogenGraphics];
}

#define DISTANCE_FACTOR 0.003
- (int)pointsDueToDistance {
    return -self.plasma.position.x*DISTANCE_FACTOR;
}

- (int)score {
    return self.pathogensKilled-self.pathogensMissed+[self pointsDueToDistance];
}

- (void)setPathogenGraphics {
    static int prevScore = -1;
    int currentScore = self.score;
    if (prevScore!=currentScore) {
        self.pathogenLabel.text=[NSString stringWithFormat:@"Score: %d", currentScore];
        prevScore=currentScore;
    }
}

#define PLASMA_MOVE_KEY @"MOVE"

- (void)setPathogensKilled:(int)pathogensKilled {
    if (_pathogensKilled!=pathogensKilled) {
        _pathogensKilled=pathogensKilled;
        [self setPathogenGraphics];
    }
}

- (void)setPathogensMissed:(int)pathogensMissed {
    if (_pathogensMissed!=pathogensMissed) {
        _pathogensMissed=pathogensMissed;
        [self.plasma removeActionForKey:PLASMA_MOVE_KEY];
        [self movePlasma];
    }
}

- (CGFloat)playerX {
    return self.size.width/2;
}

- (BBRobot *)player {
    if (!_player) {
        _player = [[BBRobot alloc] init];//[[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(10,30)];
        _player.delegate=self;
    }
    return _player;
}

- (SKSpriteNode *)plasma {
    if (!_plasma) {
        _plasma = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(self.frame.size.width*100, self.frame.size.height)];
        _plasma.anchorPoint=CGPointMake(0, .5);
        _plasma.position=CGPointMake(CGRectGetMinX(self.frame), CGRectGetMidY(self.frame));
    }
    return _plasma;
}

- (CGPoint)randomRightPlasmaLocation {
    return [self convertPoint:CGPointMake(self.size.width+40, uniform(15, self.size.height-15)) toNode:self.plasma];
}

#define VEIN_OXYGENATED .6

- (void)addRedBloodCell {
    BOOL oxygenated = YES;
    if (self.levelType==BBLevelVein) {
        oxygenated=uniform(0, 1)<VEIN_OXYGENATED;
    }
    BBRedBloodCell *red = [[BBRedBloodCell alloc] initOxygenated:oxygenated];
    red.delegate=self;
    red.position=[self randomRightPlasmaLocation];
    //get it going.
    //change momentum. starting momentum is 0. calculate ending momentum
    //vx is between -1 and -4 m/s
    //vy is between -3 and 3 m/s
    //how do meters map to pixels? I had to fudge the numbers for this one
    [red addToNode:self.plasma];
    [self.redBloodCells addObject:red];
    red.velocity = CGVectorMake(uniform(-10, -30), uniform(-30, 30));
    red.angularVelocity=uniform(-1, 1);
}

- (void)addWhiteBloodCell {
    BBWhiteBloodCell *white = [[BBWhiteBloodCell alloc] init];
    white.delegate=self;
    white.position=[self randomRightPlasmaLocation];
    
    [white addToNode:self.plasma];
    [self.whiteBloodCells addObject:white];

    white.velocity=CGVectorMake(uniform(-50, -80), uniform(-50, 50));
    white.angularVelocity=uniform(-1, 1);
}

- (void)addPathogen {
    BBPathogen *pathogen = [[BBPathogen alloc] init];
    pathogen.delegate=self;
    pathogen.position=[self randomRightPlasmaLocation];
    
    [pathogen addToNode:self.plasma];
    [self.pathogens addObject:pathogen];
    [self setPathogenGraphics];
    
    pathogen.velocity=CGVectorMake(uniform(-60, -100), uniform(-40, 40));
    pathogen.angularVelocity=uniform(-1, 1);
}

#define WAIT_BETWEEN_ADDING .2
//average frequency of adding
- (double)redCellFrequency {
    double freq = UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()? 4: 2;
    if (self.levelType==BBLevelArtery) {
        freq*=8;
    }
    return freq;
}
- (double)whiteCellFrequency {
    return UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()? .7: .3;
}
- (double)pathogenFrequency {
    return UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()?1:.5;
}

- (void)createObjects {
    //probability of adding red blood cell = WAIT_BETWEEN_ADDING * BLOOD_CELLS_PER_SECOND
    double redCells = WAIT_BETWEEN_ADDING * [self redCellFrequency];
    while (redCells>1) {
        [self addRedBloodCell];
        redCells--;
    }
    double whiteCells = WAIT_BETWEEN_ADDING * [self whiteCellFrequency];
    while (whiteCells > 1) {
        [self addWhiteBloodCell];
        whiteCells--;
    }
    double pathogens = WAIT_BETWEEN_ADDING * [self pathogenFrequency];
    while (pathogens > 1) {
        pathogens--;
        [self addPathogen];
    }
    if (uniform(0, 1)<redCells)[self addRedBloodCell];
    if (uniform(0, 1)<whiteCells)[self addWhiteBloodCell];
    if (uniform(0, 1)<pathogens) {
        [self addPathogen];
    }
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];
        
        self.playerPower=[BBRedBloodCell power]*10;
        
        [self addChild:self.plasma];
        [self.player addToNode:self.plasma];
        
        self.player.position=[self convertPoint:CGPointMake([self playerX], self.size.height/2) toNode:self.plasma];
        
        //create bottom wall
        SKSpriteNode *bottomWall = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(size.width*100, 10)];
        bottomWall.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.plasma.frame));
        bottomWall.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:bottomWall.size];
        bottomWall.physicsBody.dynamic=NO;
        [self addChild:bottomWall];
        
        //create top wall
        SKSpriteNode *topWall = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(size.width*100, 10)];
        topWall.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.plasma.frame));
        topWall.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:topWall.size];
        topWall.physicsBody.dynamic=NO;
        [self addChild:topWall];
        
        self.physicsWorld.gravity=CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate=self;
        
        //create run loop for creating new objects
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:WAIT_BETWEEN_ADDING], [SKAction performSelector:@selector(createObjects) onTarget:self]]]]];
    }
    return self;
}
         
- (void)movePlasma {
    int speed = -2000;
    if (BBLevelArtery==self.levelType) {
        speed*=8;
    }
    speed-=100*self.pathogensMissed;
    [_plasma runAction:[SKAction repeatActionForever:[SKAction moveBy:CGVectorMake(speed, 0) duration:100]] withKey:PLASMA_MOVE_KEY];
}

- (void)viewDidAppear {
    [self movePlasma];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    //start moving player up
    self.driving=YES;
    self.targetPoint =[[touches anyObject] locationInNode:self.plasma];
    
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
        self.targetPoint=[[touches anyObject] locationInNode:self.plasma];
    }
}

- (BOOL)loops {
    return NO;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    static CFTimeInterval previousTime = 0;
    if (!previousTime) previousTime=currentTime;
    //CFTimeInterval timestep = currentTime-previousTime;
    
    if (self.driving && self.playerPower>0) {
        CGFloat forceAngle = atan2(self.targetPoint.y-self.player.position.y, self.targetPoint.x-self.player.position.x);
        CGFloat acceleration = sqrtf(pow(self.player.position.y-self.targetPoint.y, 2)+pow(self.player.position.x-self.targetPoint.x, 2))/2;
        
        [self.player applyAcceleration:CGVectorMake(acceleration*cos(forceAngle), acceleration*sin(forceAngle))];
        self.playerPower-=acceleration;
        //NSLog(@"player power:%g", self.playerPower);
    }
    static int prevPower = 0;
    int newPower = self.playerPower/[BBRedBloodCell power];
    if (prevPower!=newPower) {
        prevPower=newPower;
        self.powerLabel.text=[NSString stringWithFormat:@"Power: %d", newPower];
    }
    
    //scene coordinates
    int MIN_PLASMA_X = -40;
    int MAX_PLASMA_X = self.size.width+40;
    
    if ([self convertPoint:self.player.position fromNode:self.plasma].x<MIN_PLASMA_X) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_DESTROYED object:nil];
    }
    
    //remove off-screen objects
    NSArray *inPlasma = [self.plasma.children copy];
    for (SKNode *node in inPlasma) {
        CGPoint point =[self convertPoint:node.position fromNode:self.plasma];
        if (point.x<MIN_PLASMA_X) {
            if ([self loops]) {
                node.position=[self convertPoint:CGPointMake(MAX_PLASMA_X, point.y) toNode:self.plasma];
            } else {
                [node removeFromParent];
                for (BBPathogen *pathogen in self.pathogens) {
                    if ([pathogen nodeIs:node]) {
                        self.pathogensMissed++;
                    }
                }
            }
            
        }
    }
    
    previousTime=currentTime;
}

@end
