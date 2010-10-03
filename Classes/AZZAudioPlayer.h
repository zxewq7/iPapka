//
//  AZZAudioPlayer.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 21.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface AZZAudioPlayer : NSObject<AVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
}

@property (nonatomic, retain) NSString *path;
@property (readonly) BOOL playing;
@property(readonly) NSTimeInterval duration;

-(BOOL) start;
-(void) pause;
-(void) stop;

@end
