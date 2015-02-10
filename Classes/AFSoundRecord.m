//
//  AFSoundRecord.m
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 10/02/15.
//  Copyright (c) 2015 AlvaroFranco. All rights reserved.
//

#import "AFSoundRecord.h"
#import <AVFoundation/AVFoundation.h>

@interface AFSoundRecord ()

@property (nonatomic, strong) AVAudioRecorder *recorder;

@end

@implementation AFSoundRecord

-(id)initWithFilePath:(NSString *)filePath {
    
    if (self == [super init]) {
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:0 error:nil];
        [_recorder prepareToRecord];
    }
    
    return self;
}

-(void)startRecording {
    
    [_recorder record];
}

-(void)saveRecording {
    
    [_recorder stop];
}

-(void)cancelCurrentRecording {
    
    [_recorder stop];
    [_recorder deleteRecording];
}

@end
