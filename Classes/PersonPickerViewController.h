//
//  PersonPickerViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 18.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Person;
@interface PersonPickerViewController : UITableViewController 
{
    NSArray *persons;
    Person *person;
    SEL selector;
    id target;
}

@property (nonatomic, retain) Person *person;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, retain) id target;
@end
