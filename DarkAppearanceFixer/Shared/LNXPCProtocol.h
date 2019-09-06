//
//  LNXPCProtocol.h
//  DarkAppearanceFixer
//
//  Created by Leo Natan (Wix) on 9/6/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#define LN_HELPER_XPC_SERVICE_NAME @"com.LeoNatan.DarkAppearanceFixer.Helper"

@protocol LNXPCProtocol <NSObject>

- (NSString*)startInjectingCodeBundleAtURL:(NSURL*)URL;

@end
