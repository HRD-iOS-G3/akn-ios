//
//  SignUpTableViewController.m
//  AKN_news
//
//  Created by Chum Ratha on 1/1/16.
//  Copyright © 2016 Chum Ratha. All rights reserved.
//

#import "SignUpTableViewController.h"

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
