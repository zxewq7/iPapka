#import "ResolutionManaged.h"

@implementation ResolutionManaged

-(NSString *) audioCommentPath
{
    return [self.path stringByAppendingPathComponent:@"audioComment.ima4"];
}

-(BOOL) hasAudioComment
{
    NSFileManager *df = [NSFileManager defaultManager];
    return [df fileExistsAtPath: self.audioCommentPath];
}
@end
