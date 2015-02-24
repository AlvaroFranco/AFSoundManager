//
//  AFSoundQueue.h
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 21/01/15.
//  Copyright (c) 2015 AlvaroFranco. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFSoundPlayback.h"
#import "AFSoundItem.h"

@interface AFSoundQueue : NSObject

typedef void (^feedbackBlock)(AFSoundItem *item);
typedef void (^itemFinishedBlock)(AFSoundItem *nextItem);

-(id)initWithItems:(NSArray *)items;

@property (nonatomic) AFSoundStatus status;

-(void)addItem:(AFSoundItem *)item;
-(void)addItem:(AFSoundItem *)item atIndex:(NSInteger)index;
-(void)removeItem:(AFSoundItem *)item;
-(void)removeItemAtIndex:(NSInteger)index;
-(void)clearQueue;

-(void)playCurrentItem;
-(void)pause;
-(void)playNextItem;
-(void)playPreviousItem;
-(void)playItem:(AFSoundItem *)item;
-(void)playItemAtIndex:(NSInteger)index;

-(AFSoundItem *)getCurrentItem;
-(NSInteger)indexOfCurrentItem;

-(void)listenFeedbackUpdatesWithBlock:(feedbackBlock)block andFinishedBlock:(itemFinishedBlock)finishedBlock;

@end
