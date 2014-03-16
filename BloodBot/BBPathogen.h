//
//  BBPathogen.h
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBObject.h"

typedef enum {
    BBPathogenBacteria,
    BBPathogenHIV,
    BBPathogenMalaria,
} BBPathogenType;

static BBPathogenType pathogenForLevel(BBLevelType levelType) {
    return (levelType==BBLevelArteryBacteria||levelType==BBLevelVeinBacteria||levelType==BBLevelVeinBacteriaSickle) ? BBPathogenBacteria : (levelType==BBLevelArteryHIV||levelType==BBLevelVeinHIV||levelType==BBLevelVeinHIVSickle) ? BBPathogenHIV : BBPathogenMalaria;
}

@interface BBPathogen : BBObject

//don't change after initialization
@property (nonatomic) BBPathogenType pathogenType;

//designated Initializer. call init to make a bacterium
- initWithType:(BBPathogenType)pathogenType;

@end
