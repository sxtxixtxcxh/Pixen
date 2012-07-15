//
//  PXBackgroundConfig.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@class PXBackground;

@interface PXBackgroundConfig : NSObject < NSCoding >

@property (nonatomic, strong) PXBackground *mainBackground;
@property (nonatomic, strong) PXBackground *alternateBackground;

@property (nonatomic, strong) PXBackground *mainPreviewBackground;
@property (nonatomic, strong) PXBackground *alternatePreviewBackground;

- (void)setDefaultBackgrounds;
- (void)setDefaultPreviewBackgrounds;

@end
