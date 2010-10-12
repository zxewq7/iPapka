// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentResolution.h instead.

#import <CoreData/CoreData.h>
#import "Document.h"

@class DocumentResolution;
@class Person;
@class ResolutionAudio;





@interface DocumentResolutionID : NSManagedObjectID {}
@end

@interface _DocumentResolution : Document {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentResolutionID*)objectID;



@property (nonatomic, retain) NSString *text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *deadline;

//- (BOOL)validateDeadline:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isManaged;

@property BOOL isManagedValue;
- (BOOL)isManagedValue;
- (void)setIsManagedValue:(BOOL)value_;

//- (BOOL)validateIsManaged:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) DocumentResolution* parentResolution;
//- (BOOL)validateParentResolution:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* performers;
- (NSMutableSet*)performersSet;



@property (nonatomic, retain) ResolutionAudio* audioComment;
//- (BOOL)validateAudioComment:(id*)value_ error:(NSError**)error_;



@end

@interface _DocumentResolution (CoreDataGeneratedAccessors)

- (void)addPerformers:(NSSet*)value_;
- (void)removePerformers:(NSSet*)value_;
- (void)addPerformersObject:(Person*)value_;
- (void)removePerformersObject:(Person*)value_;

@end

@interface _DocumentResolution (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;


- (NSDate*)primitiveDeadline;
- (void)setPrimitiveDeadline:(NSDate*)value;


- (NSNumber*)primitiveIsManaged;
- (void)setPrimitiveIsManaged:(NSNumber*)value;

- (BOOL)primitiveIsManagedValue;
- (void)setPrimitiveIsManagedValue:(BOOL)value_;




- (DocumentResolution*)primitiveParentResolution;
- (void)setPrimitiveParentResolution:(DocumentResolution*)value;



- (NSMutableSet*)primitivePerformers;
- (void)setPrimitivePerformers:(NSMutableSet*)value;



- (ResolutionAudio*)primitiveAudioComment;
- (void)setPrimitiveAudioComment:(ResolutionAudio*)value;


@end
