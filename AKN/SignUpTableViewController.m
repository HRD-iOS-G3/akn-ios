//
//  SignUpTableViewController.m
//  AKN_news
//
//  Created by Chum Ratha on 1/1/16.
//  Copyright © 2016 Chum Ratha. All rights reserved.
//

#import "SignUpTableViewController.h"
#import "SWRevealViewController.h"

@interface SignUpTableViewController ()

@end

@implementation SignUpTableViewController
{

    IBOutlet UITapGestureRecognizer *gestTab;
    __weak IBOutlet UIButton *btnSignUp;
    __weak IBOutlet UITextField *txtPwd;
    __weak IBOutlet UITextField *txtEmail;
    __weak IBOutlet UITextField *txtFullName;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // change status color
    
    [self customizePageMenu];
    
    [self.tableView addGestureRecognizer:gestTab];
    txtEmail.layer.masksToBounds=YES;
//    txtEmail.layer.borderColor=[UIColor lightGrayColor].CGColor;
//    txtEmail.layer.borderWidth=1;
    txtPwd.layer.masksToBounds=YES;
//    txtPwd.layer.borderColor=[UIColor lightGrayColor].CGColor;
//    txtPwd.layer.borderWidth=1;
    txtFullName.layer.masksToBounds=YES;
//    txtFullName.layer.borderColor=[UIColor lightGrayColor].CGColor;
//    txtFullName.layer.borderWidth=1;
    btnSignUp.layer.cornerRadius=6;
    
    //Set SWReveal
    [self.sidebarButton setTarget: self.revealViewController];
    [self.sidebarButton setAction: @selector( revealToggle: )];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

}

#pragma mark - Navigation bar color

-(void)customizePageMenu{
    self.title = @"Sign Up";
    
    self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:193.0/255.0 green:0.0/255.0 blue:1.0/255.0 alpha:1.0];[UIColor redColor];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Arial-Bold" size:0.0]};
}

- (IBAction)gestTab:(id)sender {
    [txtPwd endEditing:YES];
    [txtFullName endEditing:YES];
    [txtEmail endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signUp_Touch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
