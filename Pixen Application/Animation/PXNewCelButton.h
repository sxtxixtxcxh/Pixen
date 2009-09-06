//
//  PXNewCelButton.h
//  Pixen
//
//  Created by Andy Matuschak on 10/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXNewCelButton : NSView {
	int state;
	NSBezierPath *buttonPath, *plusPath;
	id delegate;
}

@end

@interface NSObject (PXNewCelButtonDelegate)
- newCel:(PXNewCelButton *)button;
@end