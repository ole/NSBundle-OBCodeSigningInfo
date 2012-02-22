//
//  main.m
//  EnumerateApps
//
//  Created by Ole Begemann on 22.02.12.
//  Copyright (c) 2012 Ole Begemann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/SecCode.h>
#import <Security/SecRequirement.h>


int main(int argc, const char * argv[])
{
    @autoreleasepool 
    {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSArray *appDirectories = [fileManager URLsForDirectory:NSApplicationDirectory inDomains:NSAllDomainsMask];
        
        for (NSURL *directory in appDirectories) 
        {
            NSString *directoryPath = [directory path];
            BOOL fileExists = [fileManager fileExistsAtPath:directoryPath];
            if (!fileExists) {
                NSLog(@"Skipping %@ because it does not exist.", directoryPath);
                continue;
            }
            
            NSArray *propertiesToCache = [NSArray arrayWithObjects:NSURLNameKey, NSURLTypeIdentifierKey, nil];
            NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtURL:directory includingPropertiesForKeys:propertiesToCache options:NSDirectoryEnumerationSkipsPackageDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
                
                NSLog(@"Error enumerating %@ in %@: %@", url, directory, error);
                return YES;
            }];
            
            for (NSURL *url in directoryEnumerator) 
            {
                NSDictionary *resourceValues = [url resourceValuesForKeys:propertiesToCache error:NULL];
                NSString *uti = [resourceValues objectForKey:NSURLTypeIdentifierKey];
                
                if ([uti isEqualToString:@"com.apple.application-bundle"]) 
                {
                    NSString *appName = [resourceValues objectForKey:NSURLNameKey];
                    NSBundle *appBundle = [[NSBundle alloc] initWithURL:url];
                    NSURL *appStoreReceiptURL = [appBundle appStoreReceiptURL];
                    BOOL appStoreReceiptExists = [fileManager fileExistsAtPath:[appStoreReceiptURL path]];
                    if (appStoreReceiptExists) {
                        NSLog(@"%@ is from the Mac App Store.", appName);
                    }

                    BOOL isSandboxed = NO;
                    SecStaticCodeRef staticCode = NULL;
                    SecStaticCodeCreateWithPath((__bridge CFURLRef)url, kSecCSDefaultFlags, &staticCode);
                    if (staticCode != NULL)
                    {
                        SecRequirementRef reqRef = NULL;
                        SecRequirementCreateWithString(CFSTR("entitlement[\"com.apple.security.app-sandbox\"] exists"), kSecCSDefaultFlags, &reqRef);
                        
                        if (reqRef != NULL)
                        {
                            OSStatus status = SecStaticCodeCheckValidityWithErrors(staticCode, kSecCSDefaultFlags, reqRef, NULL);
//                            NSLog(@"Status: %i", status);
                            if (status == noErr)
                            {
                                isSandboxed = YES;
                                NSLog(@"%@ is sandboxed", appName);
                            };
                        }
                    }
                }
            }
        }
        
    }
    return 0;
}

