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
    
    _player = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:&error];
    [_player play];
    
    __block int percentage = 0;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 block:^{
        
        if (percentage != 100) {
            
            percentage = (int)((_player.currentTime * 100)/_player.duration);
            int timeRemaining = _player.duration - _player.currentTime;
            
            block(percentage, _player.currentTime, timeRemaining, error, NO);
        } else {
            
            int timeRemaining = _player.duration - _player.currentTime;

            block(100, _player.currentTime, timeRemaining, error, YES);
            
            [_timer invalidate];
        }
    } repeats:YES];
}

-(void)startStreamingRemoteAudioFromURL:(NSString *)url andBlock:(progressBlock)block {
    
    NSURL *streamingURL = [NSURL URLWithString:url];
    NSData *streamingData = [NSData dataWithContentsOfURL:streamingURL];
    NSError *error = nil;
        
    _player = [[AVAudioPlayer alloc]initWithData:streamingData error:&error];
    [_player play];
    
    if (!error) {
    
        __block int percentage = 0;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 block:^{
            
            if (percentage != 100) {
                
                percentage = (int)((_player.currentTime * 100)/_player.duration);
                int timeRemaining = _player.duration - _player.currentTime;
                
                block(percentage, _player.currentTime, timeRemaining, error, NO);
            } else {
                
                int timeRemaining = _player.duration - _player.currentTime;
                
                block(100, _player.currentTime, timeRemaining, error, YES);
                
                [_timer invalidate];
            }
        } repeats:YES];
    } else {
        
        block(0, 0, 0, error, YES);
        [_player stop];
    }
    
}

-(NSDictionary *)retrieveInfoForCurrentPlaying {
    
    if (_player.url) {
        
        NSArray *parts = [_player.url.absoluteString componentsSeparatedByString:@"/"];
        NSString *filename = [parts objectAtIndex:[parts count]-1];
        
        NSDictionary *info = @{@"name": filename, @"duration": [NSNumber numberWithInt:_player.duration], @"elapsed time": [NSNumber numberWithInt:_player.currentTime], @"remaining time": [NSNumber numberWithInt:(_player.duration - _player.currentTime)], @"volume": [NSNumber numberWithFloat:_player.volume]};
        
        return info;
    } else {
        return nil;
    }
}

-(void)pause {
    [_player pause];
    [_timer pauseTimer];
}

-(void)resume {
    [_player play];
    [_timer resumeTimer];
}

-(void)stop {
    [_player stop];
    [_timer pauseTimer];
}

-(void)restart {
    [_player setCurrentTime:0];
}

-(void)moveToSecond:(int)second {
    [_player setCurrentTime:second];
}

-(void)moveToSection:(CGFloat)section {
    int audioSection = _player.duration * section;
    [_player setCurrentTime:audioSection];
}

-(void)changeSpeedToRate:(CGFloat)rate {
    _player.rate = rate;
}

-(void)changeVolumeToValue:(CGFloat)volume {
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
