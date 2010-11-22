#import "CommentAudio.h"
#import "DocumentWithResources.h"

@implementation CommentAudio
-(BOOL) isEditable
{
    return self.document.isEditableValue;
}
@end
