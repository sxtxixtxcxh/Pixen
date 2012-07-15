//
//  OSQTExporter.h
//  OSQTExporter
//
//  Created by Andy Matuschak on 8/7/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QTMovie;

@interface OSQTExporter : NSObject
{
  @private
	QTMovie *qtMovie;
}

- (void)addImage:(NSImage *)image forLength:(NSTimeInterval)seconds;
- (void)exportToPath:(NSString *)path parentWindow:(NSWindow *)newParentWindow;

@end
