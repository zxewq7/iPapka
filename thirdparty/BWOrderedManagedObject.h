//
//  BWOrderedManagedObject.h
//  OrderedCoreDataDemo
//
//  Created by Brian Webster on 8/5/08.
//  Copyright 2008 Fat Cat Software. Some rights reserved <http://opensource.org/licenses/mit-license.php>
//

#import <CoreData/CoreData.h>

/*!
    @class       BWOrderedManagedObject
	
    @abstract    
	
	A subclass of NSManagedObject that provide support for imposing an ordering on to-many 
	relationships
    
	@discussion  
		
	By default, to-many Core Data relationships are unordered, but there are
	some cases where you want to impose a specific ordering on a relationship.  The
	classic example of this is iTunes, where each playlist can have a list of tracks,
	but those tracks can be put in a specific order by the user.
	
	BWOrderedManagedObject manages this by using an additional property to store the
	ordering for each relationship that you want to be ordered.  By default, the string
	"Ordering" is appended to the name of the relationship key to form the key that the
	ordering data is stored in (e.g. the ordering for the "tracks" relationship is stored
	under the key "tracksOrdering")
	
	BWOrderedManagedObject also provides a set of methods that allow for inserting, deleting,
	and rearranging objects in a specific order.
*/

@interface BWOrderedManagedObject : NSManagedObject 
{

}

/*!
    @method     orderedKeys
	
    @abstract   Returns the list of to-many relationships that have an ordering
	
    @discussion 
	
	By default, this method will compile a list of keys based on the entity definition of
	the object.  Any to-many relationship which has the corresponding ordering key also
	defined will be returned.  This method can be overridden if you want to use some other
	method of determining which of your relationships should be ordered.
	
*/
- (NSArray*)orderedKeys;

/*!
    @method     
    @abstract   Returns the key used to store the ordering for a given relationship
    @discussion 
	
	By default, this method simply appends "Ordering" to the given key to form the ordering 
	key.  You can override this method if you wish to use a different technique to map from
	relationship to ordering.
*/
- (NSString*)orderingKeyForRelationshipKey:(NSString*)key;

/*!
    @method     orderingForKey
    @abstract   Returns the ordering for a given relationship
    @discussion 
	
	The ordering for a relationship is stored as an array of NSURLs.  Each URL corresponds
	to the URIRepresentation of an object in the relationship, and the order of the URLs in
	the array determines the order of the objects.
*/

- (NSArray*)orderingForKey:(NSString*)key;

/*!
    @method     setOrdering:forKey:
    @abstract   Sets a new ordering for a given relationship
    @discussion 
	
	Sets a new ordering for a relationship.  You typically don't need to call this method
	directly, as the various insert/delete methods will usually suffice.  The newOrdering
	array should contain NSURL objects containing the URIRepresentation of the objects in
	the relationship, in the order you want them to be.
*/

- (void)setOrdering:(NSArray*)newOrdering forKey:(NSString*)key;

/*!
    @method     orderedValueForKey:
    @abstract   Returns the objects in a relationship in order
    @discussion This method returns an array of the NSManagedObjects in the given relationship,
		in the order specified by the relationship's ordering key.
    @param      key The key for the relationship whose objects you want to obtain
    @result     The ordered array of objects for the relationship
*/
- (NSArray*)orderedValueForKey:(NSString*)key;

/*!
    @method     mutableOrderedValueForKey:
    @abstract   Returns a mutable proxy array that can be used to manipulate a relationship
    @discussion The mutable array returned by this method will pass through any operations to
		the underlying relationship, in a similar manner to mutableArrayValueForKey:
    @param      key The key for the relationship whose objects you want to manipulate
    @result     A mutable proxy array
*/
- (NSMutableArray*)mutableOrderedValueForKey:(NSString*)key;

//These methods are the underlying methods called by the proxy returned by 
//mutableOrderedValueForKey, above.  You can call them directly, or just call normal NSArray
//methods through the array proxy.
- (unsigned)countOfOrderedValueForKey:(NSString*)key;
- (NSManagedObject*)objectInOrderedValueForKey:(NSString*)key atIndex:(NSUInteger)index;
- (void)insertObject:(NSManagedObject*)object inOrderedValueForKey:(NSString*)key atIndex:(NSUInteger)index;
- (void)removeObjectFromOrderedValueForKey:(NSString*)key atIndex:(NSUInteger)index;
- (void)replaceObjectInOrderedValueForKey:(NSString*)key atIndex:(NSUInteger)index withObject:(NSManagedObject*)newObject;

/*!
    @method     moveObjectsInOrderedValueForKey:fromIndexes:toIndex:
    @abstract   Moves a set of objects to a different position in the array
    @discussion This is a convenience method for the typical case where a user is rearranging
		objects in a relationship by drag and drop in a table view or other ordered view.
    @param      key The relationship whose objects you want to move
    @param      indexes The indexes of the objects that are being moved (i.e. the dragged
		selection in the table view)
    @param      newIndex The index to which the objects will be moved (i.e. the drop position
		in the table view)
*/
- (void)moveObjectsInOrderedValueForKey:(NSString*)key fromIndexes:(NSIndexSet*)indexes toIndex:(unsigned)newIndex;

@end
