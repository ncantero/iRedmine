//
//  iRedmineAppDelegate.m
//  iRedmine
//
//  Created by Thomas Stägemann on 31.03.09.
//  Copyright Thomas Stägemann 2009. All rights reserved.
//

#import "iRedmineAppDelegate.h"

@implementation iRedmineAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	// Save data if appropriate
}


- (void)dealloc 
{
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
