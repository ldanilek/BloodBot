//
//  LMButtonView.h
//  Lazer Maze
//
//  Created by Lee Danilek on 8/3/13.
//  Copyright (c) 2013 Ship Shape. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBButtonView;

@protocol BBButtonDelegate <NSObject>

- (void)buttonPressed:(BBButtonView *)button;

@end

@interface BBButtonView : UIView

@property (nonatomic, weak) id <BBButtonDelegate> delegate;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *buttonColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic) double radius;
@property (nonatomic, strong) UIColor *starColor;

- (NSString *)currentTitle;

@end
