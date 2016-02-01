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
    
    
    // border radius for button
    [self.signUpButton.layer setCornerRadius:self.signUpButton.bounds.size.height/2];
    self.signUpButton.clipsToBounds = YES;
    
    
    //Set GradienColor for control
    NSArray *gradientColor =[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00] CGColor], (id)[[UIColor colorWithRed:(140/225.0) green:(30/255.0) blue:(30/255.0) alpha:1.00] CGColor], nil];
    [self setGradientColor:self.signUpButton NSArrayColor:gradientColor];
    

    
    //Set SWReveal
    [self.sidebarButton setTarget: self.revealViewController];
    [self.sidebarButton setAction: @selector( revealToggle: )];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    
    // change background color
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00]];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:(241/255.0) green:(241/255.0) blue:(241/255.0) alpha:1.00]];

}

-(void)setGradientColor:(UIView *)control NSArrayColor:(NSArray *)arrayColor{
    //Set GradienColor for control
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = control.bounds;
    gradient.colors = arrayColor;
    
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(0, 1);
    [control.layer insertSublayer:gradient atIndex:0];
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

#pragma mark: - Sign Up
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
        [SVProgressHUD show];
        [self.view setUserInteractionEnabled:false];
        
        // disable login button
        self.signUpButton.enabled = false;
               
        //Create connection object
        manager = [[ConnectionManager alloc] init];
        
        //Set delegate
        manager.delegate = self;
        
        //Create dictionary for store article detail input from user
        NSDictionary *dictionaryObject = @{
                                           @"username": name,
                                           @"email": email,
                                           @"password": password,
                                           @"image": @""
                                           
                                           };
        
        
        //Send data to server and insert it
        [manager requestDataWithURL:dictionaryObject withKey:@"/api/user/" method:@"POST"];
        
    }
    
}


-(void)dismissKeyboard{
    [self.view endEditing:YES];
}

#pragma mark: - ConnectionManagerDelegate
-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
    
    [self.view setUserInteractionEnabled:true];
    
    // disable login button
    self.signUpButton.enabled =true;
    
    if([[result valueForKey:@"MESSAGE"] containsString:@"SUCCESS"]){
        [SVProgressHUD dismiss];
        //open home view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Sidebar" bundle:nil];
        
        // determine the initial view controller here and instantiate it with
        UIViewController *viewController =  [storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else{
         [SVProgressHUD showErrorWithStatus:@"SignUp Failed\nThis username is already created!!!"];
    }
}

@end
