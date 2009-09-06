//
//  PXBitmapExporter.h
//  Pixen-XCode
//
//  Created by Andy Matuschak on Wed Jun 09 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PXCanvas;
@interface PXBitmapExporter : NSObject
{

}

+ BMPDataForImage:image;
+ PICTDataForImage:image;
+ indexedBitmapDataForCanvas:(PXCanvas *)canvas;

@end
