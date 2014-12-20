AFSoundManager
==============

[![Build Status](https://travis-ci.org/AlvaroFranco/AFSoundManager.svg?branch=master)](https://travis-ci.org/AlvaroFranco/AFSoundManager)
[![alt text](https://cocoapod-badges.herokuapp.com/v/AFSoundManager/badge.png "")]()
[![alt text](https://cocoapod-badges.herokuapp.com/p/AFSoundManager/badge.png "")]()
[![alt text](https://camo.githubusercontent.com/f513623dcee61532125032bbf1ddffda06ba17c7/68747470733a2f2f676f2d736869656c64732e6865726f6b756170702e636f6d2f6c6963656e73652d4d49542d626c75652e706e67 "")]()

iOS audio playing (both local and streaming) and recording made easy through a complete and block-driven Objective-C class. AFSoundManager uses AudioToolbox and AVFoundation frameworks to serve the audio. You can pick a local file or you can use a URL to stream the audio, the choice is up to you.

![alt text](https://raw.github.com/AlvaroFranco/AFSoundManager/master/preview.png "Preview")

##Installation

AFSoundManager is available on CocoaPods so you can get it by adding this line to your Podfile:

	pod 'AFSoundManager'

If you don't use CocoaPods, you will have to import these files into your project:

	AFSoundManager.h
	AFSoundManager.m
	AFAudioRouter.h
	AFAudioRouter.m

Also, you need to import the ```AudioToolbox``` framework and te ```AudioFoundation``` framework.

##Usage

First of all, make sure that you have imported the main class into the class where you are going to play audio.

	#import "AFSoundManager.h"

Then, you only need to call one method to start playing your audio.

###Local playing
If you need to play a local file, call ```-startPlayingLocalFileWithName:atPath:withCompletionBlock:```. If you want to use the default path, just set it as ```nil```.

Example:

	[[AFSoundManager sharedManager] startPlayingLocalFileWithName:@"filename.mp3" atPath:nil withCompletionBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error) {

        if (!error)
        	//This block will be fired when the audio progress increases in 1%
        } else {
        	//Handle the error
        }
    }];

###Audio streaming
For remote audio, call ```-startStreamingRemoteAudioFromURL:andBlock:```

Example:

	[[AFSoundManager sharedManager] startStreamingRemoteAudioFromURL:@"http://www.example.com/audio/file.mp3" andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error) {

        if (!error)
        	//This block will be fired when the audio progress increases in 1%
        } else {
        	//Handle the error
        }
    }];

###Control
If you need to pause, resume or stop the current playing, guess what, there's a method for that!

	[[AFSoundManager sharedManager]pause];
	[[AFSoundManager sharedManager]resume];
	[[AFSoundManager sharedManager]stop];
	[[AFSoundManager sharedManager]restart];

For going back or forward, you have to specify the second where to continue playing the audio by calling ```-moveToSecond:```

For example, if you need to move the audio to the second 288, call

	[[AFSoundManager sharedManager]moveToSecond:288];

If you are using a UISlider, for example, and you need to work with values between 0.000000 and 1.000000, don't you worry, we got it:

	[[AFSoundManager sharedManager]moveToSection:0.345680]; //That will move the audio to the 34.568% of its total progress

You can also change the speed rate of the playing.

   [[AFSoundManager sharedManager]changeSpeedToRate:2.0];

The normal rate would be 1.0, while the half-speed playback would be 0.5 and the double speed playback 2.0

In order to change the volume, call ```-changeVolumeToValue:``` by passing a decimal number between 0.000000 (mute) and 1.000000 (maximum volume). Example:

	[[AFSoundManager sharedManager] changeVolumeToValue:0.750000]; //This will put the volume at 75%

###Playing status

In order to get noticed of the playing status changes, you need to implement the *AFSoundManagerDelegate* by adding it to your class, just like other delegates.

Then, just implement the ```currentPlayingStatusChanged:``` method in the class you want to get notified about the status changes in. 

	-(void)currentPlayingStatusChanged:(AFSoundManagerStatus)status {
	
    	switch (status) {
    	
        	case AFSoundManagerStatusFinished:
            	//Playing got finished
            	break;
        
        	case AFSoundManagerStatusPaused:
            	//Playing was paused
          	 	break;
            
        	case AFSoundManagerStatusPlaying:
            	//Playing got started or resumed
            	break;
        
        	case AFSoundManagerStatusRestarted:
            	//Playing got restarted
            	break;
            
        	case AFSoundManagerStatusStopped:
            	//Playing got stopped
            	break;
    	}
	}
	
Handle the change in each case.

###Background playing

If you want to enable background playing, make sure you have Background Modes enabled on your project, under the Capabilities section:

![alt text](https://raw.github.com/AlvaroFranco/AFSoundManager/master/background.png "")

Also, add this information to your info.plist file:

![alt text](https://raw.github.com/AlvaroFranco/AFSoundManager/master/plist-data.png "")

###Output manage
AFSoundManager also lets you choose which device do you want to use to play the audio. I mean, even if you have your headphones plugged in, you can force the audio to play on the built-in speakers or play it through the headphones.

If the headphones (or any external speaker) are plugged in and you want to play it on the built-in speakers, call:

	[[AFSoundManager sharedManager] forceOutputToBuiltInSpeakers];

If you want to play it through the default device (in this case the headphones or the external speaker) call

	[[AFSoundManager sharedManager] forceOutputToDefaultDevice];

And if you want to check if the headphones, or a external speaker, are currently plugged in on the device, check it with ```-areHeadphonesConnected```. Example:

	if ([[AFSoundManager sharedManager] areHeadphonesConnected]) {
		//Headphones connected
	} else {
		//Headphones NOT connected
	}

##Recording audio

Start recording audio from the device's microphone is easy peasy!

	[[AFSoundManager sharedManager] startRecordingAudioWithFileName:@"recording" andExtension:@"mp3" shouldStopAtSecond:25];

**If you don't want recording to stop automatically**, set shouldStopAtSecond as **0** or **nil**.

###Control the recording

AFSoundManager let's you perform several actions with your current recording:

	[[AFSoundManager sharedManager] pauseRecording]; // Pauses the current recording
    [[AFSoundManager sharedManager] resumeRecording]; // Resumes the current recording (if it's paused)
    [[AFSoundManager sharedManager] stopAndSaveRecording]; // Stops the current recording and closes the file
    [[AFSoundManager sharedManager] deleteRecording]; // Delete the current recording (perform this before stoping it)

Lastly, to get the current recording duration, call ```-timeRecorded``` which will return a NSTimeInterval object.

##License
AFSoundManager is under MIT license so feel free to use it!

##Author
Made by Alvaro Franco. If you have any question, feel free to drop me a line at [alvarofrancoayala@gmail.com](mailto:alvarofrancoayala@gmail.com)
