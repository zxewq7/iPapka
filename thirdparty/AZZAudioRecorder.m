//
//  AZZAudioRecorder.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 21.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "AZZAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

#define kMaxTimetoRecord 300

@implementation AZZAudioRecorder
@synthesize path;

-(BOOL) start
{
    [self stop];
    if (!self.path)
        return NO;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryRecord error:&err];
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
    
    NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,
                         [NSNumber numberWithInt:16000.0],AVSampleRateKey,
                         [NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
                         nil];
    NSURL *url = [NSURL fileURLWithPath: self.path];
    err = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&err];
    [recordSettings release];
    if(!recorder)
    {
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return NO;
    }
    
    //prepare to record
    recorder.delegate = self;
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable)
        return NO;
    
    
    // start recording
    [self willChangeValueForKey:@"recording"];
    BOOL res = [recorder recordForDuration:(NSTimeInterval) kMaxTimetoRecord];
    [self didChangeValueForKey:@"recording"];

    return res;
}

-(void) pause
{
    [recorder pause];
}

-(void) stop
{
    [self willChangeValueForKey:@"recording"];
    [recorder stop];
    [self didChangeValueForKey:@"recording"];

    [recorder release];
    
    recorder = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryRecord error:&err];
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

-(BOOL) recording
{
    return recorder.recording;
}

-(NSTimeInterval) currentTime
{
    return recorder.currentTime;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    [self willChangeValueForKey:@"recording"];
    [self didChangeValueForKey:@"recording"];
}

-(void) dealloc
{
    [recorder release]; recorder = nil;
    
    self.path = nil;
    [super dealloc];
}
@end
