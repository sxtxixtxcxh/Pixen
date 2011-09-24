//
//  PAGifImporter.h
//  Pixen Animator
//
//  Created by Andy Matuschak on Fri Jul 16 2004.
//  Copyright (c) 2004 Pixen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXGifImporter : NSObject

+ (BOOL)fileAtURLIsAnimated:(NSURL *)url;

@end
