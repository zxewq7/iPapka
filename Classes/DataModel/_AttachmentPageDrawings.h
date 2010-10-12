// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AttachmentPageDrawings.h instead.

#import <CoreData/CoreData.h>
#import "FileField.h"

@class AttachmentPage;


@interface AttachmentPageDrawingsID : NSManagedObjectID {}
@end

@interface _AttachmentPageDrawings : FileField {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AttachmentPageDrawingsID*)objectID;




@property (nonatomic, retain) AttachmentPage* parent;
//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;



@end

@interface _AttachmentPageDrawings (CoreDataGeneratedAccessors)

@end

@interface _AttachmentPageDrawings (CoreDataGeneratedPrimitiveAccessors)



- (AttachmentPage*)primitiveParent;
- (void)setPrimitiveParent:(AttachmentPage*)value;


@end
