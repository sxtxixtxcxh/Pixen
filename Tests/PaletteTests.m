//
//  PaletteTests.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PaletteTests.h"

#import "PXColorArray.h"

@implementation PaletteTests

- (void)testColorArray
{
	PXColorArrayRef array = PXColorArrayCreate();
	
	STAssertTrue(array != NULL, @"The color array should be non-NULL");
	STAssertTrue(PXColorArrayCount(array) == 0, @"The color array should be empty");
	
	PXColor firstColor = PXGetBlackColor();
	PXColor secondColor = PXColorMake(20, 100, 80, 20);
	PXColor thirdColor = PXColorMake(50, 20, 140, 180);
	PXColor fourthColor = PXGetClearColor();
	
	PXColorArrayAppendColor(array, firstColor);
	
	STAssertTrue(PXColorArrayCount(array) == 1, @"The count of the color array should be 1");
	STAssertTrue(PXColorEqualsColor(PXColorArrayColorAtIndex(array, 0), firstColor),
				 @"A wrong color value was appended");
	
	PXColorArrayAppendColor(array, secondColor);
	
	STAssertTrue(PXColorArrayCount(array) == 2, @"The count of the color array should be 2");
	STAssertTrue(PXColorEqualsColor(PXColorArrayColorAtIndex(array, 1), secondColor),
				 @"A wrong color value was appended");
	
	for (NSUInteger n = 0; n < 100; n++) {
		PXColorArrayAppendColor(array, thirdColor);
	}
	
	STAssertTrue(PXColorArrayCount(array) == 102, @"The count of the color array should be 102");
	
	for (NSUInteger n = 2; n < 102; n++) {
		STAssertTrue(PXColorEqualsColor(PXColorArrayColorAtIndex(array, n), thirdColor),
					 @"Wrong color values were appended");
	}
	
	STAssertTrue(PXColorArrayIndexOfColor(array, firstColor) == 0,
				 @"The reported color index is wrong");
	
	STAssertTrue(PXColorArrayIndexOfColor(array, secondColor) == 1,
				 @"The reported color index is wrong");
	
	STAssertTrue(PXColorArrayIndexOfColor(array, thirdColor) == 2,
				 @"The reported color index is wrong");
	
	PXColorArrayRemoveColorAtIndex(array, 1);
	
	STAssertTrue(PXColorArrayCount(array) == 101, @"The count of the color array should be 101");
	STAssertTrue(PXColorEqualsColor(PXColorArrayColorAtIndex(array, 1), thirdColor),
				 @"The indicated color was not removed");
	
	PXColorArrayRemoveColorAtIndex(array, 0);
	
	STAssertTrue(PXColorArrayCount(array) == 100, @"The count of the color array should be 100");
	STAssertTrue(PXColorEqualsColor(PXColorArrayColorAtIndex(array, 0), thirdColor),
				 @"The indicated color was not removed");
	
	PXColorArrayRemoveColorAtIndex(array, 99);
	
	STAssertTrue(PXColorArrayCount(array) == 99, @"The count of the color array should be 99");
	
	PXColorArrayEnumerateWithBlock(array, ^(PXColor color) {
		STAssertTrue(PXColorEqualsColor(color, thirdColor), @"Wrong color values were enumerated");
	});
	
	PXColorArrayInsertColorAtIndex(array, 99, fourthColor);
	
	STAssertTrue(PXColorArrayCount(array) == 100, @"The count of the color array should be 100");
	STAssertTrue(PXColorEqualsColor(PXColorArrayColorAtIndex(array, 99), fourthColor),
				 @"The given color was not inserted");
	
	PXColorArrayInsertColorAtIndex(array, 0, fourthColor);
	
	STAssertTrue(PXColorArrayCount(array) == 101, @"The count of the color array should be 101");
	STAssertTrue(PXColorEqualsColor(PXColorArrayColorAtIndex(array, 0), fourthColor),
				 @"The given color was not inserted");
	STAssertTrue(PXColorEqualsColor(PXColorArrayColorAtIndex(array, 100), fourthColor),
				 @"The colors did not shift correctly after the insertion");
	
	PXColorArrayMoveColor(array, 0, 4);
	
	STAssertTrue(PXColorArrayCount(array) == 101, @"The count of the color array should be 101");
	STAssertTrue(PXColorEqualsColor(PXColorArrayColorAtIndex(array, 0), thirdColor), @"The move failed");
	STAssertTrue(PXColorEqualsColor(PXColorArrayColorAtIndex(array, 4), fourthColor), @"The move failed");
	
	PXColorArrayMoveColor(array, 4, 102);
	
	STAssertTrue(PXColorArrayCount(array) == 101, @"The count of the color array should be 101");
	STAssertTrue(PXColorEqualsColor(PXColorArrayColorAtIndex(array, 4), thirdColor), @"The move failed");
	STAssertTrue(PXColorEqualsColor(PXColorArrayColorAtIndex(array, 100), fourthColor), @"The move failed");
	
	PXColorArrayRelease(array);
}

@end
