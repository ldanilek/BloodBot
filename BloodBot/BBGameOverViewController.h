//
//  BBGameOverViewController.h
//  BloodBot
//
//  Created by Lee Danilek on 3/14/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBButtonView.h"

@class BBGameOverViewController;

@protocol BBGameOverProtocol <NSObject>

- (void)toMenu:(BBGameOverViewController *)vc;
@optional
- (void)resume:(BBGameOverViewController *)vc;

@end

@interface BBGameOverViewController : UIViewController

@property UIImage *initialImage;
@property (nonatomic, weak) id <BBGameOverProtocol> delegate;

@property BOOL justPaused;//include resume button
@property NSString *message;//just shown if game over, not just paused
@property BOOL highScore;//current score is high score

@end
