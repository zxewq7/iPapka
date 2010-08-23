//
//  Folder.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 19.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Folder : NSObject<NSCoding> {
    NSString     *name;
    NSString     *localizedName;
    NSString     *predicateString;
    NSPredicate  *predicate;
    NSString     *entityName;
    Class        entityClass;
}
+(id)folderWith:(NSString *) aName predicateString:(NSString *) aPredicateString andEntityName:(NSString *) anEntityName;
@property (nonatomic, retain, setter=setName:)              NSString     *name;
@property (nonatomic, readonly, getter=localizedName)       NSString     *localizedName;
@property (nonatomic, retain, setter=setPredicateString:)   NSString     *predicateString;
@property (nonatomic, readonly, getter=predicate)           NSPredicate  *predicate;
@property (nonatomic, retain, setter=setEntityName:)        NSString     *entityName;
@property (nonatomic, readonly, getter=entityClass)         Class        entityClass;
@end
