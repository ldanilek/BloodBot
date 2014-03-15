//
//  BBWhiteBloodCell.h
//  BloodBot
//
//  Created by Lee Danilek on 3/7/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBObject.h"

@interface BBWhiteBloodCell : BBObject

-(BOOL)infectedHIV;
-(void)infectWithHIV;
- (int)score;

@end
