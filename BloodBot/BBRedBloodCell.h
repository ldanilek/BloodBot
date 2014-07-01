//
//  BBRedBloodCell.h
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBObject.h"

static BOOL isSickle(BBPerson person) {
    return person==BBPersonSickle;
}

@interface BBRedBloodCell : BBObject

- (id)initOxygenated:(BOOL)oxygenated sickle:(BOOL)sickled;//designated initializer

//do not set often. it resets the texture whenever you do
@property (nonatomic) BOOL oxygenated;
@property (nonatomic) BOOL sickled;

+ (double)powerForLevelType:(BBLevelType)levelType;

- (void)infectWithMalaria;
- (BOOL)infectedMalaria;
//- (void)runAction:(SKAction *)action;

- (BOOL)shouldBecomeMalaria;

@end
