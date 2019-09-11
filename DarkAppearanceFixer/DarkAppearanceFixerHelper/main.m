//
//  main.m
//  DarkAppearanceFixerHelper
//
//  Created by Leo Natan (Wix) on 9/6/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "LNXPCProtocol.h"
#import "mach_inject_bundle.h"

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
	[NSWorkspace.sharedWorkspace addObserver:self forKeyPath:@"runningApplications" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
	
	NSArray* bundleIdentifiers = @[@"com.apple.finder"]; // [NSUserDefaults.standardUserDefaults objectForKey:@"bundleIdentifiers"];
	if(bundleIdentifiers)
	{
		[self startInjectingProcessesWithBundleIdentifiers:bundleIdentifiers];
	}
	
	[_listener resume];
	
	[NSRunLoop.currentRunLoop run];
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
	newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(LNXPCProtocol)];
	newConnection.exportedObject = self;
	[newConnection resume];
	
	return YES;
}

static NSMutableDictionary<NSString*, NSNumber*>* _trackedProcesses;

- (void)startInjectingProcessesWithBundleIdentifiers:(NSArray<NSString *> *)bundleIdentifiers
{
	NSMutableDictionary<NSString*, NSNumber*>* newProcesses = [NSMutableDictionary new];
	
	[bundleIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
		id oldPid = _trackedProcesses[key] ?: @(-1);
		newProcesses[key] = oldPid;
	}];
	
	_trackedProcesses = newProcesses;
	
	[self _injectAvailableProcessesIfNeeded];
	
	[NSUserDefaults.standardUserDefaults setObject:bundleIdentifiers forKey:@"bundleIdentifiers"];
}

- (void)_injectAvailableProcessesIfNeeded
{
	NSMutableDictionary<NSString*, NSNumber*>* newProcesses = [_trackedProcesses mutableCopy];
	
	[_trackedProcesses enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
		NSRunningApplication* app = [NSRunningApplication runningApplicationsWithBundleIdentifier:key].firstObject;
		pid_t pid = app ? app.processIdentifier : -1;
		
		if(pid != -1 && [obj isEqualToNumber:@(pid)] == NO)
		{
			mach_error_t err = mach_inject_bundle_pid("/usr/local/lib/libDarkAppearanceOverrides.dylib", pid);
			NSLog(@"%@", @(err));
		}
		
		newProcesses[key] = @(pid);
	}];
	
	_trackedProcesses = newProcesses;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
	if([keyPath isEqualToString:@"runningApplications"] && change[NSKeyValueChangeNewKey])
	{
		NSRunningApplication* app = [change[NSKeyValueChangeNewKey] firstObject];
		
		if(_trackedProcesses[app.bundleIdentifier])
		{
			[self _injectAvailableProcessesIfNeeded];
		}
	}
}

@end

int main(int argc, const char * argv[]) {
	[[LNHelper new] run];
	
	return 0;
}
