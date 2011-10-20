//
//  PXCanvas_ApplescriptAdditions.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXCanvas.h"

@interface PXCanvas (ApplescriptAdditions)

- (id)handleGetColorScriptCommand:(id)command;
- (id)handleSetColorScriptCommand:(id)command;

- (int)height;
- (void)setHeight:(int)height;

- (int)width;
- (void)setWidth:(int)width;

@end
