// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AttachmentPagePainting.h instead.

#import <CoreData/CoreData.h>
#import "FileField.h"

@class AttachmentPage;


@interface AttachmentPagePaintingID : NSManagedObjectID {}
@end

@interface _AttachmentPagePainting : FileField {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AttachmentPagePaintingID*)objectID;




@property (nonatomic, retain) AttachmentPage* page;
//- (BOOL)validatePage:(id*)value_ error:(NSError**)error_;



@end

@interface _AttachmentPagePainting (CoreDataGeneratedAccessors)

@end

@interface _AttachmentPagePainting (CoreDataGeneratedPrimitiveAccessors)



- (AttachmentPage*)primitivePage;
- (void)setPrimitivePage:(AttachmentPage*)value;


@end
