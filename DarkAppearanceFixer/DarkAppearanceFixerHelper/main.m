//
//  main.m
//  DarkAppearanceFixerHelper
//
//  Created by Leo Natan (Wix) on 9/6/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LNXPCProtocol.h"

@interface LNHelper : NSObject <NSXPCListenerDelegate, LNXPCProtocol> @end
@implementation LNHelper
{
	NSXPCListener* _listener;
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		_listener = [[NSXPCListener alloc] initWithMachServiceName:LN_HELPER_XPC_SERVICE_NAME];
		_listener.delegate = self;
	}
	
	return self;
}

- (void)run
{
	[_listener resume];
	
	dispatch_main();
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
	newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(LNXPCProtocol)];
	newConnection.exportedObject = self;
	[newConnection resume];
	
	return YES;
}

- (NSString*)startInjectingCodeBundleAtURL:(NSURL*)URL
{
	NSLog(@"");
	
	return @"asd";
}

@end

int main(int argc, const char * argv[]) {
	[[LNHelper new] run];
	
	return 0;
}
