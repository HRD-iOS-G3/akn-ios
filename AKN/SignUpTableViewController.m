//
//  SignUpTableViewController.m
//  AKN_news
//
//  Created by Chum Ratha on 1/1/16.
//  Copyright © 2016 Chum Ratha. All rights reserved.
//

#import "SignUpTableViewController.h"
#import "SWRevealViewController.h"
#import "ConnectionManager.h"
#import "SVProgressHUD.h"
#import "Utilities.h"
#import <Google/Analytics.h>

@interface SignUpTableViewController ()<ConnectionManagerDelegate>{
    ConnectionManager *manager;
}

@end

@implementation SignUpTableViewController
{

    IBOutlet UITapGestureRecognizer *gestTab;
    __weak IBOutlet UIButton *btnSignUp;
    __weak IBOutlet UITextField *txtPwd;
    __weak IBOutlet UITextField *txtEmail;
    __weak IBOutlet UITextField *txtFullName;
}


-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	// May return nil if a tracker has not already been initialized with a
	// property ID.
	id tracker = [[GAI sharedInstance] defaultTracker];
	
	// This screen name value will remain set on the tracker and sent with
	// hits until it is set to a new value or to nil.
	[tracker set:kGAIScreenName
		   value:@"Signup Screen"];
	
	// Previous V3 SDK versions
	// [tracker send:[[GAIDictionaryBuilder createAppView] build]];
	
	// New SDK versions
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Create connection object
    manager = [[ConnectionManager alloc] init];
    
    //Set delegate
    manager.delegate = self;
    
    [Utilities customizeNavigationBar:self.navigationController withTitle:@"Sign Up"];
    
    // border radius for button
    [Utilities setBorderRadius:self.signUpButton];
    
    [self.tableView addGestureRecognizer:gestTab];
    
    // Design Style Control
    txtEmail.layer.masksToBounds=YES;
    txtPwd.layer.masksToBounds=YES;
    txtFullName.layer.masksToBounds=YES;
    btnSignUp.layer.cornerRadius=6;
        
    //Set GradienColor for control
    NSArray *gradientColor  = [NSArray arrayWithObjects:
                               (id)[[UIColor colorWithRed:(200/255.0)
                                                    green:(38/255.0)
                                                     blue:(38/255.0)
                                                    alpha:1.00] CGColor],
                               (id)[[UIColor colorWithRed:(140/225.0)
                                                    green:(30/255.0)
                                                     blue:(30/255.0)
                                                    alpha:1.00] CGColor], nil];

    [Utilities setGradientColor:self.signUpButton NSArrayColor:gradientColor];
    
    //Set SWReveal
    [Utilities setSWRevealSidebarButton:self.sidebarButton :self.revealViewController :self.view];
}

- (IBAction)gestTab:(id)sender {
    [txtPwd endEditing:YES];
    [txtFullName endEditing:YES];
    [txtEmail endEditing:YES];
}


#pragma mark: - sign up event
- (IBAction)signUpAction:(id)sender {
     // dismiss keyboard
    [self dismissKeyboard];
    
    // Get value from text field
    NSString * name = self.nameTextField.text;
    NSString * email = self.emailTextField.text;
    NSString * password = self.passwordTextField.text;
    
    // validate text field
    if ([name isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"Please complete name"];
    }else if ([email isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"Please complete email"];
    }else if ([password isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"Please complete pasword"];
    }else{
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD show];
        
        //Create dictionary for store article detail input from user
        NSDictionary * param = @{ @"username": name,
                                  @"email": email,
                                  @"password": password,
                                  @"image": @""};
        
        //Send data to server and insert it
        [manager requestDataWithURL:SIGNUP_URL data:param method:POST];
    }
}



#pragma mark: - ConnectionManagerDelegate
-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    // check sign up status
    if([[result valueForKey:R_KEY_MESSAGE] containsString:SIGNUP_SUCCESS]){
        //open home view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Sidebar" bundle:nil];
        
        // determine the initial view controller here and instantiate it with
        UIViewController *viewController =  [storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else{
        [SVProgressHUD showErrorWithStatus:SIGNUP_UNSUCCESS];
    }
}

-(void)dismissKeyboard{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
