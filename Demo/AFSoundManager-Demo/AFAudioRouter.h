//
//  AFAudioRouter.h
//  AFSoundManager
//
//  Created by Alvaro Franco on 4/16/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface AFAudioRouter : NSObject <AVAudioPlayerDelegate>

+(void)initAudioSessionRouting;
+(void)switchToDefaultHardware;
+(void)forceOutputToBuiltInSpeakers;

@end
