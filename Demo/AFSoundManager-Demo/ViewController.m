//
//  ViewController.m
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 4/16/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import "ViewController.h"
#import "AFSoundManager.h"

@interface ViewController ()

@end

@implementation ViewController

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [_playLocalButton addTarget:self action:@selector(playLocalFile) forControlEvents:UIControlEventTouchUpInside];
    [_playRemoteButton addTarget:self action:@selector(playRemoteFile) forControlEvents:UIControlEventTouchUpInside];
    
    [_slider addTarget:self action:@selector(backOrForwardAudio:) forControlEvents:UIControlEventValueChanged];
    _slider.value = 0;
    
    [_segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    
    [_pauseButton addTarget:self action:@selector(pauseAudio) forControlEvents:UIControlEventTouchUpInside];
    [_playButton addTarget:self action:@selector(resumeAudio) forControlEvents:UIControlEventTouchUpInside];
    
    [_pauseButton setImage:[self invertImage:[UIImage imageNamed:@"pause.png"]] forState:UIControlStateNormal];
    [_playButton setImage:[self invertImage:[UIImage imageNamed:@"play.png"]] forState:UIControlStateNormal];
    
    [NSTimer scheduledTimerWithTimeInterval:1 block:^{
        
        if ([[AFSoundManager sharedManager]areHeadphonesConnected]) {
            [_segmentedControl setSelectedSegmentIndex:0];
            [_segmentedControl setEnabled:YES forSegmentAtIndex:0];
        } else {
            [_segmentedControl setSelectedSegmentIndex:1];
            [_segmentedControl setEnabled:NO forSegmentAtIndex:0];
        }
    } repeats:YES];
}

-(void)playLocalFile {
    
    [[AFSoundManager sharedManager]startPlayingLocalFileWithName:@"jazz.mp3" andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"mm:ss"];
        
        NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:elapsedTime];
        _elapsedTime.text = [formatter stringFromDate:elapsedTimeDate];
        
        NSDate *timeRemainingDate = [NSDate dateWithTimeIntervalSince1970:timeRemaining];
        _timeRemaining.text = [formatter stringFromDate:timeRemainingDate];
        
        _slider.value = percentage * 0.01;
    }];
}

-(void)playRemoteFile {
    
    [[AFSoundManager sharedManager]startStreamingRemoteAudioFromURL:_customURL.text andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
        
        if (!error) {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"mm:ss"];
            
            NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:elapsedTime];
            _elapsedTime.text = [formatter stringFromDate:elapsedTimeDate];
            
            NSDate *timeRemainingDate = [NSDate dateWithTimeIntervalSince1970:timeRemaining];
            _timeRemaining.text = [formatter stringFromDate:timeRemainingDate];
            
            _slider.value = percentage * 0.01;
        } else {
            
            NSLog(@"There has been an error playing the remote file: %@", [error description]);
        }
                
    }];
}

-(void)backOrForwardAudio:(UISlider *)sender {
    
    [[AFSoundManager sharedManager]moveToSection:sender.value];
}

-(void)pauseAudio {
    [[AFSoundManager sharedManager]pause];
}

-(void)resumeAudio {
    [[AFSoundManager sharedManager]resume];
}

-(void)segmentedControlChanged:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            [[AFSoundManager sharedManager]forceOutputToDefaultDevice];
            break;
        
        case 1:
            [[AFSoundManager sharedManager]forceOutputToBuiltInSpeakers];
            break;
            
        default:
            break;
    }
}

-(UIImage *)invertImage:(UIImage *)originalImage {
    
    UIGraphicsBeginImageContext(originalImage.size);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    CGRect imageRect = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
    [originalImage drawInRect:imageRect];
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, originalImage.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    CGContextClipToMask(UIGraphicsGetCurrentContext(), imageRect,  originalImage.CGImage);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor whiteColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, originalImage.size.width, originalImage.size.height));
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_customURL resignFirstResponder];
}

@end
