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

@property CGPoint targetOnScreen;//in scene coordinates
@property (strong, nonatomic) NSMutableSet *redBloodCells;//set of SKNodes
@property (strong, nonatomic) NSMutableSet *whiteBloodCells;
@property (strong, nonatomic) NSMutableSet *pathogens;

@property (nonatomic) int pathogensKilled;
@property (nonatomic) int pathogensMissed;
//@property (strong, nonatomic) SKSpriteNode *pathogenProportion;
@property (strong, nonatomic) SKLabelNode *pathogenLabel;

@property double playerPower;
@property (strong, nonatomic) SKLabelNode *powerLabel;

@property int touches;

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
    if ([redCell infectedMalaria]) {
        [self.player absorbObject:redCell];
        self.pathogensKilled++;
        [redCell remove];
    } else if (redCell.oxygenated) {
        self.playerPower+=[BBRedBloodCell powerForLevelType:self.levelType];
        redCell.oxygenated=NO;
    }
    
    BBWhiteBloodCell *whiteCell = (BBWhiteBloodCell *)[self.player otherObjectInCollision:contact possibleObjects:self.whiteBloodCells];
    if (whiteCell) {
        if ([whiteCell infectedHIV]) {
            self.pathogensKilled+=[whiteCell score];
            [self.player absorbObject:whiteCell];
            [whiteCell remove];
            [self.whiteBloodCells removeObject:whiteCell];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_DESTROYED object:nil];
        }
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
            if (pathogen.pathogenType==BBPathogenHIV) {
                [whiteCell infectWithHIV];
            } else {
                self.pathogensKilled++;
                [whiteCell absorbObject:pathogen];
                [pathogen remove];
            }
        }
    }
    
    if (!pathogen) {//player and white cell didn't kill pathogen. check if pathogen touched rbc
        for (BBPathogen *pathogen in self.pathogens) {
            BBRedBloodCell *red = (BBRedBloodCell *)[pathogen otherObjectInCollision:contact possibleObjects:self.redBloodCells];
            if (pathogen.pathogenType==BBPathogenMalaria) {
                [red infectWithMalaria];
            } else {
                red.oxygenated=NO;
            }
        }
    }
    
    [self setPathogenGraphics];
}

#define DISTANCE_FACTOR 0.01
- (int)pointsDueToDistance {
    return -self.plasma.position.x*DISTANCE_FACTOR;
}

- (void)setPathogenGraphics {
    static int prevScore = -1;
    int currentScore = 100-self.pathogensMissed;
    if (prevScore!=currentScore) {
        self.pathogenLabel.text=[NSString stringWithFormat:@"Lives: %d", currentScore];
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
        _player = [[BBRobot alloc] init];
        _player.delegate=self;
    }
    return _player;
}

- (SKSpriteNode *)plasma {
    if (!_plasma) {
        _plasma = [[SKSpriteNode alloc] initWithColor:[SKColor colorWithRed:.5 green:0 blue:0 alpha:1] size:CGSizeMake(self.frame.size.width*100, self.frame.size.height)];
        _plasma.anchorPoint=CGPointMake(0, .5);
        _plasma.position=CGPointMake(CGRectGetMinX(self.frame), CGRectGetMidY(self.frame));
    }
    return _plasma;
}

- (CGPoint)randomRightPlasmaLocation {
    return [self convertPoint:CGPointMake(self.size.width+40, uniform(15, self.size.height-15)) toNode:self.plasma];
}

#define VEIN_OXYGENATED .6
#define ARTERY_OXYGENATED .9

- (void)addRedBloodCell {
    BOOL oxygenated = uniform(0, 1)<ARTERY_OXYGENATED;
    if (!isArtery(self.levelType.location)) {
        oxygenated=uniform(0, 1)<VEIN_OXYGENATED;
    }
    BBRedBloodCell *red = [[BBRedBloodCell alloc] initOxygenated:oxygenated sickle:isSickle(self.levelType)];
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
    BBPathogen *pathogen = [[BBPathogen alloc] initWithType:self.levelType.pathogenType];
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
    double freq = UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()? 5: 2;
    if (isArtery(self.levelType.location)) {
        freq*=5;
    }
    
    return freq;
}
- (double)whiteCellFrequency {
    return UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()? .5: .3;
}
- (double)pathogenFrequency {
    double freq = UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()?1:.5;
    if (isSickle(self.levelType)&&self.levelType.pathogenType==BBPathogenHIV) {
        freq/=5;
    }
    return freq;
}
- (double)hivFrequency {//frequency that a hiv-infected white blood cell will create more HIV pathogens.
    if (isSickle(self.levelType)) {
        return .1;
    }
    return .4;
}
- (double)malariaFrequency {//frequency that an malaria-infected rbc will burst into more malaria pathogens
    return .01;
}

- (void)addHIV {
    double hivFrequency = WAIT_BETWEEN_ADDING*[self hivFrequency];
    for (BBWhiteBloodCell *wbc in self.whiteBloodCells) {
        if ([wbc infectedHIV] && uniform(0, 1)<hivFrequency) {
            BBPathogen *pathogen = [[BBPathogen alloc] initWithType:BBPathogenHIV];
            
            pathogen.delegate=self;
            pathogen.position=wbc.position;
            
            [pathogen addToNode:self.plasma];
            [self.pathogens addObject:pathogen];
            [self setPathogenGraphics];
        }
    }
}

#define MIN_MALARIA_CREATED 2
#define MAX_MALARIA_CREATED 3
- (void)addMalaria {
    double malariaFrequency = WAIT_BETWEEN_ADDING*[self malariaFrequency];
    for (BBRedBloodCell *rbc in self.redBloodCells) {
        if ([rbc infectedMalaria] && uniform(0, 1)<malariaFrequency) {
            int randomNumber = uniform(MIN_MALARIA_CREATED, MAX_MALARIA_CREATED+1);
            for (int i=0; i<randomNumber; i++) {
                BBPathogen *malaria = [[BBPathogen alloc] initWithType:BBPathogenMalaria];
                
                malaria.delegate=self;
                malaria.position=rbc.position;
                malaria.velocity=rbc.velocity;
                
                [malaria addToNode:self.plasma];
                [self.pathogens addObject:malaria];
            }
            [rbc remove];
        }
    }
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
    [self addMalaria];
    [self addHIV];
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];
        
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
        
        SKSpriteNode *rightWall = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(50, self.frame.size.height)];
        rightWall.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:rightWall.size];
        rightWall.physicsBody.dynamic=NO;
        rightWall.position=CGPointMake(CGRectGetMaxX(self.frame)+100, CGRectGetMidY(self.frame));
        [self addChild:rightWall];
        
        self.physicsWorld.gravity=CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate=self;
        
        //create run loop for creating new objects
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:WAIT_BETWEEN_ADDING], [SKAction performSelector:@selector(createObjects) onTarget:self]]]]];
    }
    return self;
}

- (void)setLevelType:(BBLevelType)levelType {
    _levelType=levelType;
    self.playerPower=[BBRedBloodCell powerForLevelType:self.levelType]*10;
}
         
- (void)movePlasma {
    int speed = -2000;
    if (isArtery(self.levelType.location)) {
        speed*=8;
    }
    speed-=100*self.pathogensMissed;
    [_plasma runAction:[SKAction repeatActionForever:[SKAction moveBy:CGVectorMake(speed, 0) duration:100]] withKey:PLASMA_MOVE_KEY];
}

- (void)viewDidAppear {
    [self movePlasma];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.touches++;
    self.targetOnScreen =[[touches anyObject] locationInNode:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.touches--;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.targetOnScreen=[[touches anyObject] locationInNode:self];
}

- (BOOL)loops {
    return NO;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    static CFTimeInterval previousTime = 0;
    if (!previousTime) previousTime=currentTime;
    //CFTimeInterval timestep = currentTime-previousTime;
    
    if (self.touches && self.playerPower>0) {
        CGPoint targetPoint = [self.plasma convertPoint:self.targetOnScreen fromNode:self];
        CGFloat forceAngle = atan2(targetPoint.y-self.player.position.y, targetPoint.x-self.player.position.x);
        CGFloat distance = sqrtf(pow(self.player.position.y-targetPoint.y, 2)+pow(self.player.position.x-targetPoint.x, 2));
        CGFloat acceleration = self.playerPower/100000 * distance;
        [self.player applyAcceleration:CGVectorMake(acceleration*cos(forceAngle), acceleration*sin(forceAngle))];
        
        self.playerPower-=acceleration;
    }
    static int prevPower = 0;
    int newPower = self.playerPower/[BBRedBloodCell powerForLevelType:self.levelType];
    if (prevPower!=newPower) {
        prevPower=newPower;
        self.powerLabel.text=[NSString stringWithFormat:@"Fuel: %d", newPower];
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
                if (![self.player nodeIs:node]) {
                    [node removeFromParent];
                }
                for (BBPathogen *pathogen in self.pathogens) {
                    if ([pathogen nodeIs:node]) {
                        pathogen.displayed=NO;
                        self.pathogensMissed++;
                    }
                }
                for (BBWhiteBloodCell *wbc in self.whiteBloodCells) {
                    if ([wbc nodeIs:node]) {
                        wbc.displayed=NO;
                        self.pathogensMissed+=[wbc score];
                    }
                }
            }
            
        }
    }
    
    previousTime=currentTime;
}

@end
