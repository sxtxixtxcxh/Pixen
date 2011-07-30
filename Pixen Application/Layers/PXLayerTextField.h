//
//  PXLayerTextField.h
//  Pixen
//
//  Created by Andy Matuschak on 6/28/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXLayerTextField : NSTextField {
  @private
	BOOL isEditing;
	BOOL isFirstEnd;
	BOOL reachedByClicking;
}
- (void)useEditAppearance;

@property (nonatomic, readonly, getter=isEditing) BOOL editing;

@end
