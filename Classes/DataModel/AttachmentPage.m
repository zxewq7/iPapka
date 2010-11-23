#import "AttachmentPage.h"
#import "Attachment.h"
#import "AttachmentPagePainting.h"
#import "DocumentWithResources.h"
#import "DocumentRoot.h"

@implementation AttachmentPage

-(BOOL) isImageExists
{
    NSFileManager *df = [NSFileManager defaultManager];
    return [df fileExistsAtPath: self.pathImage];
}

-(NSString *)path
{
    return [[self.attachment.path stringByAppendingPathComponent:@"pages"] stringByAppendingPathComponent: [NSString stringWithFormat:@"%d", [self.number intValue]]];
}

-(NSString *)pathImage
{
    return [self.path stringByAppendingPathComponent: @"image.png"];
}

-(UIImage *) image
{
    if (!self.isImageExists)
        return nil;

    return [UIImage imageWithContentsOfFile:self.pathImage];
}

-(BOOL) hasPaintings
{
    AttachmentPagePainting *painting = [self painting];
    return [painting hasPainting];
}

-(BOOL) hasAudio
{
    return NO;
}

-(BOOL) hasText
{
    return NO;
}

-(BOOL) isEditable
{
    return self.attachment.document.isEditable && 
        self.syncStatusValue != SyncStatusNeedSyncFromServer &&
        self.isImageExists;
}
@end
