//
//  PXDefaultBackgroundTemplateView.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXBackgroundTemplateView.h"

@interface PXDefaultBackgroundTemplateView : PXBackgroundTemplateView
{
    NSString *_backgroundTypeText;
    BOOL _activeDragTarget;
}

@property (nonatomic, retain) NSString *backgroundTypeText;
@property (nonatomic, assign) BOOL activeDragTarget;

@end
