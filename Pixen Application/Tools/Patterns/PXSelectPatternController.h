//
//  PXSelectPatternController.h
//  Pixen
//
//  Created by Matt on 2/23/13.
//
//

@class PXPattern;
@protocol PXSelectPatternControllerDelegate;

@interface PXSelectPatternController : NSViewController

@property (nonatomic, strong) IBOutlet NSArrayController *patternsController;

@property (nonatomic, weak) NSPopover *popover;

@property (nonatomic, weak) id < PXSelectPatternControllerDelegate > delegate;

@end


@protocol PXSelectPatternControllerDelegate

- (void)selectPatternControllerDidChoosePattern:(PXPattern *)pattern;

@end
