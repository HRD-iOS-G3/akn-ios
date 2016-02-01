//
//  AppDelegate.m
//  AKN
//
//  Created by Ponnreay on 1/1/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "AppDelegate.h"
#import <Google/Analytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[NSThread sleepForTimeInterval:2];
	self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Sidebar" bundle:nil];
	
	// determine the initial view controller here and instantiate it with
	UIViewController *viewController =  [storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
	
	self.window.rootViewController = viewController;
	[self.window makeKeyAndVisible];
	
	// Override point for customization after application launch.
	UIPageControl *pageControl = [UIPageControl appearance];
	pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
	pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
	pageControl.backgroundColor = [UIColor whiteColor];
	
	// Configure tracker from GoogleService-Info.plist.
	NSError *configureError;
	[[GGLContext sharedInstance] configureWithError:&configureError];
	NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
	
	// Optional: configure GAI options.
	//	GAI *gai = [GAI sharedInstance];
	//	gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
	//	gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
	
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
