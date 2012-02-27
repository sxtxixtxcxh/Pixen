//
// Prefix header for all source files of the 'Pixen' target in the 'Pixen' project
//

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#if !__has_feature(objc_arc)
#define __unsafe_unretained
#define __bridge
#endif


#ifdef __OBJC__
	#import <Cocoa/Cocoa.h>
	#import "NSArray_DeepMutableCopy.h"
	#import "PXNotifications.h"
	#import "PXDefaults.h"
	#import "Constants.h"
#endif
