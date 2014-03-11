//
//  BBRedBloodCell.h
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBObject.h"

@interface BBRedBloodCell : BBObject

- (id)initOxygenated:(BOOL)oxygenated;

//do not set often. it resets the texture whenever you do
@property (nonatomic) BOOL oxygenated;

+ (double)power;

@end
