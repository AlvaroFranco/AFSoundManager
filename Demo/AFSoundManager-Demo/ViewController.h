//
//  ViewController.h
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 4/16/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *playLocalButton;
@property (nonatomic, strong) IBOutlet UIButton *playRemoteButton;

@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *pauseButton;

@property (nonatomic, strong) IBOutlet UITextField *customURL;

@property (nonatomic, strong) IBOutlet UILabel *elapsedTime;
@property (nonatomic, strong) IBOutlet UILabel *timeRemaining;
@property (nonatomic, strong) IBOutlet UISlider *slider;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;

@end
