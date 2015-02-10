//
//  AFSoundRecord.h
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 10/02/15.
//  Copyright (c) 2015 AlvaroFranco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFSoundRecord : NSObject

-(id)initWithFilePath:(NSString *)filePath;

-(void)startRecording;
-(void)saveRecording;
-(void)cancelCurrentRecording;

@end
