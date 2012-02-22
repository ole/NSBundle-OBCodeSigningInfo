//
//  NSBundle+OBCodeSigning.h
//  EnumerateApps
//
//  Created by Ole Begemann on 22.02.12.
//  Copyright (c) 2012 Ole Begemann. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    OBCodeSignStateUnsigned = 1L << 0,
    OBCodeSignStateSignatureValid = 1L << 1,
    OBCodeSignStateSignatureInvalid = 1L << 2,
    OBCodeSignStateSignatureNotVerifiable = 1L << 3,
    OBCodeSignStateSignatureUnsupported = 1L << 4,
    OBCodeSignStateSandboxed = 1L << 5,
    OBCodeSignStateError = 1L << 30
} OBCodeSignState;


@interface NSBundle (OBCodeSigning)

- (BOOL)comesFromAppStore;
- (OBCodeSignState)codeSignState;

@end
