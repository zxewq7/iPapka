//
//  LNDataSourceTest.m
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 12.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  Link to Google Toolbox For Mac (IPhone Unit Test): 
//					http://code.google.com/p/google-toolbox-for-mac/wiki/iPhoneUnitTesting
//  Link to OCUnit:	http://www.sente.ch/s/?p=276&lang=en
//  Link to OCMock:	http://www.mulle-kybernetik.com/software/OCMock/



#import <UIKit/UIKit.h>
#import "GTMSenTestCase.h"
#import "LNDataSource.h"

@interface LNDataSourceTest : GTMTestCase {
    LNDataSource *dataSource;
    NSLock       *theLock;
}
@property (retain) NSLock *theLock;
@end

@implementation LNDataSourceTest
@synthesize theLock;

#if TARGET_IPHONE_SIMULATOR     // Only run when the target is simulator

- (void) setUp {
	 dataSource = [LNDataSource sharedLNDataSource];
}

// Start all test methods with testXXX
- (void) testRefresh {
    self.theLock = [NSLock new];
    [self.theLock lock];

    [dataSource refreshDocuments];
    
        // now lock the semaphore again - which will block this
        // thread unless/until unlock gets invoked
    [self.theLock lock];
    
        // make sure the async callback did in fact happen by
        // checking whether it modified a variable
     //    STAssertTrue (self.testState != 0, @"delegate did not get called");
    
        // we're done
    [self.theLock release];
}

- (void) testRaisesExceptionWhenWrongMethodIsCalled {
        //	STAssertThrows([mock uppercaseString], @"Should have raised an exception.");	
}

- (void) tearDown {
    // Release data structures here.
}

#endif

@end
