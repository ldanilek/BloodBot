//
//  BBChooserViewController.h
//  BloodBot
//
//  Created by Lee Danilek on 5/31/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BBPathogenChooser,
    BBLocationChooser,//vein or artery, organ to protect
    BBPersonChooser,//for sickle and other things specific to the person
} BBChooserType;

@class BBChooserViewController;
@protocol BBChooserDelegate <NSObject>

- (void)chooser:(BBChooserViewController *)chooser chose:(int)chosen named:(NSString *)choiceName;

@end

@interface BBChooserViewController : UIViewController

@property (atomic, weak) id <BBChooserDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property BBChooserType chooserType;
@property int currentChoice;

@end
