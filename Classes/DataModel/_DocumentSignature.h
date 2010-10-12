// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentSignature.h instead.

#import <CoreData/CoreData.h>
#import "Document.h"

@class SignatureAudio;



@interface DocumentSignatureID : NSManagedObjectID {}
@end

@interface _DocumentSignature : Document {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentSignatureID*)objectID;



@property (nonatomic, retain) NSString *comment;

//- (BOOL)validateComment:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) SignatureAudio* audioComment;
//- (BOOL)validateAudioComment:(id*)value_ error:(NSError**)error_;



@end

@interface _DocumentSignature (CoreDataGeneratedAccessors)

@end

@interface _DocumentSignature (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveComment;
- (void)setPrimitiveComment:(NSString*)value;




- (SignatureAudio*)primitiveAudioComment;
- (void)setPrimitiveAudioComment:(SignatureAudio*)value;


@end
