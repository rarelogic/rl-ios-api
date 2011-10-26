//  Created by Alejandro Isaza on 11-08-15.
//  Copyright 2011 Preterra Corp. All rights reserved.

#import "RareLogicTestAppDelegate.h"

@implementation RareLogicTestAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [RareLogic sharedInstanceWithProfile: @"rarelogic.com"];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
	
    return YES;
}

- (void)dealloc {
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
