//
//  BBMyScene.m
//  BloodBot
//
//  Created by Lee Danilek on 3/5/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBMyScene.h"

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
@property (nonatomic) int pathogensKilledDirectly;//hit and killed by player
//@property (strong, nonatomic) SKSpriteNode *pathogenProportion;
@property (strong, nonatomic) SKLabelNode *pathogenLabel;
@property (strong, nonatomic) SKLabelNode *scoreLabel;
@property (strong, nonatomic) SKLabelNode *tutorialLabel;
@property int tutorialMessage;

@property double playerPower;
@property (strong, nonatomic) SKLabelNode *powerLabel;

@property int previousScore;

@property CFTimeInterval playingTime;//goes up from zero
@property CFTimeInterval currentTime;//system time of last frame

@property (nonatomic) double speedMultiplier;

@end

@implementation BBMyScene

#define PLASMA_MOVE_KEY @"move that plasma!"

- (void)setStopped:(BOOL)paused {
    if (_stopped != paused) {
        if (paused) {
            self.physicsWorld.speed = 0;
            [self stopPlasma];
        } else {
            self.physicsWorld.speed = 1;
            [self movePlasma];
        }
    }
    _stopped=paused;
}

- (SKLabelNode *)powerLabel {
    if (!_powerLabel) {
        _powerLabel=[[SKLabelNode alloc] initWithFontNamed:BBFONT];
        _powerLabel.fontSize=15;
        [self addChild:_powerLabel];
        _powerLabel.position=CGPointMake(self.size.width-50, 30);
    }
    return _powerLabel;
}

- (SKLabelNode *)pathogenLabel {
    if ([self.tutorialName isEqualToString:@"Navigation"]||[self.tutorialName isEqualToString:@"Obstacles"]) {
        return nil;
    }
    if (!_pathogenLabel) {
        _pathogenLabel=[[SKLabelNode alloc] initWithFontNamed:BBFONT];
        _pathogenLabel.fontSize=15;
        [self addChild:_pathogenLabel];
        _pathogenLabel.position=CGPointMake(self.size.width-50, 60);
    }
    return _pathogenLabel;
}

- (SKLabelNode *)scoreLabel {
    if ([self.tutorialName isEqualToString:@"Navigation"]) {
        return nil;
    }
    if (!_scoreLabel) {
        _scoreLabel=[[SKLabelNode alloc] initWithFontNamed:BBFONT];
        _scoreLabel.fontSize=15;
        [self addChild:_scoreLabel];
        _scoreLabel.position=CGPointMake(self.size.width-50, 90);
    }
    return _scoreLabel;
}

- (int)score {
    return self.playingTime*5;
}

- (void)displayScore {
    //score is directly related to time. good idea? maybe incorporate pathogens killed?
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.score];
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

//resistance probability grows with every killed cell.
- (double)resistanceProbability {
    //graph this to see what it looks like. X from 0 to 100. Y from 0 to 1
    if (self.levelType.pathogenType==BBPathogenTB) {
        return 2/(1+exp(-.02*self.pathogensKilled))-1;
    } else if (self.levelType.pathogenType==BBPathogenMalaria) {
        return 2/(1+exp(-.003*self.pathogensKilled))-1;
    }
    return 0;
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    //check for objects touched by player
    BBRedBloodCell *redCell = (BBRedBloodCell *)[self.player otherObjectInCollision:contact possibleObjects:self.redBloodCells];
    if ([redCell infectedMalaria]) {
        [self.player absorbObject:redCell];
        self.pathogensKilled++;
        self.pathogensKilledDirectly++;
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
            //[self.player grow];
            [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_DESTROYED object:[NSString stringWithFormat:@"Stay away from white blood cells. They patrol the bloodstream, eliminating foreign bodies, like pathogens and robots."]];
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
        }
    }
    BBPathogen *pathogen = (BBPathogen *)[self.player otherObjectInCollision:contact possibleObjects:self.pathogens];
    if (pathogen && !pathogen.resistant) {
        self.pathogensKilled++;
        self.pathogensKilledDirectly++;
        [self.player absorbObject:pathogen];
        self.playerPower+=pathogen.redBloodCellsAbsorbed * [BBRedBloodCell powerForLevelType:self.levelType];
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
                red.resistant=pathogen.resistant;
            } else {
                if (red.oxygenated) {
                    pathogen.redBloodCellsAbsorbed++;
                    red.oxygenated=NO;
                }
            }
        }
    }
    
    [self setPathogenGraphics];
}

#define DISTANCE_FACTOR 0.01
- (int)pointsDueToDistance {
    return -self.plasma.position.x*DISTANCE_FACTOR;
}

- (int)startingLives {
    //thirty is good sometimes
    if (self.levelType.location==BBLocationCarotidArtery) {
        //don't let much get to the brain
        return 20;
    }
    if (self.levelType.person==BBPersonSickle && [[self organProtecting] isEqualToString:@"heart"]) {
        return 20;
    }
    if (self.levelType.person==BBPersonSickle && self.levelType.pathogenType==BBPathogenMalaria) {
        return 40;
    }
    if (self.levelType.pathogenType==BBPathogenTB && [[self organProtecting] isEqualToString:@"lung"]) {
        //TB likes to infect lungs
        return 15;
    }
    return 30;
}

- (void)setPathogenGraphics {
    int currentScore = self.startingLives-self.pathogensMissed;
    if (self.previousScore!=currentScore) {
        self.pathogenLabel.text=[NSString stringWithFormat:@"Lives: %d", currentScore];
        self.previousScore=currentScore;
    }
}

- (void)setPathogensKilled:(int)pathogensKilled {
    if (_pathogensKilled!=pathogensKilled) {
        _pathogensKilled=pathogensKilled;
        [self setPathogenGraphics];
    }
}

- (NSString *)organProtecting {
    switch (self.levelType.location) {
        case BBLocationVenaCava:
            return @"heart";
            break;
            
        case BBLocationCarotidArtery:
            return @"brain";
            break;
            
        case BBLocationPulmonaryArtery:
            return @"lung";
            break;
            
        case BBLocationPulmonaryVein:
            return @"heart";
            break;
            
        default:
            break;
    }
    return @"ear";
}

- (NSString *)personsName {
    switch (self.levelType.person) {
        case BBPersonAverage:
            return @"Sue";
            break;
            
        case BBPersonSickle:
            return @"Larry";
            break;
            
        default:
            break;
    }
    return @"The Doctor";
}

- (NSString *)possessivePronoun {
    switch (self.levelType.person) {
        case BBPersonAverage:
            return @"her";
            break;
            
        case BBPersonSickle:
            return @"his";
            break;
            
        default:
            break;
    }
    return @"its";
}

- (void)setPathogensMissed:(int)pathogensMissed {
    if (_pathogensMissed!=pathogensMissed) {
        int increase = pathogensMissed-_pathogensMissed;
        _pathogensMissed=pathogensMissed;
        [self setPathogenGraphics];
        if (pathogensMissed>=self.startingLives) {
            [[NSNotificationCenter defaultCenter] performSelector:@selector(postNotification:) withObject:[NSNotification notificationWithName:PLAYER_DESTROYED object:[NSString stringWithFormat:@"%@'s %@ can't just keep absorbing pathogens. You caught %d, but let %d past your defenses.", self.personsName, self.organProtecting, self.pathogensKilled, self.pathogensMissed]] afterDelay:0];
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
        }
        self.plasma.speed*=pow(1.05, increase);
        self.speedMultiplier*=pow(1.05, increase);
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

#define LESS_OXYGENATED .5
#define MORE_OXYGENATED 1

//all things should have the same ranges of speeds, because they've just been bouncing around together. why would any of them tend to be going faster? maybe if they had different masses. hmm
#define MIN_VX -40
#define MAX_VX 0
#define MIN_VY -40
#define MAX_VY 40

- (CGVector)initialVelocityMake {
    return CGVectorMake(uniform(MIN_VX, MAX_VX)*self.speedMultiplier, uniform(MIN_VY, MAX_VY));
}

- (void)addRedBloodCell {
    BOOL oxygenated = YES;
    if (!isOxygenated(self.levelType.location)) {
        oxygenated=uniform(0, 1)<LESS_OXYGENATED;
    }
    BBRedBloodCell *red = [[BBRedBloodCell alloc] initOxygenated:oxygenated sickle:isSickle(self.levelType.person)];
    red.delegate=self;
    red.position=[self randomRightPlasmaLocation];
    //get it going.
    //change momentum. starting momentum is 0. calculate ending momentum
    //vx is between -1 and -4 m/s
    //vy is between -3 and 3 m/s
    //how do meters map to pixels? I had to fudge the numbers for this one
    [red addToNode:self.plasma];
    [self.redBloodCells addObject:red];
    red.velocity = [self initialVelocityMake];
    red.angularVelocity=uniform(-1, 1);
}

- (void)addWhiteBloodCell {
    BBWhiteBloodCell *white = [[BBWhiteBloodCell alloc] init];
    white.delegate=self;
    white.position=[self randomRightPlasmaLocation];
    
    [white addToNode:self.plasma];
    [self.whiteBloodCells addObject:white];

    white.velocity= [self initialVelocityMake];
    white.angularVelocity=uniform(-1, 1);
}

- (void)addPathogen {
    BOOL willBeResistant = ( uniform(0, 1) < [self resistanceProbability] );
    BBPathogen *pathogen = [[BBPathogen alloc] initWithType:self.levelType.pathogenType resistant:willBeResistant];
    pathogen.delegate=self;
    pathogen.position=[self randomRightPlasmaLocation];
    NSLog(@"new pathogen with %g chance of resistance", [self resistanceProbability]);
    
    [pathogen addToNode:self.plasma];
    [self.pathogens addObject:pathogen];
    [self setPathogenGraphics];
    
    pathogen.velocity= [self initialVelocityMake];
    pathogen.angularVelocity=uniform(-1, 1);
}

- (double)speedMultiplier {
    if (!_speedMultiplier) {
        _speedMultiplier = bloodSpeed(self.levelType.location);
    }
    return _speedMultiplier;
}

#define WAIT_BETWEEN_ADDING .2
//average frequency of adding
- (double)redCellFrequency {
    double freq = 1 * self.speedMultiplier;
    return freq;
}
- (double)whiteCellFrequency {
    if ([self.tutorialName isEqualToString:@"Navigation"]) {
        return 0;
    }
    return .5 * self.speedMultiplier;
}
- (double)pathogenFrequency {
    if ([self.tutorialName isEqualToString:@"Navigation"]||[self.tutorialName isEqualToString:@"Obstacles"]) {
        return 0;
    }
    double freq = 1;
    if (isSickle(self.levelType.person)&&self.levelType.pathogenType==BBPathogenHIV) {
        freq/=5;
    }
    return freq * self.speedMultiplier;
}

//these should not be affected by the type of blood they're in
- (double)hivFrequency {//frequency that a hiv-infected white blood cell will create more HIV pathogens.
    if (isSickle(self.levelType.person)) {
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

#define MIN_MALARIA_CREATED 1
#define MAX_MALARIA_CREATED 1
- (void)addMalaria {
    double malariaFrequency = WAIT_BETWEEN_ADDING*[self malariaFrequency];
    for (BBRedBloodCell *rbc in self.redBloodCells) {
        if ([rbc infectedMalaria] && uniform(0, 1)<malariaFrequency) {
            int randomNumber = uniform(MIN_MALARIA_CREATED, MAX_MALARIA_CREATED+1);
            for (int i=0; i<randomNumber; i++) {
                BBPathogen *malaria = [[BBPathogen alloc] initWithType:BBPathogenMalaria resistant:rbc.resistant];
                
                malaria.delegate=self;
                malaria.position=rbc.position;
                malaria.velocity=rbc.velocity;
                
                [malaria addToNode:self.plasma];
                [self.pathogens addObject:malaria];
            }
            [rbc removeNow];
        }
    }
}

- (void)createObjects {
    if (!self.stopped) {
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
    
    [self performSelector:@selector(createObjects) withObject:nil afterDelay:WAIT_BETWEEN_ADDING];
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        
        self.backgroundColor = [SKColor blackColor];
        
        [self addChild:self.plasma];
        [self.player addToNode:self.plasma];
        
        self.player.position=[self convertPoint:CGPointMake([self playerX], self.size.height/2) toNode:self.plasma];
        
        //create bottom wall
        SKSpriteNode *bottomWall = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(size.width*100, 40)];
        bottomWall.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.plasma.frame));
        bottomWall.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:bottomWall.size];
        bottomWall.physicsBody.dynamic=NO;
        [self addChild:bottomWall];
        
        //create top wall
        SKSpriteNode *topWall = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(size.width*100, 40)];
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
        [self performSelector:@selector(createObjects) withObject:nil afterDelay:WAIT_BETWEEN_ADDING];
    }
    return self;
}

- (void)setTutorialName:(NSString *)tutorialName {
    _tutorialName=tutorialName;
    if (tutorialName!=nil) {
        SKLabelNode *label = [[SKLabelNode alloc] initWithFontNamed:BBFONT];
        label.text=tutorialName;
        label.fontSize=25;
        label.position=CGPointMake(self.size.width/2, 30);
        label.color=[SKColor whiteColor];
        [self addChild:label];
        self.tutorialLabel = label;
        [self performSelector:@selector(displayTutorialMessage) withObject:nil afterDelay:2];
    }
}

- (void)displayTutorialMessage {
    if (self.tutorialMessage<self.tutorialMessages.count) {
        self.tutorialLabel.text = self.tutorialMessages[self.tutorialMessage];
        self.tutorialMessage++;
        [self performSelector:@selector(displayTutorialMessage) withObject:nil afterDelay:8];
    }
}

- (NSArray *)tutorialMessages {
    if ([self.tutorialName isEqualToString:@"Navigation"]) {
        return @[@"You are controlling a blue robot in someone's bloodstream", @"Hold down your finger to attract the robot", @"Hold farther from the robot to pull harder", @"Bump into oxygenated red blood cells to increase fuel", @"When you have more fuel, you pull harder", @"The harder you pull, the faster you use up your fuel", @"Pause at any time by tapping with two fingers", @"You can bounce off the top and bottom, but don't go too far left", @"The bloodstream travels at different speeds in different parts of the body", @""];
    } else if ([self.tutorialName isEqualToString:@"Obstacles"]) {
        return @[@"White blood cells identify invaders, like robots, and destroy them", @"Avoid white blood cells as much as possible", @""];
    } else if ([self.tutorialName isEqualToString:@"Pathogens"]) {
        NSMutableArray *messages = [NSMutableArray arrayWithObjects:@"Pathogens and infected cells are orange with a green center", @"Your mission is to destroy as many pathogens as possible", @"Bounce the BloodBot against pathogens to destroy them", @"You lose lives when pathogens or infected cells escape", nil];
        if (self.levelType.pathogenType==BBPathogenHIV) {
            [messages addObject:@"HIV pathogens infect and reproduce through white blood cells"];
        } else {
            [messages addObject:@"White blood cells also destroy pathogens on contact"];
            [messages addObject:@"The more pathogens you kill, the more new pathogens will be resistant"];
            [messages addObject:@"Resistant pathogens have a blue outline"];
            [messages addObject:@"They can only be killed by white blood cells, not the BloodBot"];
        }
        [messages addObject:@"Like the BloodBot, pathogens also absorb oxygen from red blood cells"];
        [messages addObject:@"When you kill a pathogen, you get all of the fuel it had absorbed"];
        [messages addObject:@""];
        return [messages copy];
    }
    return nil;
}

- (void)setLevelType:(BBLevelType)levelType {
    _levelType=levelType;
    self.playerPower=[BBRedBloodCell powerForLevelType:self.levelType]*3;
}
         
- (void)movePlasma {
    int speed = -2000*self.speedMultiplier;
    [_plasma runAction:[SKAction repeatActionForever:[SKAction moveBy:CGVectorMake(speed, 0) duration:100]] withKey:PLASMA_MOVE_KEY];
}

- (void)stopPlasma {
    [_plasma removeActionForKey:PLASMA_MOVE_KEY];
}

- (void)viewDidAppear {
    [self movePlasma];
    self.previousScore=-1;
    //self.pathogensKilled=0;
    [self performSelector:@selector(pathogenLabel) withObject:nil afterDelay:.01];
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
    if (!self.stopped) {
        CFTimeInterval elapsedTime = currentTime-self.currentTime;
        if (elapsedTime<0.5) {//game was probably paused if time between frames is this long. Don't count as part of playing time.
            self.playingTime+=elapsedTime;
        }
        self.currentTime=currentTime;
        
        [self displayScore];
        
        if (self.touches && self.playerPower>0) {
            CGPoint targetPoint = [self.plasma convertPoint:self.targetOnScreen fromNode:self];
            CGFloat forceAngle = atan2(targetPoint.y-self.player.position.y, targetPoint.x-self.player.position.x);
            CGFloat distance = sqrtf(pow(self.player.position.y-targetPoint.y, 2)+pow(self.player.position.x-targetPoint.x, 2));
            CGFloat acceleration = self.playerPower/100000 * distance;
            [self.player applyAcceleration:CGVectorMake(acceleration*cos(forceAngle), acceleration*sin(forceAngle))];
            
            self.playerPower-=acceleration;
        }
        
        static int prevPower = -1;
        int newPower = 5*self.playerPower/[BBRedBloodCell powerForLevelType:self.levelType];
        if (prevPower!=newPower) {
            prevPower=newPower;
            self.powerLabel.text=[NSString stringWithFormat:@"Fuel: %d", newPower];
        }
        
        //scene coordinates
        int MIN_PLASMA_X = -40;
        int MAX_PLASMA_X = self.size.width+40;
        
        if ([self convertPoint:self.player.position fromNode:self.plasma].x<MIN_PLASMA_X) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_DESTROYED object:[NSString stringWithFormat:@"%@'s having enough trouble without you getting a robot stuck in %@ %@.", self.personsName, [self possessivePronoun], [self organProtecting]]];
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
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
    }
    //previousTime=currentTime;
}

@end
