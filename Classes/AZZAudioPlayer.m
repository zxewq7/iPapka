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

-(void) setPath:(NSString *)aPath
{
    if (path == aPath || [path isEqualToString:aPath])
        return;

    [path release];
    path = [aPath retain];
    
    [player stop];
    [player release];
    
    NSError *err = nil;
    player = [[ AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&err];
    
    if(!player)
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    
    [player setDelegate:self];
}

-(BOOL) start
{
    [self stop];

    if (!player)
        return NO;
    
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

-(NSTimeInterval) duration
{
    return player.duration;
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
