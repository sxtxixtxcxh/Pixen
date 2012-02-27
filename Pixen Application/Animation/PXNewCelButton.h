//
//  PXNewCelButton.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXNewCelButton : NSView
{
  @private
	NSCellStateValue _state;
	NSBezierPath *_buttonPath, *_plusPath;
	id _delegate;
}

@property (nonatomic, assign) IBOutlet id delegate;

@end


@interface NSObject (PXNewCelButtonDelegate)

- (void)newCelButtonClicked:(PXNewCelButton *)button;

@end
