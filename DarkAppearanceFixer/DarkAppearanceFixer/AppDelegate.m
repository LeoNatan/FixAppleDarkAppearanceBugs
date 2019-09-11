//
//  AppDelegate.m
//  DarkAppearanceFixer
//
//  Created by Leo Natan (Wix) on 9/6/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSURL* frameworkURL = [NSBundle.mainBundle URLForResource:@"mach_inject_bundle" withExtension:@"framework"];
	NSURL* frameworkInUsrLocalLib = [[NSURL fileURLWithPath:@"/usr/local/lib"] URLByAppendingPathComponent:frameworkURL.lastPathComponent];
	
	[NSFileManager.defaultManager removeItemAtURL:frameworkInUsrLocalLib error:NULL];
	[NSFileManager.defaultManager copyItemAtURL:frameworkURL toURL:frameworkInUsrLocalLib error:NULL];
}

@end
