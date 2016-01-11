//
//  MainViewController.m
//  AKN
//
//  Created by Kokpheng on 1/3/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "MainViewController.h"
#import "SWRevealViewController.h"


#import "CAPSPageMenu.h"
#import "TablePageViewController.h"
#import "viewPageController.h"
#include "TableSourceViewController.h"

@interface MainViewController ()<SWRevealViewControllerDelegate>

@property (nonatomic) CAPSPageMenu *pageMenu;

@end

@implementation MainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
	[self customizePageMenu];
    [self customizeSlideOutMenu];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // change status color
	
   // self.revealViewController.rightViewRevealOverdraw = 0.0f;
   // self.revealViewController.rearViewRevealOverdraw = 260.0f;
    
    [self.sidebarButton setTarget: self.revealViewController];
    [self.sidebarButton setAction: @selector( revealToggle: )];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
  //  [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
}


-(void)customizePageMenu{
	self.title = @"ALL KHMER NEWS";
	//self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
	self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:193.0/255.0 green:0.0/255.0 blue:1.0/255.0 alpha:1.0];[UIColor redColor];
	self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
	//[self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
	//self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
//	self.navigationController.navigationBar.tintColor = [UIColor blueColor];
	self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Arial-Bold" size:0.0]};
	
	
	UIStoryboard *pageMenuStoryboard = [UIStoryboard storyboardWithName:@"PageMenu" bundle:nil];
	
	
	TablePageViewController *controller1 = [pageMenuStoryboard instantiateViewControllerWithIdentifier:@"home"];
	controller1.title = @"Home";
	viewPageController *controller2 =[pageMenuStoryboard instantiateViewControllerWithIdentifier:@"category"];
	controller2.title = @"Category";
	TableSourceViewController *controller3=[pageMenuStoryboard instantiateViewControllerWithIdentifier:@"source"];
	controller3.title=@"Source";
	NSArray *controllerArray = @[controller1, controller2,controller3];
	NSDictionary *parameters = @{CAPSPageMenuOptionMenuItemSeparatorWidth: @(0.0),
								 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
								 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.0),
								 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor blackColor],
								 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor redColor],
								 CAPSPageMenuOptionMenuItemSeparatorRoundEdges:@YES,
								 };
	_pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0,64, self.view.frame.size.width, self.view.frame.size.height-64) options:parameters];
	[self.view addSubview:_pageMenu.view];

}

-(void) customizeSlideOutMenu{
    // INITIAL APPEARANCE: Configure the initial position of the menu and content views
    self.revealViewController.frontViewPosition = FrontViewPositionLeft; // FrontViewPositionLeft (only content), FrontViewPositionRight(menu and content), FrontViewPositionRightMost(only menu), see others at library documentation...
    self.revealViewController.rearViewRevealWidth = self.view.frame.size.width * 0.8; // how much of the menu is shown (default 260.0)
    
    // TOGGLING OVERDRAW: Configure the overdraw appearance of the content view while dragging it
    self.revealViewController.rearViewRevealOverdraw = 0.0f; // how much of an overdraw can occur when dragging further than 'rearViewRevealWidth' (default 60.0)
    self.revealViewController.bounceBackOnOverdraw = NO; // If YES the controller will bounce to the Left position when dragging further than 'rearViewRevealWidth' (default YES)
    
    // TOGGLING MENU DISPLACEMENT: how much displacement is applied to the menu when animating or dragging the content
    self.revealViewController.rearViewRevealDisplacement = 40.0f; // (default 40.0)
    
    // TOGGLING ANIMATION: Configure the animation while the menu gets hidden
    self.revealViewController.toggleAnimationType = SWRevealToggleAnimationTypeSpring; // Animation type (SWRevealToggleAnimationTypeEaseOut or SWRevealToggleAnimationTypeSpring)
    self.revealViewController.toggleAnimationDuration = 0.25f; // Duration for the revealToggle animation (default 0.25)
    self.revealViewController.springDampingRatio = 1.0f; // damping ratio if SWRevealToggleAnimationTypeSpring (default 1.0)
    
    // SHADOW: Configure the shadow that appears between the menu and content views
    self.revealViewController.frontViewShadowRadius = 10.0f; // radius of the front view's shadow (default 2.5)
    self.revealViewController.frontViewShadowOffset = CGSizeMake(0.0f, 2.5f); // radius of the front view's shadow offset (default {0.0f,2.5f})
    self.revealViewController.frontViewShadowOpacity = 0.8f; // front view's shadow opacity (default 1.0)
    self.revealViewController.frontViewShadowColor = [UIColor darkGrayColor]; // front view's shadow color (default blackColor)
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end