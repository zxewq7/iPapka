//
//  AZZAudioRecorder.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 21.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioRecorder.h>

@class AVAudioRecorder;

@interface AZZAudioRecorder : NSObject<AVAudioRecorderDelegate>
{
    AVAudioRecorder *recorder;
    NSString *path;
}

@property (nonatomic, retain) NSString *path;
@property (readonly) BOOL recording;
@property (readonly) NSTimeInterval currentTime;

-(BOOL) start;
-(void) pause;
-(void) stop;
@end
