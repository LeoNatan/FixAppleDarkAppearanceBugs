//
//  ViewController.m
//  DarkAppearanceFixer
//
//  Created by Leo Natan (Wix) on 9/6/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import "ViewController.h"
@import ServiceManagement;
#import "LNXPCProtocol.h"

@implementation ViewController
{
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Do any additional setup after loading the view.
}

- (IBAction)installHelper:(id)sender
{
	AuthorizationRef _authRef;
	AuthorizationItem authItem = {kSMRightBlessPrivilegedHelper, 0, NULL, 0};
	AuthorizationRights authRights = {1, &authItem};
	AuthorizationFlags flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
	OSStatus err = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &_authRef);
	
	if(err != errAuthorizationSuccess)
	{
		[NSApp presentError:[NSError errorWithDomain:@"AuthError" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Authorization failed."}]];
		return;
	}
	
	CFErrorRef error;
	if(NO == SMJobBless(kSMDomainSystemLaunchd, CFSTR("com.LeoNatan.DarkAppearanceFixer.Helper"), _authRef, &error))
	{
		[NSApp presentError:((__bridge NSError*)error)];
	}
}

- (IBAction)connectAndAttemptRempte:(id)sender
{
	NSXPCConnection* connection = [[NSXPCConnection alloc] initWithMachServiceName:LN_HELPER_XPC_SERVICE_NAME options:NSXPCConnectionPrivileged];
	connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(LNXPCProtocol)];
	[connection resume];
	
	[connection.remoteObjectProxy startInjectingCodeBundleAtURL:[NSURL URLWithString:@"https://www.ynet.co.il"]];
	
	[connection invalidate];
}

@end
