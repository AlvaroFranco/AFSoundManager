//
//  AFSoundPlayback.h
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 21/01/15.
//  Copyright (c) 2015 AlvaroFranco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AFSoundItem.h"

typedef void (^feedbackBlock)(AFSoundItem *item);
typedef void (^finishedBlock)(void);

@interface AFSoundPlayback : NSObject

extern NSString *const AFSoundPlaybackStatus;
extern NSString *const AFSoundStatusDuration;
extern NSString *const AFSoundStatusTimeElapsed;

extern NSString *const AFSoundPlaybackFinishedNotification;

typedef NS_ENUM(NSInteger, AFSoundStatus) {
    
    AFSoundStatusNotStarted = 0,
    AFSoundStatusPlaying,
    AFSoundStatusPaused,
    AFSoundStatusFinished
};

-(id)initWithItem:(AFSoundItem *)item;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic) AFSoundStatus status;

@property (nonatomic, readonly) AFSoundItem *currentItem;

-(void)play;
-(void)pause;
-(void)restart;

-(void)playAtSecond:(NSInteger)second;

-(void)listenFeedbackUpdatesWithBlock:(feedbackBlock)block andFinishedBlock:(finishedBlock)finishedBlock;
-(NSDictionary *)statusDictionary;

@end