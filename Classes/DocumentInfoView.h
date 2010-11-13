//
//  DocumentInfoDetailsView.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 26.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZSegmentedLabel;
@interface DocumentInfoView : UIView 
{
    UILabel *textLabel;
    AZZSegmentedLabel *detailTextLabel1;
    UILabel *detailTextLabel2;
    UITableView *tableView;
    UISegmentedControl *filterView;
}

@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, readonly) AZZSegmentedLabel *detailTextLabel1;
@property (nonatomic, readonly) UILabel *detailTextLabel2;

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) UISegmentedControl *filterView;
@end
