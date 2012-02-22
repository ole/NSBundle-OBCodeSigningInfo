//
//  main.m
//  EnumerateApps
//
//  Created by Ole Begemann on 22.02.12.
//  Copyright (c) 2012 Ole Begemann. All rights reserved.
//

#import <Foundation/Foundation.h>

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

                    NSString *appPath = [url path];
                    NSString *codesignPath = @"/usr/bin/codesign";
                    NSArray *codesignArguments = [NSArray arrayWithObjects:@"-d", @"--entitlements", @"-", appPath, nil];
                    NSPipe *codesignPipeStdOut = [[NSPipe alloc] init];
                    NSPipe *codesignPipeStdErr = [[NSPipe alloc] init];
                    NSTask *codesignTask = [[NSTask alloc] init];
                    [codesignTask setLaunchPath:codesignPath];
                    [codesignTask setArguments:codesignArguments];
                    [codesignTask setStandardOutput:codesignPipeStdOut];
                    [codesignTask setStandardError:codesignPipeStdErr];
                    [codesignTask launch];
                    [codesignTask waitUntilExit];
                    NSFileHandle *codesignPipeHandle = [codesignPipeStdOut fileHandleForReading];
                    NSData *codesignOutputData = [codesignPipeHandle availableData];
                    //NSLog(@"%@", codesignOutputData);
                    NSDictionary *entitlements = nil;
                    entitlements = [NSPropertyListSerialization propertyListWithData:codesignOutputData options:NSPropertyListImmutable format:NULL error:NULL];
                    if (!entitlements) {
                        if ([codesignOutputData length] > 8) {
                            NSData *fixedCodesignData = [codesignOutputData subdataWithRange:NSMakeRange(8, [codesignOutputData length]-8)];
                            entitlements = [NSPropertyListSerialization propertyListWithData:fixedCodesignData options:NSPropertyListImmutable format:NULL error:NULL];
                        }
                    }
                    if (entitlements) {
                        BOOL isSandboxed = [[entitlements objectForKey:@"com.apple.security.app-sandbox"] boolValue];
                        if (isSandboxed) {
                            NSLog(@"%@ is sandboxed", appName);
                        }
                    }
                }
            }
        }
        
    }
    return 0;
}

