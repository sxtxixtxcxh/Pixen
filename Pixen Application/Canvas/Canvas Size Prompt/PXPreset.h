//
//  PXPreset.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

@interface PXPreset : NSObject < NSCoding >
{
  @private
	NSString *_name;
	NSSize _size;
	NSColor *_color;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSSize size;
@property (nonatomic, retain) NSColor *color;

@end
