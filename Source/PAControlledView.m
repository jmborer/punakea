//
//  PAControlledView.m
//  punakea
//
//  Created by Johannes Hoffart on 17.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAControlledView.h"

@implementation PAControlledView

- (void)didAddSubview:(NSView *)subview
{
	[delegate controlledViewHasChanged];
}

@end
