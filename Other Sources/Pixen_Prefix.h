//
// Prefix header for all source files of the 'Pixen' target in the 'Pixen' project
//

#ifdef __OBJC__
    #import <Cocoa/Cocoa.h>
    #import "NSArray_DeepMutableCopy.h"
    #import "PXNotifications.h"
    #import "PXDefaults.h"
    #import "Constants.h"
#endif

#if !(__has_feature(objc_arc))
#define __bridge
#endif

#if !(__has_feature(objc_arc))
#define __unsafe_unretained
#endif
