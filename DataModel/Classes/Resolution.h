//
//  Resolution.h
//  DataModel
//
//  Created by Vladimir Solomenchuk on 13.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Document.h"

@interface Resolution : Document<NSCoding> {
    NSString   *text;
    NSArray    *performers;
    BOOL       managed;
    Resolution *parentResolution;
    NSDate     *deadline;
    BOOL       hasAudioComment;
}
@property (nonatomic, retain) NSString   *text;
@property (nonatomic, retain) NSArray    *performers;
@property (nonatomic, retain) NSDate     *deadline;
@property (nonatomic)         BOOL       managed;
@property (nonatomic, retain) Resolution *parentResolution;
@property (nonatomic, retain, readonly) NSString *audioComment;
@property (nonatomic)         BOOL       hasAudioComment;
@end
