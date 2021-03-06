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
#import "DetailNewsTableViewController.h"
#import "SearchAllTableViewController.h"
#import "Connectivity.h"
#import "UIView+Toast.h"
#import "Utilities.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Google/Analytics.h>

@interface MainViewController ()<SWRevealViewControllerDelegate,UISearchBarDelegate>{
    UIView *disableViewOverlay;
	NSString *searchString;
}

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (nonatomic) CAPSPageMenu *pageMenu;
@property (nonatomic, strong) UIBarButtonItem *searchItem;
@property (nonatomic, strong) UISearchBar *searchBarField;

@end

@implementation MainViewController

static MainViewController *this;
+(MainViewController *)getInstance{
	return this;
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	// May return nil if a tracker has not already been initialized with a
	// property ID.
	id tracker = [[GAI sharedInstance] defaultTracker];
	
	// This screen name value will remain set on the tracker and sent with
	// hits until it is set to a new value or to nil.
	[tracker set:kGAIScreenName
		   value:@"Home Screen"];
	
	// Previous V3 SDK versions
	// [tracker send:[[GAIDictionaryBuilder createAppView] build]];
	
    
    
	// New SDK versions
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    // Allocate a reachability object
    Connectivity* reach = [Connectivity reachabilityWithHostname:@"http://akn.khmeracademy.org"];
    
    // Set the blocks
    reach.reachableBlock = ^(Connectivity*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
        });
    };
    
    reach.unreachableBlock = ^(Connectivity*reach)
    {
        NSLog(@"UNREACHABLE!");
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];

    
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
	this = self;
    [Utilities customizeNavigationBar:self.navigationController withTitle:@"ALL KHMER NEWS"];
	[self customizeTapBarTitle];
    [self customizeSlideOutMenu];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // change status color
    
    [self.sidebarButton setTarget: self.revealViewController];
    [self.sidebarButton setAction: @selector( revealToggle: )];
    
    //Set FrontView to blur by NSNotificationCenter
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector( visualBlurViewChange ) name:@"VisualEffectBlueViewChange" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector( visualBlurViewChange ) name:@"NSNotificationCenterHomeClick" object:nil];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    //search bar
    
    //self.searchItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    self.searchItem = [[UIBarButtonItem alloc] initWithCustomView:_searchButton];
    self.navigationItem.rightBarButtonItem = _searchItem;

    self.navigationItem.rightBarButtonItem = _searchItem;
    
    self.searchBarField = [[UISearchBar alloc] init];
    _searchBarField.showsCancelButton = YES;
    _searchBarField.delegate = self;
    disableViewOverlay = [[UIView alloc]
                               initWithFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height)];
    disableViewOverlay.backgroundColor=[UIColor blackColor];
    disableViewOverlay.alpha = 0;
    
    // change SVProgressHUD background color
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00]];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:(241/255.0) green:(241/255.0) blue:(241/255.0) alpha:1.00]];
    
}

-(void)test{
    
}

#pragma mark: - search bar tap event
- (IBAction)searchBarTapped:(id)sender {
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"X"];
    self.searchBarField.placeholder=@"Search Title of News";
    self.searchBarField.searchBarStyle=UISearchBarStyleMinimal;
    UITextField *textFieldInsideSearchBar =[self.searchBarField valueForKey:@"searchField"];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchBarCancelButtonClicked:)];
	[disableViewOverlay addGestureRecognizer:tap];
	
    textFieldInsideSearchBar.textColor=[UIColor whiteColor];
    [UIView animateWithDuration:0.1 animations:^{
        self.searchButton.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        // remove the search button
        self.navigationItem.rightBarButtonItem = nil;
        // add the search bar (which will start out hidden).
        self.navigationItem.titleView = _searchBarField;
        _searchBarField.alpha = 0.0;
        
        [UIView animateWithDuration:0.02
                         animations:^{
                             _searchBarField.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [_searchBarField becomeFirstResponder];
                         }];
        
    }];
}

#pragma mark UISearchBarDelegate methods
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"X"];
    self.searchBarField.placeholder=@"Search Title of News";
    self.searchBarField.searchBarStyle=UISearchBarStyleMinimal;
    UITextField *textFieldInsideSearchBar =[self.searchBarField valueForKey:@"searchField"];
    textFieldInsideSearchBar.textColor=[UIColor whiteColor];
    [UIView animateWithDuration:0.1f animations:^{
        _searchBarField.alpha = 0.0;
        } completion:^(BOOL finished) {
        self.navigationItem.titleView = nil;
        self.navigationItem.rightBarButtonItem = _searchItem;
        _searchButton.alpha = 0.0;  // set this *after* adding it back
        [UIView animateWithDuration:0.2f animations:^ {
            _searchButton.alpha = 1.0;
        }];
    }];
    [disableViewOverlay removeFromSuperview];
    self.searchBarField.text=@"";
}

#pragma mark: - search bar button event
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [disableViewOverlay removeFromSuperview];
    //[self searchBarTextDidEndEditing:searchBar];
    [self.searchBarField endEditing:YES];
    MainViewController *mvc = [MainViewController getInstance];
    SearchAllTableViewController *svc = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateViewControllerWithIdentifier:@"search"];
	svc.searchKey = searchString;
    //dvc.news = _newsList[indexPath.row];
    [mvc.navigationController pushViewController:svc animated:YES];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    disableViewOverlay.alpha = 0;
    [self.view addSubview:disableViewOverlay];
    
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    disableViewOverlay.alpha = 0.6;
    [UIView commitAnimations];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//    NSLog(@"End work");
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	searchString = searchText;
    [searchDelayer invalidate], searchDelayer=nil;
    if (YES /* ...or whatever validity test you want to apply */)
        searchDelayer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                         target:self
                                                       selector:@selector(doDelayedSearch:)
                                                       userInfo:searchText
                                                        repeats:NO];
}

-(void)doDelayedSearch:(NSTimer *)t
{
    assert(t == searchDelayer);
    [self request:searchDelayer.userInfo];
    searchDelayer = nil; // important because the timer is about to release and dealloc itself
}

-(void)request:(NSString *)myString{
//    NSLog(@"%@",myString);
}

#pragma mark Set FrontView to blur by NSNotificationCenter
-(void)visualBlurViewChange{
    if(self.revealViewController.frontViewPosition == 3)
  self.visualEffectView.layer.zPosition = 1;
    else if(self.revealViewController.frontViewPosition == 4)
        self.visualEffectView.layer.zPosition = 0;
}

#pragma mark - set tap tar title
-(void)customizeTapBarTitle{
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

#pragma mark - SlideOutMenu
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

@end