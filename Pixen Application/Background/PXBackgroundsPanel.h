//
//  PXBackgroundsPanel.h
//  Pixen
//

#import <Cocoa/Cocoa.h>

//Had to override NSPanel because it wasn't posting the become/resign key window notifications or sending those delegate methods.

@interface PXBackgroundsPanel : NSPanel {

}

@end
