//
//  PXPreset.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

@interface PXPreset : NSObject < NSCoding >

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSSize size;
@property (nonatomic, strong) NSColor *color;

@end
