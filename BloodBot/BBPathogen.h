//
//  BBPathogen.h
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBObject.h"

@interface BBPathogen : BBObject

//don't change after initialization
@property (nonatomic) BBPathogenType pathogenType;

//convenience initializer. not resistant
- initWithType:(BBPathogenType)pathogenType;

//designated Initializer. call init to make a bacterium
- (instancetype)initWithType:(BBPathogenType)pathogenType resistant:(BOOL)resistant;

@property int redBloodCellsAbsorbed;//player can steal energy eaten by pathogens!

@property BOOL resistant;//to being attacked by player

@end
