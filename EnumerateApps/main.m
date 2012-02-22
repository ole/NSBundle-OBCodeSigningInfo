//
//  main.m
//  EnumerateApps
//
//  Created by Ole Begemann on 22.02.12.
//  Copyright (c) 2012 Ole Begemann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSBundle+OBCodeSigning.h"


int main(int argc, const char * argv[])
{
    @autoreleasepool 
    {
        if (argc > 1)
        {
            for (unsigned int argumentIndex = 1; argumentIndex < argc; argumentIndex++)
            {
                const char *argument = argv[argumentIndex];
                NSString *bundlePath = [NSString stringWithCString:argument encoding:NSUTF8StringEncoding];
                NSString *appName = [bundlePath lastPathComponent];
                NSBundle *appBundle = [NSBundle bundleWithPath:bundlePath];
                
                BOOL comesFromAppStore = [appBundle comesFromAppStore];
                OBCodeSignState codeSignState = [appBundle codeSignState];
                if (comesFromAppStore) {
                    NSLog(@"%@ is from the Mac App Store.", appName);
                }
                if ((codeSignState & OBCodeSignStateError) == OBCodeSignStateError || codeSignState == OBCodeSignStateInvalidState) 
                {
                    NSLog(@"An error occured checking %@'s signature.", appName);
                }
                else
                {
                    if ((codeSignState & OBCodeSignStateUnsigned) == OBCodeSignStateUnsigned) {
                        NSLog(@"%@ is not code signed.", appName);
                    }
                    if ((codeSignState & OBCodeSignStateSignatureValid) == OBCodeSignStateSignatureValid) {
                        NSLog(@"%@ has a valid code signature.", appName);
                    }
                    if ((codeSignState & OBCodeSignStateSignatureInvalid) == OBCodeSignStateSignatureInvalid) {
                        NSLog(@"%@ has an invalid code signature.", appName);
                    }
                    if ((codeSignState & OBCodeSignStateSignatureUnsupported) == OBCodeSignStateSignatureUnsupported) {
                        NSLog(@"%@ has an unsupported code signature.", appName);
                    }
                    if ((codeSignState & OBCodeSignStateSignatureNotVerifiable) == OBCodeSignStateSignatureNotVerifiable) {
                        NSLog(@"%@'s signature could not be verified.", appName);
                    }
                    if ((codeSignState & OBCodeSignStateSandboxed) == OBCodeSignStateSandboxed) {
                        NSLog(@"%@ is sandboxed.", appName);
                    } else {
                        NSLog(@"%@ is not sandboxed.", appName);
                    }
                }
            }
        }
        else
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
                        
                        if ([appBundle comesFromAppStore]) {
                            NSLog(@"%@ is from the Mac App Store.", appName);
                        }
                        
                        BOOL isSandboxed = ([appBundle codeSignState] & OBCodeSignStateSandboxed) == OBCodeSignStateSandboxed;
                        if (isSandboxed) {
                            NSLog(@"%@ is sandboxed.", appName);
                        }
                    }
                }
            }
        }
    }
    return 0;
}

