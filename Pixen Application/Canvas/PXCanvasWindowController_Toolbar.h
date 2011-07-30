//
//  PXCanvasWindowController_Toolbar.h
//  Pixen
//

#import <Cocoa/Cocoa.h>

#import "PXCanvasWindowController.h"

@interface PXCanvasWindowController(Toolbar)
- (void)prepareToolbar;
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar *) toolbar;
- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *) toolbar;

@end