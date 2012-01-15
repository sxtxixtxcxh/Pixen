//
//  PXCanvas_Backgrounds.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvas.h"

@class PXBackground;

@interface PXCanvas (Backgrounds)

@property (nonatomic, retain) PXBackground *mainBackground;
@property (nonatomic, retain) PXBackground *alternateBackground;
@property (nonatomic, retain) PXBackground *mainPreviewBackground;
@property (nonatomic, retain) PXBackground *alternatePreviewBackground;

@end
