#import "DocumentResolution.h"

@implementation DocumentResolution

-(NSString *) audioCommentPath
{
    return [self.path stringByAppendingPathComponent:@"audioComment.ima4"];
}
@end
