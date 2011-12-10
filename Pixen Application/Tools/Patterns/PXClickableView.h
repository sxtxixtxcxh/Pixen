//
//  PXClickableView.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

@interface PXClickableView : NSView
{
    BOOL _selected;
    id _delegate;
}

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) IBOutlet id delegate;

@end


@interface NSObject (PXClickableViewDelegate)

- (void)viewDidReceiveDoubleClick:(NSView *)view;

@end
