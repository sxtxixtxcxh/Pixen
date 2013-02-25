//
//  PXPatternSizeController.h
//  Pixen
//
//  Created by Matt on 2/25/13.
//
//

#import <Cocoa/Cocoa.h>

@interface PXPatternSizeController : NSWindowController

@property (nonatomic, weak) IBOutlet NSTextField *widthField;
@property (nonatomic, weak) IBOutlet NSTextField *heightField;

- (void)runSheetModalForParentWindow:(NSWindow *)parentWindow;

- (IBAction)create:(id)sender;

- (int)width;
- (int)height;

@end
