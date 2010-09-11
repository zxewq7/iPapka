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
    UIImage      *icon;
    NSString     *iconName;
}
+(id)folderWithName:(NSString *) aName predicateString:(NSString *) aPredicateString entityName:(NSString *) anEntityName iconName:(NSString *) anIconName;
@property (nonatomic, retain, setter=setName:)              NSString     *name;
@property (nonatomic, readonly, getter=localizedName)       NSString     *localizedName;
@property (nonatomic, retain, setter=setPredicateString:)   NSString     *predicateString;
@property (nonatomic, readonly, getter=predicate)           NSPredicate  *predicate;
@property (nonatomic, retain, setter=setEntityName:)        NSString     *entityName;
@property (nonatomic, readonly, getter=entityClass)         Class        entityClass;
@property (nonatomic, readonly, getter=icon)                UIImage      *icon;
@property (nonatomic, retain, setter=setIconName:)          NSString     *iconName;
@end
