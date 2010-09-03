//
//  DatePickerController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 03.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerController : UIViewController {
    UIDatePicker *datePickerView;
    NSDate *date;
    NSDate *maximumDate;
}
@property (nonatomic, retain) NSDate* date;
@property (nonatomic, retain) NSDate* maximumDate;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, retain) id target;
@end
