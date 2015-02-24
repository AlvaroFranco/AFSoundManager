//
//  ViewController.m
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 20/01/15.
//  Copyright (c) 2015 AlvaroFranco. All rights reserved.
//

#import "ViewController.h"
#import "AFSoundManager.h"

@interface ViewController ()

@property (nonatomic, strong) AFSoundPlayback *playback;
@property (nonatomic, strong) AFSoundQueue *queue;

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    AFSoundItem *item1 = [[AFSoundItem alloc] initWithLocalResource:@"demo1.mp3" atPath:nil];
    AFSoundItem *item2 = [[AFSoundItem alloc] initWithLocalResource:@"demo2.mp3" atPath:nil];
    AFSoundItem *item3 = [[AFSoundItem alloc] initWithLocalResource:@"demo3.mp3" atPath:nil];
    AFSoundItem *item4 = [[AFSoundItem alloc] initWithLocalResource:@"demo4.mp3" atPath:nil];
    AFSoundItem *item5 = [[AFSoundItem alloc] initWithLocalResource:@"demo5.mp3" atPath:nil];
    AFSoundItem *item6 = [[AFSoundItem alloc] initWithLocalResource:@"demo6.mp3" atPath:nil];
    
    _items = [NSMutableArray arrayWithObjects:item1, item2, item3, item4, item5, item6, nil];
    
    _queue = [[AFSoundQueue alloc] initWithItems:_items];
    [_queue playCurrentItem];
    
    [_queue listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
        
        NSLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);
    } andFinishedBlock:^(AFSoundItem *nextItem) {
        
        NSLog(@"Finished item, next one is %@", nextItem.title);
    }];
}

-(IBAction)playNext:(id)sender {
    
    [_queue playNextItem];
}

-(IBAction)playPrevious:(id)sender {
    
    [_queue playPreviousItem];
}

-(IBAction)playItem:(id)sender {
    
    [_queue playCurrentItem];
}

-(IBAction)pauseItem:(id)sender {
    
    [_queue pause];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    AFSoundItem *item = _items[indexPath.row];
    
    cell.textLabel.text = item.title;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_queue playItem:(AFSoundItem *)_items[indexPath.row]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
