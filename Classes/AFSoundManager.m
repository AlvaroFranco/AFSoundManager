//
//  AFSoundManager.m
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 4/16/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import "AFSoundManager.h"

@interface AFSoundManager ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) int type;
@property (nonatomic) int status;

@end

@implementation AFSoundManager

+(instancetype)sharedManager {
    
    static AFSoundManager *soundManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        soundManager = [[self alloc]init];
    });
    
    return soundManager;
}

-(void)startPlayingLocalFileWithName:(NSString *)name andBlock:(progressBlock)block {
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle]resourcePath], name];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSError *error = nil;
    
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:&error];
    [_audioPlayer play];
    
    __block int percentage = 0;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 block:^{
        
        if (percentage != 100) {
            
            percentage = (int)((_audioPlayer.currentTime * 100)/_audioPlayer.duration);
            int timeRemaining = _audioPlayer.duration - _audioPlayer.currentTime;
            
            block(percentage, _audioPlayer.currentTime, timeRemaining, error, NO);
        } else {
            
            int timeRemaining = _audioPlayer.duration - _audioPlayer.currentTime;

            block(100, _audioPlayer.currentTime, timeRemaining, error, YES);
            
            [_timer invalidate];
        }
    } repeats:YES];
}

-(void)startStreamingRemoteAudioFromURL:(NSString *)url andBlock:(progressBlock)block {
    
    NSURL *streamingURL = [NSURL URLWithString:url];
    NSError *error = nil;
    
    _player = [[AVPlayer alloc]initWithURL:streamingURL];
    [_player play];
    
    if (!error) {
    
        __block int percentage = 0;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 block:^{
            
            if (percentage != 100) {
                
                percentage = (int)((CMTimeGetSeconds(_player.currentItem.currentTime) * 100)/CMTimeGetSeconds(_player.currentItem.duration));
                int timeRemaining = CMTimeGetSeconds(_player.currentItem.duration) - CMTimeGetSeconds(_player.currentItem.currentTime);
                
                block(percentage, CMTimeGetSeconds(_player.currentItem.currentTime), timeRemaining, error, NO);
            } else {
                
                int timeRemaining = CMTimeGetSeconds(_player.currentItem.duration) - CMTimeGetSeconds(_player.currentItem.currentTime);
                
                block(100, CMTimeGetSeconds(_player.currentItem.currentTime), timeRemaining, error, YES);
                
                [_timer invalidate];
            }
        } repeats:YES];
    } else {
        
        block(0, 0, 0, error, YES);
        [_audioPlayer stop];
    }
    
}

-(NSDictionary *)retrieveInfoForCurrentPlaying {
    
    if (_audioPlayer.url) {
        
        NSArray *parts = [_audioPlayer.url.absoluteString componentsSeparatedByString:@"/"];
        NSString *filename = [parts objectAtIndex:[parts count]-1];
        
        NSDictionary *info = @{@"name": filename, @"duration": [NSNumber numberWithInt:_audioPlayer.duration], @"elapsed time": [NSNumber numberWithInt:_audioPlayer.currentTime], @"remaining time": [NSNumber numberWithInt:(_audioPlayer.duration - _audioPlayer.currentTime)], @"volume": [NSNumber numberWithFloat:_audioPlayer.volume]};
        
        return info;
    } else {
        return nil;
    }
}

-(void)pause {
    [_audioPlayer pause];
    [_player pause];
    [_timer pauseTimer];
}

-(void)resume {
    [_audioPlayer play];
    [_player play];
    [_timer resumeTimer];
}

-(void)stop {
    [_audioPlayer stop];
    _player = nil;
    [_timer pauseTimer];
}

-(void)restart {
    [_audioPlayer setCurrentTime:0];
    
    int32_t timeScale = _player.currentItem.asset.duration.timescale;
    [_player seekToTime:CMTimeMake(0.000000, timeScale)];
}

-(void)moveToSecond:(int)second {
    [_audioPlayer setCurrentTime:second];
    
    int32_t timeScale = _player.currentItem.asset.duration.timescale;
    [_player seekToTime:CMTimeMakeWithSeconds((Float64)second, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void)moveToSection:(CGFloat)section {
    int audioPlayerSection = _audioPlayer.duration * section;
    [_audioPlayer setCurrentTime:audioPlayerSection];
    
    int32_t timeScale = _player.currentItem.asset.duration.timescale;
    Float64 playerSection = CMTimeGetSeconds(_player.currentItem.duration) * section;
    [_player seekToTime:CMTimeMakeWithSeconds(playerSection, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void)changeSpeedToRate:(CGFloat)rate {
    _audioPlayer.rate = rate;
    _player.rate = rate;
}

-(void)changeVolumeToValue:(CGFloat)volume {
    _audioPlayer.volume = volume;
    _player.volume = volume;
}

-(void)startRecordingAudioWithFileName:(NSString *)name andExtension:(NSString *)extension shouldStopAtSecond:(NSTimeInterval)second {
    
    _recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.%@", [NSHomeDirectory() stringByAppendingString:@"/Documents"], name, extension]] settings:nil error:nil];
    
    if (second == 0 && !second) {
        [_recorder record];
    } else {
        [_recorder recordForDuration:second];
    }
}

-(void)pauseRecording {
    
    if ([_recorder isRecording]) {
        [_recorder pause];
    }
}

-(void)resumeRecording {
    
    if (![_recorder isRecording]) {
        [_recorder record];
    }
}

-(void)stopAndSaveRecording {
    [_recorder stop];
}

-(void)deleteRecording {
    [_recorder deleteRecording];
}

-(NSInteger)timeRecorded {
    return [_recorder currentTime];
}

-(BOOL)areHeadphonesConnected {
    
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance]currentRoute];
        
    BOOL headphonesLocated = NO;
    
    for (AVAudioSessionPortDescription *portDescription in route.outputs) {
        
        headphonesLocated |= ([portDescription.portType isEqualToString:AVAudioSessionPortHeadphones]);
    }
    
    return headphonesLocated;
}

-(void)forceOutputToDefaultDevice {
    
    [AFAudioRouter initAudioSessionRouting];
    [AFAudioRouter switchToDefaultHardware];
}

-(void)forceOutputToBuiltInSpeakers {
    
    [AFAudioRouter initAudioSessionRouting];
    [AFAudioRouter forceOutputToBuiltInSpeakers];
}

@end

@implementation NSTimer (Blocks)

+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
    
    void (^block)() = [inBlock copy];
    id ret = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(executeSimpleBlock:) userInfo:block repeats:inRepeats];
    
    return ret;
}

+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
    
    void (^block)() = [inBlock copy];
    id ret = [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(executeSimpleBlock:) userInfo:block repeats:inRepeats];
    
    return ret;
}

+(void)executeSimpleBlock:(NSTimer *)inTimer {
    
    if ([inTimer userInfo]) {
        void (^block)() = (void (^)())[inTimer userInfo];
        block();
    }
}

@end

@implementation NSTimer (Control)

static NSString *const NSTimerPauseDate = @"NSTimerPauseDate";
static NSString *const NSTimerPreviousFireDate = @"NSTimerPreviousFireDate";

-(void)pauseTimer {
    
    objc_setAssociatedObject(self, (__bridge const void *)(NSTimerPauseDate), [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, (__bridge const void *)(NSTimerPreviousFireDate), self.fireDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.fireDate = [NSDate distantFuture];
}

-(void)resumeTimer {
    
    NSDate *pauseDate = objc_getAssociatedObject(self, (__bridge const void *)NSTimerPauseDate);
    NSDate *previousFireDate = objc_getAssociatedObject(self, (__bridge const void *)NSTimerPreviousFireDate);
    
    const NSTimeInterval pauseTime = -[pauseDate timeIntervalSinceNow];
    self.fireDate = [NSDate dateWithTimeInterval:pauseTime sinceDate:previousFireDate];
}

@end
