//
//  LoginTableViewController.m
//  AKN_news
//
//  Created by Chum Ratha on 1/1/16.
//  Copyright © 2016 Chum Ratha. All rights reserved.
//

#import "LoginTableViewController.h"

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
