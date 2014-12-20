//
//  AFSoundManager.h
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 4/16/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>

#import "AFAudioRouter.h"

typedef NS_ENUM (int, AFSoundManagerStatus) {
    AFSoundManagerStatusPlaying,
    AFSoundManagerStatusPaused,
    AFSoundManagerStatusStopped,
    AFSoundManagerStatusRestarted,
    AFSoundManagerStatusFinished
};

@class AFSoundManager;

@protocol AFSoundManagerDelegate

-(void)currentPlayingStatusChanged:(AFSoundManagerStatus)status;

@end

@interface AFSoundManager : NSObject

typedef void (^progressBlock)(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished);

+(instancetype)sharedManager;
@property (nonatomic, assign) id<AFSoundManagerDelegate> delegate;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVQueuePlayer *queuePlayer;

@property (nonatomic) int status;

-(void)startPlayingLocalFileWithName:(NSString *)name atPath:(NSString *)path withCompletionBlock:(progressBlock)block;
-(void)startStreamingRemoteAudioFromURL:(NSString *)url andBlock:(progressBlock)block;

-(void)pause;
-(void)resume;
-(void)stop;
-(void)restart;

-(BOOL)status:(AFSoundManagerStatus)status;

-(void)changeVolumeToValue:(CGFloat)volume;
-(void)changeSpeedToRate:(CGFloat)rate;
-(void)moveToSecond:(int)second;
-(void)moveToSection:(CGFloat)section;
-(NSDictionary *)retrieveInfoForCurrentPlaying;

-(void)startRecordingAudioWithFileName:(NSString *)name andExtension:(NSString *)extension shouldStopAtSecond:(NSTimeInterval)second;
-(void)pauseRecording;
-(void)resumeRecording;
-(void)stopAndSaveRecording;
-(void)deleteRecording;
-(NSInteger)timeRecorded;

-(BOOL)areHeadphonesConnected;
-(void)forceOutputToDefaultDevice;
-(void)forceOutputToBuiltInSpeakers;

@end

@interface NSTimer (Blocks)

+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;

@end

@interface NSTimer (Control)

-(void)pauseTimer;
-(void)resumeTimer;

@end
