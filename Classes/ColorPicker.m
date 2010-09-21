//
//  ColorPicker.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 18.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ColorPicker.h"

//FUNCTIONS:
/*
 HSL2RGB Converts hue, saturation, luminance values to the equivalent red, green and blue values.
 For details on this conversion, see Fundamentals of Interactive Computer Graphics by Foley and van Dam (1982, Addison and Wesley)
 You can also find HSL to RGB conversion algorithms by searching the Internet.
 See also http://en.wikipedia.org/wiki/HSV_color_space for a theoretical explanation
 */
static void HSL2RGB(float h, float s, float l, float* outR, float* outG, float* outB)
{
	float			temp1,
    temp2;
	float			temp[3];
	int				i;
	
    // Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
	if(s == 0.0) {
		if(outR)
			*outR = l;
		if(outG)
			*outG = l;
		if(outB)
			*outB = l;
		return;
	}
	
    // Test for luminance and compute temporary values based on luminance and saturation 
	if(l < 0.5)
		temp2 = l * (1.0 + s);
	else
		temp2 = l + s - l * s;
    temp1 = 2.0 * l - temp2;
	
    // Compute intermediate values based on hue
	temp[0] = h + 1.0 / 3.0;
	temp[1] = h;
	temp[2] = h - 1.0 / 3.0;
    
	for(i = 0; i < 3; ++i) {
		
        // Adjust the range
		if(temp[i] < 0.0)
			temp[i] += 1.0;
		if(temp[i] > 1.0)
			temp[i] -= 1.0;
		
		
		if(6.0 * temp[i] < 1.0)
			temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
		else {
			if(2.0 * temp[i] < 1.0)
				temp[i] = temp2;
			else {
				if(3.0 * temp[i] < 2.0)
					temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
				else
					temp[i] = temp1;
			}
		}
	}
	
    // Assign temporary values to R, G, B
	if(outR)
		*outR = temp[0];
	if(outG)
		*outG = temp[1];
	if(outB)
		*outB = temp[2];
}
#define kPaletteSize			5

#define kLuminosity			0.75
#define kSaturation			1.0

#define kColorViewLeftMargin  36.0f
#define kColorViewRightMargin  36.0f
#define kColorViewTopMargin  5.0f
#define kColorViewBottomMargin  5.0f

#define kColorViewTag  1001

#define kTableWidth  240

@interface ColorPicker (Private)
+ (UIColor *) colorForIndex:(NSUInteger) index;
@end

@implementation ColorPicker
@synthesize color;


+(UIColor *) defaultColor
{
    return [ColorPicker colorForIndex:0];
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(kTableWidth, self.tableView.rowHeight * kPaletteSize);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ColorCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        CGRect frame = CGRectMake(kColorViewLeftMargin, kColorViewTopMargin, kTableWidth - kColorViewLeftMargin - kColorViewRightMargin, tableView.rowHeight - kColorViewTopMargin - kColorViewBottomMargin);
        UIView *colorView = [[UIView alloc] initWithFrame: frame];
        colorView.tag = kColorViewTag;

        [cell addSubview: colorView];

        [colorView release];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UIView *colorView = [cell viewWithTag: kColorViewTag];
    switch (indexPath.row)
    {
        case 0:
            colorView.backgroundColor = [UIColor redColor];
            break;
        case 1:
            colorView.backgroundColor = [UIColor yellowColor];
            break;
        case 2:
            colorView.backgroundColor = [UIColor greenColor];
            break;
        case 3:
            colorView.backgroundColor = [UIColor blueColor];
            break;
        case 4:
            colorView.backgroundColor = [UIColor purpleColor];
            break;
    }
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    self.color = [ColorPicker colorForIndex: indexPath.row];
}

#pragma mark -
#pragma mark Memory management
- (void)viewDidUnload 
{
    [super viewDidUnload];
    
    self.color = nil;
}


- (void)dealloc 
{
    self.color = nil;

    [super dealloc];
}

#pragma Private

+ (UIColor *) colorForIndex:(NSUInteger) index
{
    CGFloat components[3];
    HSL2RGB((CGFloat)index / (CGFloat)kPaletteSize, kSaturation, kLuminosity, &components[0], &components[1], &components[2]);
    return [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:0];
}
@end

