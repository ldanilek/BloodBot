//
//  BBRobot.h
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBObject.h"

@interface BBRobot : BBObject

- (void)applyAcceleration:(CGVector)acceleration;//force is applied to a specific part on the robot

@end
