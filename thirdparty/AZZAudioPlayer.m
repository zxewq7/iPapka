//
//  AZZAudioPlayer.m
//  iPapka
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
    if (path != aPath)
    {
        [path release];
        path = [aPath retain];
    }
    
    [self stop];

    [player release]; player = nil;
    
    NSFileManager *df = [NSFileManager defaultManager];

    if (!path || ![df fileExistsAtPath: self.path])
        return;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *err = nil;
    
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    
    if(err)
    {
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    err = nil;
    
    [audioSession setActive:YES error:&err];
    
    if(err)
    {
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    player = [[ AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&err];
    
    if(!player)
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    
    [player setDelegate:self];
}

-(BOOL) start
{
    [self stop];
    
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
    if (!player.playing)
        return;
        
    [self willChangeValueForKey:@"playing"];
    [player stop];
    [self didChangeValueForKey:@"playing"];
    player.currentTime = 0;
}

-(BOOL) playing
{
    return player.playing;
}

-(NSTimeInterval) duration
{
    return player.duration;
}

-(NSTimeInterval) currentTime
{
    return player.currentTime;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self willChangeValueForKey:@"playing"];
    [self didChangeValueForKey:@"playing"];
}

-(void) dealloc
{
    [player release]; player = nil;
    
    self.path = nil;
    [super dealloc];
}
@end
