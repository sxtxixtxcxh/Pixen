//
//  PXNewCelButton.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@interface PXNewCelButton : NSView

@property (nonatomic, assign) IBOutlet id delegate;

@end


@interface NSObject (PXNewCelButtonDelegate)

- (void)newCelButtonClicked:(PXNewCelButton *)button;

@end
