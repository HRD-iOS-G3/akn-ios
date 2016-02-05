//
//  ViewController.m
//  PagingMenu
//
//  Created by Chum Ratha on 1/4/16.
//  Copyright © 2016 Chum Ratha. All rights reserved.
//

#import "ViewController.h"
#import "TablePageViewController.h"
#import "viewPageController.h"
#include "TableSourceViewController.h"
#import "Utilities.h"
@interface ViewController ()
@property (nonatomic) CAPSPageMenu *pageMenu;
@end

@implementation ViewController
{
    __weak IBOutlet UIView *myview;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utilities customizeNavigationBar:self.navigationController withTitle:@"ALL KHMER NEWS"];
    
    // set tab view controller title
    TablePageViewController *controller1 = [self.storyboard instantiateViewControllerWithIdentifier:@"home"];
    controller1.title = @"Home";
    
    viewPageController *controller2 =[self.storyboard instantiateViewControllerWithIdentifier:@"category"];
    controller2.title = @"Category";
    
    TableSourceViewController *controller3=[self.storyboard instantiateViewControllerWithIdentifier:@"source"];
    controller3.title=@"Source";
    
    NSLog(@"I love Cambodia");
    NSArray *controllerArray = @[controller1, controller2,controller3];
    NSDictionary *parameters = @{CAPSPageMenuOptionMenuItemSeparatorWidth: @(0),
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.0),
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor blackColor],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor redColor],
                                 CAPSPageMenuOptionMenuItemSeparatorRoundEdges:@YES,
                                 };
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0,63, self.view.frame.size.width, self.view.frame.size.height-63) options:parameters];
    [self.view addSubview:_pageMenu.view];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
