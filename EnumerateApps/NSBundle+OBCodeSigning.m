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
        OSStatus signatureCheckResult = SecStaticCodeCheckValidityWithErrors(staticCode, kSecCSBasicValidateOnly, NULL, NULL);
        switch (signatureCheckResult) {
            case errSecSuccess:
                resultState |= OBCodeSignStateSignatureValid;
                break;
            case errSecCSUnsigned:
                resultState |= OBCodeSignStateUnsigned;
                break;
            case errSecCSSignatureFailed:
            case errSecCSSignatureInvalid:
                resultState |= OBCodeSignStateSignatureInvalid;
                break;
            case errSecCSSignatureNotVerifiable:
                resultState |= OBCodeSignStateSignatureNotVerifiable;
                break;
            case errSecCSSignatureUnsupported:
                resultState |= OBCodeSignStateSignatureUnsupported;
                break;
            default:
                resultState = OBCodeSignStateError;
                break;
        }
        
        if ((resultState & OBCodeSignStateSignatureValid) == OBCodeSignStateSignatureValid) 
        {
            SecRequirementRef sandboxRequirement = NULL;
            OSStatus requirementResult = SecRequirementCreateWithString(CFSTR("entitlement[\"com.apple.security.app-sandbox\"] exists"), kSecCSDefaultFlags, &sandboxRequirement);
            if (requirementResult == errSecSuccess) 
            {
                OSStatus codeCheckResult = SecStaticCodeCheckValidityWithErrors(staticCode, kSecCSBasicValidateOnly, sandboxRequirement, NULL);
                if (codeCheckResult == errSecSuccess) {
                    resultState |= OBCodeSignStateSandboxed;
                }
                CFRelease(sandboxRequirement);
            }
        }
        else
        {
            resultState = OBCodeSignStateError;
        }
        CFRelease(staticCode);
    }
    else
    {
        resultState = OBCodeSignStateError;
    }
    
    return resultState;
}

@end
