//
//  DarkAppearanceOverrides.m
//  DarkAppearanceOverrides
//
//  Created by Leo Natan (Wix) on 1/28/19.
//  Copyright © 2019 Leo Natan. All rights reserved.
//

#import <AppKit/AppKit.h>
@import ObjectiveC;

@interface NSColor (AppleOverrides) @end
@implementation NSColor (AppleOverrides)

+ (void)load
{
	if([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.AppStore"] ||
	   [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.mail"])
	{
		Method m1 = class_getClassMethod(self.class, @selector(systemBlueColor));
		Method m2 = class_getClassMethod(self.class, @selector(__ln_systemBlueColor));
		
		method_exchangeImplementations(m1, m2);
	}
	//
}

+ (NSColor *)linkColor
{
	return NSColor.controlAccentColor;
}

+ (NSColor *)__ln_systemBlueColor
{
	return NSColor.controlAccentColor;
}

@end

@interface NSImage (AppleOverrides) @end
@implementation NSImage (AppleOverrides)

+ (void)load
{
	Method m1 = class_getInstanceMethod(self.class, @selector(csk_imageTintedWithColor:));
	if(m1 == NULL)
	{
		return;
	}
	
	Method m2 = class_getInstanceMethod(self.class, @selector(__ln_csk_imageTintedWithColor:));
	
	method_exchangeImplementations(m1, m2);
}

- (NSImage*)__ln_imageTintedWithColor:(NSColor*)color
{
	return [NSImage imageWithSize:self.size flipped:NO drawingHandler:^BOOL(NSRect dstRect)
			{
				if([NSAppearance.currentAppearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]] == NSAppearanceNameDarkAqua)
				{
					[[color colorWithSystemEffect:NSColorSystemEffectDeepPressed] setFill];
				}
				else
				{
					[color setFill];
				}
				
				NSRectFill(dstRect);
				
				[self drawInRect:dstRect fromRect:dstRect operation:NSCompositingOperationDestinationIn fraction:1.0];
				
				return YES;
			}];
}

- (NSImage*)__ln_csk_imageTintedWithColor:(NSColor*)color
{
	if(color != NSColor.systemBlueColor)
	{
		return [self __ln_csk_imageTintedWithColor:color];
	}
	
	return [self __ln_imageTintedWithColor:NSColor.controlAccentColor];
	
	//	self.template = YES;
	//	return self;
}

@end

@interface NSProgressIndicator (AppleOverrides) @end
@implementation NSProgressIndicator (AppleOverrides)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.Safari"])
		{
			//🤦‍♂️ Apple is setting aqua appearance to the progress indicator.
			Method m = class_getInstanceMethod(self.class, @selector(__ln_setAppearance:));
			
			class_addMethod(self.class, @selector(setAppearance:), method_getImplementation(m), method_getTypeEncoding(m));
		}
	});
}

- (void)__ln_setAppearance:(NSAppearance *)appearance
{
	[super setAppearance:NSApp.effectiveAppearance];
}

@end
