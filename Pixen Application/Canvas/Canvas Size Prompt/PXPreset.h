//
//  PXPreset.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

@interface PXPreset : NSObject < NSCoding >

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSSize size;
@property (nonatomic, retain) NSColor *color;

@end
