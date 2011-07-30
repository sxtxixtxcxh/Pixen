//
//  PXPatternCell.h
//  Pixen
//

#import <AppKit/AppKit.h>

@class PXPattern;

@interface PXPatternCell : NSButtonCell {
  @private
	PXPattern *pattern;
	id delegate;
	
	NSPoint dragOrigin;
	NSRect lastFrame;
	NSEvent *dragEvent;
}

@property (nonatomic, assign) id delegate;

- (NSSize)properSize;
- (PXPattern *)pattern;
- (NSRect)autoFrame;
- (void)setPattern:(PXPattern *)pat;

@end