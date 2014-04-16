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
#import <objc/runtime.h>

#import "AFAudioRouter.h"

@interface AFSoundManager : NSObject

typedef void (^progressBlock)(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error);

+(instancetype)sharedManager;

-(void)startPlayingLocalFileWithName:(NSString *)name andBlock:(progressBlock)block;
-(void)startStreamingRemoteAudioFromURL:(NSString *)url andBlock:(progressBlock)block;

-(void)pause;
-(void)resume;
-(void)stop;
-(void)restart;

-(void)changeVolumeToValue:(CGFloat)volume;
-(void)moveToSecond:(int)second;
-(NSDictionary *)retrieveInfoForCurrentPlaying;

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