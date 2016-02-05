//
//  AboutUsTableViewController.m
//  AKN
//
//  Created by Kokpheng on 1/27/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "AboutUsTableViewController.h"
#import "SWRevealViewController.h"
#import "Utilities.h"

@interface AboutUsTableViewController ()

@end

@implementation AboutUsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utilities customizeNavigationBar:self.navigationController withTitle:@"ABOUT US"];

    //Set SWReveal
    [Utilities setSWRevealSidebarButton:self.sidebarButton :self.revealViewController :self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
