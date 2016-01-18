//
//  LoginTableViewController.m
//  AKN_news
//
//  Created by Chum Ratha on 1/1/16.
//  Copyright © 2016 Chum Ratha. All rights reserved.
//

#import "LoginTableViewController.h"
#import "SWRevealViewController.h"

@interface LoginTableViewController ()

@end

@implementation LoginTableViewController
{
    IBOutlet UITapGestureRecognizer *gesture;
    __weak IBOutlet UIButton *btnLogin;
    __weak IBOutlet UITextField *txtPwd;
    __weak IBOutlet UITextField *txtEmail;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // change status color
    
    [self customizePageMenu];
    
    [self.tableView addGestureRecognizer:gesture];
    // Design Style Control
    txtEmail.layer.masksToBounds=YES;
//    txtEmail.layer.borderColor=[UIColor lightGrayColor].CGColor;
//    txtEmail.layer.borderWidth=1;
    txtPwd.layer.masksToBounds=YES;
//    txtPwd.layer.borderColor=[UIColor lightGrayColor].CGColor;
//    txtPwd.layer.borderWidth=1;
    btnLogin.layer.cornerRadius=6;
    // Do any additional setup after loading the view.
    
    
    //Set SWReveal
    [self.sidebarButton setTarget: self.revealViewController];
    [self.sidebarButton setAction: @selector( revealToggle: )];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

#pragma mark - Navigation bar color

-(void)customizePageMenu{
    self.title = @"Login";
    
    self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:193.0/255.0 green:0.0/255.0 blue:1.0/255.0 alpha:1.0];[UIColor redColor];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Arial-Bold" size:0.0]};
}


- (IBAction)gesture:(id)sender {
    [txtEmail endEditing:YES];
    [txtPwd endEditing:YES];
}
- (IBAction)actionLogin:(id)sender {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Sidebar" bundle:nil];
	
	// determine the initial view controller here and instantiate it with
	UIViewController *viewController =  [storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
