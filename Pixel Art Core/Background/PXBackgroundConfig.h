//
//  PXBackgroundConfig.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@class PXBackground;

@interface PXBackgroundConfig : NSObject < NSCoding >

@property (nonatomic, retain) PXBackground *mainBackground;
@property (nonatomic, retain) PXBackground *alternateBackground;

@property (nonatomic, retain) PXBackground *mainPreviewBackground;
@property (nonatomic, retain) PXBackground *alternatePreviewBackground;

- (void)setDefaultBackgrounds;
- (void)setDefaultPreviewBackgrounds;

@end
