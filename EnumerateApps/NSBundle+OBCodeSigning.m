//
//  NSBundle+OBCodeSigning.m
//  EnumerateApps
//
//  Created by Ole Begemann on 22.02.12.
//  Copyright (c) 2012 Ole Begemann. All rights reserved.
//

#import "NSBundle+OBCodeSigning.h"
#import <Security/SecCode.h>
#import <Security/SecRequirement.h>


@implementation NSBundle (OBCodeSigning)

- (BOOL)comesFromAppStore
{
    // Check existence of Mac App Store receipt
    NSURL *appStoreReceiptURL = [self appStoreReceiptURL];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL appStoreReceiptExists = [fileManager fileExistsAtPath:[appStoreReceiptURL path]];
    return appStoreReceiptExists;
}


- (OBCodeSignState)codeSignState
{
    OBCodeSignState resultState = 0;

    NSURL *bundleURL = [self bundleURL];
    SecStaticCodeRef staticCode = NULL;
    OSStatus staticCodeResult = SecStaticCodeCreateWithPath((__bridge CFURLRef)bundleURL, kSecCSDefaultFlags, &staticCode);
    if (staticCodeResult == errSecSuccess) 
    {
        SecRequirementRef requirement = NULL;
        OSStatus requirementResult = SecRequirementCreateWithString(CFSTR("entitlement[\"com.apple.security.app-sandbox\"] exists"), kSecCSDefaultFlags, &requirement);
        if (requirementResult == errSecSuccess) 
        {
            OSStatus codeCheckResult = SecStaticCodeCheckValidityWithErrors(staticCode, kSecCSBasicValidateOnly, requirement, NULL);
            if (codeCheckResult == errSecSuccess) {
                resultState |= OBCodeSignStateSandboxed;
            } else if (codeCheckResult == errSecCSUnsigned) {
                resultState |= OBCodeSignStateUnsigned;
            } else if (codeCheckResult == errSecCSSignatureFailed || codeCheckResult == errSecCSSignatureInvalid) {
                resultState |= OBCodeSignStateSignatureInvalid;
            } else if (codeCheckResult == errSecCSSignatureNotVerifiable) {
                resultState |= OBCodeSignStateSignatureNotVerifiable;
            } else if (codeCheckResult == errSecCSSignatureUnsupported) {
                resultState |= OBCodeSignStateSignatureUnsupported;
            }
            CFRelease(requirement);
        }
        else
        {
            resultState |= OBCodeSignStateError;
        }
        CFRelease(staticCode);
    }
    else
    {
        resultState |= OBCodeSignStateError;
    }
    
    return resultState;
}

@end
