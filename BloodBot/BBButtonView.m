//
//  LMButtonView.m
//  Lazer Maze
//
//  Created by Lee Danilek on 8/3/13.
//  Copyright (c) 2013 Ship Shape. All rights reserved.
//

#import "BBButtonView.h"

@interface BBButtonView ()

@property (nonatomic) BOOL depressed;

@end

@implementation BBButtonView

- (NSString *)currentTitle {
    return self.text;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor=[UIColor blackColor];
    }
    return _textColor;
}

- (UIFont *)font {
    if (!_font) {
        //NSArray *fontNames=[UIFont familyNames];
        _font= [UIFont fontWithName:BBFONT size:20];
        
    }
    return _font;
}

- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

- (void)setDepressed:(BOOL)depressed {
    _depressed=depressed;
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.depressed=YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.depressed=NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.depressed) {
        self.depressed=NO;
        [self.delegate buttonPressed:self];
    }
}

#define CANCEL_DISTANCE 50
#define IPAD_CANCEL_DISTANCE 100

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    int cancel = UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM() ? IPAD_CANCEL_DISTANCE: CANCEL_DISTANCE;
    UITouch *touch = [touches anyObject];
    CGPoint touchplace = [touch locationInView:self];
    self.depressed=CGRectContainsPoint(self.bounds, touchplace) || sqrt(pow(touchplace.x-self.bounds.size.width/2, 2)+pow(touchplace.y-self.bounds.size.height/2, 2))<cancel;
}

- (UIColor *)buttonColor {
    if (!_buttonColor) {
        _buttonColor=[UIColor whiteColor];
    }
    return _buttonColor;
}

- (double)radius {
    if (!_radius) {
        _radius=20;
    }
    return _radius;
}

#define STAR_SIZE 20.
#define SMALL_STAR_SIZE 10.

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.backgroundColor=[UIColor clearColor];
    [self.buttonColor setFill];
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.radius];
    [roundedRect fill];
    if (!self.depressed) {
        NSDictionary *attributes = @{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor};
        CGSize size = [self.text sizeWithAttributes:attributes];
        CGPoint topLeft = CGPointMake(self.bounds.size.width/2-size.width/2, self.bounds.size.height/2-size.height/2);
        [self.text drawAtPoint:topLeft withAttributes:attributes];
    }
    if (self.starColor) {
        UIBezierPath *star = [UIBezierPath bezierPath];
        double size = UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()?STAR_SIZE:SMALL_STAR_SIZE;
        CGPoint center = CGPointMake(size,size);
        CGFloat radius1 = size;
        CGFloat radius2 = size/2;
        CGFloat radius = radius2;
        [star moveToPoint:CGPointMake(size, 0)];
        double angle = 3*M_PI_2;
        double angleChange = 2*M_PI/10;
        for (int vertex=0; vertex<9; vertex++) {
            angle+=angleChange;
            [star addLineToPoint:CGPointMake(center.x+radius*cos(angle), center.y+radius*sin(angle))];
            radius=(radius==radius1 ? radius2 : radius1);
        }
        [self.starColor setFill];
        [star fill];
    }
}

@end
