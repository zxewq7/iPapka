// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ResolutionAudio.h instead.

#import <CoreData/CoreData.h>
#import "FileField.h"

@class DocumentResolution;


@interface ResolutionAudioID : NSManagedObjectID {}
@end

@interface _ResolutionAudio : FileField {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ResolutionAudioID*)objectID;




@property (nonatomic, retain) DocumentResolution* parent;
//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;



@end

@interface _ResolutionAudio (CoreDataGeneratedAccessors)

@end

@interface _ResolutionAudio (CoreDataGeneratedPrimitiveAccessors)



- (DocumentResolution*)primitiveParent;
- (void)setPrimitiveParent:(DocumentResolution*)value;


@end
