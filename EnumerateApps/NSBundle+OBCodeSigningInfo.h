//
//  NSBundle+OBCodeSigningInfo.h
//  EnumerateApps
//
//  Created by Ole Begemann on 22.02.12.
//  Copyright (c) 2012 Ole Begemann. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    OBCodeSignStateUnsigned = 1,
    OBCodeSignStateSignatureValid,
    OBCodeSignStateSignatureInvalid,
    OBCodeSignStateSignatureNotVerifiable,
    OBCodeSignStateSignatureUnsupported,
    OBCodeSignStateError
} OBCodeSignState;


@interface NSBundle (OBCodeSigningInfo)

- (BOOL)comesFromAppStore;
- (BOOL)isSandboxed;
- (OBCodeSignState)codeSignState;

@end
