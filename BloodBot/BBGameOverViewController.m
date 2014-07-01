//
//  BBGameOverViewController.m
//  BloodBot
//
//  Created by Lee Danilek on 3/14/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBGameOverViewController.h"
#import "BBButtonView.h"

@interface BBGameOverViewController () <BBButtonDelegate>

@property (nonatomic, weak) UIImageView *screenshot;
@property BOOL loaded;

@end

@implementation BBGameOverViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)buttonPressed:(BBButtonView *)button {
    if ([button.text isEqualToString:@"Menu"]) {
        [self.delegate toMenu:self];
    } else if ([button.text isEqualToString:@"Resume"]) {
        [self.delegate resume:self];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.loaded) {
        self.view.backgroundColor=[UIColor blackColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.initialImage];
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        imageView.center=CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        [self.view addSubview:imageView];
        self.screenshot=imageView;
        imageView.alpha=.5;
        
        BBButtonView *button = [[BBButtonView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
        button.center = imageView.center;
        button.text=@"Menu";
        [self.view addSubview:button];
        button.delegate=self;
        
        CGPoint center = imageView.center;
        center.y-=150;
        if (self.justPaused) {
            BBButtonView *resumeButton = [[BBButtonView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
            resumeButton.center=center;
            resumeButton.text=@"Resume";
            [self.view addSubview:resumeButton];
            resumeButton.delegate=self;
        } else {
            UITextView *messageLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 400, 300)];
            messageLabel.editable=NO;
            messageLabel.scrollEnabled=NO;
            messageLabel.userInteractionEnabled=NO;
            messageLabel.selectable=NO;
            messageLabel.text = self.message;
            [self.view addSubview:messageLabel];
            messageLabel.center=center;
            messageLabel.backgroundColor=[UIColor clearColor];
            messageLabel.textColor=[UIColor whiteColor];
            messageLabel.textAlignment=NSTextAlignmentCenter;
            messageLabel.font=[UIFont fontWithName:BBFONT size:20];
        }
        
    }
    self.loaded = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
