//
//  PathUtilities.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *GetApplicationSupportDirectory(void);
extern NSString *GetPixenSupportDirectory(void);
extern NSString *GetPixenPaletteDirectory(void);
extern NSString *GetPixenBackgroundsDirectory(void);
extern NSString *GetBackgroundPresetsDirectory(void);
extern NSString *GetBackgroundImagesDirectory(void);

extern NSString *GetPixenPatternFile(void);
extern NSString *GetPathForBackgroundNamed(NSString *name);

extern NSString *GetDescriptionForDocumentType(NSString *uti);
