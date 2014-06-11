//
//  AFAudioRouter.m
//  AFSoundManager
//
//  Created by Alvaro Franco on 4/16/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import "AFAudioRouter.h"

@implementation AFAudioRouter

#define IS_DEBUGGING NO
#define IS_DEBUGGING_EXTRA_INFO NO
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

+(void)initAudioSessionRouting {
    
    static BOOL audioSessionSetup = NO;
    if (audioSessionSetup == NO) {
        
        NSError *sessionError = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error: &sessionError];
        
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
        
        UInt32 doSetProperty = 1;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
        
        [[AVAudioSession sharedInstance] setDelegate:(id<AVAudioPlayerDelegate>)self];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        
        AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, onAudioRouteChange, nil);
        AudioSessionAddPropertyListener (kAudioSessionProperty_AudioInputAvailable, onAudioRouteChange, nil);
        
    }
    
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    audioSessionSetup = YES;
}

+(void)switchToDefaultHardware {

    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
}

+(void)forceOutputToBuiltInSpeakers {

    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
}

void onAudioRouteChange (void *clientData, AudioSessionPropertyID inID, UInt32 dataSize, const void* inData) {
    
    if( IS_DEBUGGING == YES ) {
        NSLog(@"==== Audio Harware Status ====");
        NSLog(@"Current Input:  %@", [AFAudioRouter getAudioSessionInput]);
        NSLog(@"Current Output: %@", [AFAudioRouter getAudioSessionOutput]);
        NSLog(@"Current hardware route: %@", [AFAudioRouter getAudioSessionRoute]);
        NSLog(@"==============================");
    }
    
    if( IS_DEBUGGING_EXTRA_INFO == YES ) {
        NSLog(@"==== Audio Harware Status (EXTENDED) ====");
        CFDictionaryRef dict = (CFDictionaryRef)inData;
        CFDictionaryRef oldRoute = CFDictionaryGetValue(dict, kAudioSession_AudioRouteChangeKey_PreviousRouteDescription);
        CFDictionaryRef newRoute = CFDictionaryGetValue(dict, kAudioSession_AudioRouteChangeKey_CurrentRouteDescription);
        NSLog(@"Audio old route: %@", oldRoute);
        NSLog(@"Audio new route: %@", newRoute);
        NSLog(@"=========================================");
    }
}

+(NSString *)getAudioSessionInput {
    
    UInt32 routeSize;
    AudioSessionGetPropertySize(kAudioSessionProperty_AudioRouteDescription, &routeSize);
    CFDictionaryRef desc;
    
    AudioSessionGetProperty (kAudioSessionProperty_AudioRouteDescription, &routeSize, &desc);
    
    CFArrayRef outputs = CFDictionaryGetValue(desc, kAudioSession_AudioRouteKey_Inputs);
    
    CFDictionaryRef diction = CFArrayGetValueAtIndex(outputs, 0);
    
    CFStringRef input = CFDictionaryGetValue(diction, kAudioSession_AudioRouteKey_Type);
    return [NSString stringWithFormat:@"%@", input];
}

+(NSString *)getAudioSessionOutput {
    
    UInt32 routeSize;
    AudioSessionGetPropertySize(kAudioSessionProperty_AudioRouteDescription, &routeSize);
    CFDictionaryRef desc;
    
    AudioSessionGetProperty (kAudioSessionProperty_AudioRouteDescription, &routeSize, &desc);
    
    CFArrayRef outputs = CFDictionaryGetValue(desc, kAudioSession_AudioRouteKey_Outputs);
    
    CFDictionaryRef diction = CFArrayGetValueAtIndex(outputs, 0);
    
    CFStringRef output = CFDictionaryGetValue(diction, kAudioSession_AudioRouteKey_Type);
    return [NSString stringWithFormat:@"%@", output];
}

+(NSString *)getAudioSessionRoute {
    
    UInt32 rSize = sizeof (CFStringRef);
    CFStringRef route;
    AudioSessionGetProperty (kAudioSessionProperty_AudioRoute, &rSize, &route);
    
    if (route == NULL) {
        NSLog(@"Silent switch is currently on");
        return @"None";
    }
    
    return [NSString stringWithFormat:@"%@", route];
}

@end
