//
//  AZZAudioPlayer.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 21.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "AZZAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>


@implementation AZZAudioPlayer
@synthesize path;

-(BOOL) start
{
    [self stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    if(err)
    {
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return NO;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err)
    {
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return NO;
    }
    
    player = [[ AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&err];

    if(!player)
    {
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return NO;
    }
    
    [player setDelegate:self];

    // start playing
    [self willChangeValueForKey:@"playing"];
    
    BOOL res = [player play];
    
    [self didChangeValueForKey:@"playing"];    
    
    return res;
}

-(void) pause
{
    [player pause];
}

-(void) stop
{
    [self willChangeValueForKey:@"playing"];
    [player stop];
    [self didChangeValueForKey:@"playing"];

    [player release];
    
    player = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    if(err)
    {
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    err =  nil;
    [audioSession setActive:NO error:&err];
    
    if(err)
    {
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
}

-(BOOL) playing
{
    return player.playing;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self willChangeValueForKey:@"playing"];
    [self didChangeValueForKey:@"playing"];
}

-(void) dealloc
{
    [player release];
    player = nil;
    
    self.path = nil;
    [super dealloc];
}
@end
