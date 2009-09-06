//
//  PXModalColorWell.m
//  Pixen
//
//  Created by Andy Matuschak on 8/23/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "PXModalColorWell.h"
#import "PXModalColorPanel.h"

@implementation PXModalColorWell

- (void)activate:sender
{
	[self willChangeValueForKey:@"color"];
	[[PXModalColorPanel sharedColorPanel] setColor:[self color]];
	[self setColor:[[PXModalColorPanel sharedColorPanel] run]];
	[self didChangeValueForKey:@"color"];
}

@end
