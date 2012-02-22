//
//  NSBundle+SandboxingInfo.m
//  EnumerateApps
//
//  Created by Ole Begemann on 22.02.12.
//  Copyright (c) 2012 Ole Begemann. All rights reserved.
//

#import "NSBundle+SandboxingInfo.h"
#import <Security/SecCode.h>
#import <Security/SecRequirement.h>


@implementation NSBundle (SandboxingInfo)

- (BOOL)isSandboxed
{
    BOOL isSandboxed = NO;
    NSURL *bundleURL = [self bundleURL];
    SecStaticCodeRef staticCode = NULL;
    SecStaticCodeCreateWithPath((__bridge CFURLRef)bundleURL, kSecCSDefaultFlags, &staticCode);
    if (staticCode != NULL)
    {
        SecRequirementRef requirement = NULL;
        SecRequirementCreateWithString(CFSTR("entitlement[\"com.apple.security.app-sandbox\"] exists"), kSecCSDefaultFlags, &requirement);
        if (requirement != NULL)
        {
            OSStatus status = SecStaticCodeCheckValidityWithErrors(staticCode, kSecCSDefaultFlags, requirement, NULL);
            if (status == errSecSuccess) {
                isSandboxed = YES;
            };
            CFRelease(requirement);
        }
        CFRelease(staticCode);
    }
    return isSandboxed;
}

@end
