# NSBundle+OBCodeSigningInfo

A category on `NSBundle` that adds method to check an app bundle's code signing and sandboxing state.

Written by Ole Begemann, February 2012.

For more info, see the corresponding blog post: [Checking Code Signing and Sandboxing Status in Code](http://oleb.net/blog/2012/02/checking-code-signing-and-sandboxing-status-in-code/).

## WARNING

Please do not use this code in your apps. It was just a quick experiment and is neither tested nor secure.

## Usage

1. Add the files `NSBundle+OBCodeSigningInfo.h` and `NSBundle+OBCodeSigningInfo.m` to your Xcode project.
2. `#import "NSBundle+OBCodeSigningInfo.h"`
3. For a given `NSBundle`, call one or more of these methods to get information about its code signing state:

        - (BOOL)ob_comesFromAppStore;
        - (BOOL)ob_isSandboxed;
        - (OBCodeSignState)ob_codeSignState;
