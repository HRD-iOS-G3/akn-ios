//
//  LoginTableViewController.m
//  AKN_news
//
//  Created by Chum Ratha on 1/1/16.
//  Copyright © 2016 Chum Ratha. All rights reserved.
//

#import "LoginTableViewController.h"
#import "SWRevealViewController.h"
#import "ConnectionManager.h"
#import "SVProgressHUD.h"
#import "Utilities.h"
#import <Google/Analytics.h>

@interface LoginTableViewController ()<ConnectionManagerDelegate>{
    ConnectionManager *manager;
}

@end

@implementation LoginTableViewController
{
    IBOutlet UITapGestureRecognizer *gesture;
    __weak IBOutlet UIButton *btnLogin;
    __weak IBOutlet UITextField *txtPwd;
    __weak IBOutlet UITextField *txtEmail;
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	// May return nil if a tracker has not already been initialized with a
	// property ID.
	id tracker = [[GAI sharedInstance] defaultTracker];
	
	// This screen name value will remain set on the tracker and sent with
	// hits until it is set to a new value or to nil.
	[tracker set:kGAIScreenName
		   value:@"Login Screen"];
	
	// Previous V3 SDK versions
	// [tracker send:[[GAIDictionaryBuilder createAppView] build]];
	
	// New SDK versions
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utilities customizeNavigationBar:self.navigationController withTitle:@"Login"];
    
    // border radius
    [self.loginButton.layer setCornerRadius:self.loginButton.bounds.size.height/2];
    self.loginButton.clipsToBounds = YES;
    
    //Set GradienColor for control
    NSArray *gradientColor  =[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00] CGColor], (id)[[UIColor colorWithRed:(140/225.0) green:(30/255.0) blue:(30/255.0) alpha:1.00] CGColor], nil];
    [Utilities setGradientColor:self.loginButton NSArrayColor:gradientColor];
    
    [self.tableView addGestureRecognizer:gesture];
    
    // Design Style Control
    txtEmail.layer.masksToBounds=YES;
    txtPwd.layer.masksToBounds=YES;
    btnLogin.layer.cornerRadius=6;
    // Do any additional setup after loading the view.
    
    //Set SWReveal
    [self.sidebarButton setTarget: self.revealViewController];
    [self.sidebarButton setAction: @selector( revealToggle: )];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (IBAction)gesture:(id)sender {
    [txtEmail endEditing:YES];
    [txtPwd endEditing:YES];
}

#pragma mark: - Login
- (IBAction)actionLogin:(id)sender {
    // dismiss keyboard
    [self dismissKeyboard];
    
    // Get value from text field
    NSString * email = self.usernameTextField.text;
    NSString * password = self.passwordTextField.text;
    
    // validate text field
    if ([email isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"Please complete username"];
    }else if ([password isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"Please complete pasword"];
    }else{
        [self.view setUserInteractionEnabled:false];
        
        // disable login button
        [self.activityIndicatorLoading startAnimating];
        self.loginButton.enabled = false;
        
        //Create connection object
        manager = [[ConnectionManager alloc] init];
        
        //Set delegate
        manager.delegate = self;
        
        // request dictionary
        NSDictionary * param = @{@"email": email,
                                 @"password":password};
        
        // send data to server
        [manager requestDataWithURL:LOGIN_URL data:param method:POST];
    }
}

#pragma mark: - ConnectionManagerDelegate
-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
    
    // enable view, button and stop activityIndicatorLoading
    [self.view setUserInteractionEnabled:true];
    [self.activityIndicatorLoading stopAnimating];
    self.loginButton.enabled = true;
    
    // check return message
    if([[result valueForKey:R_KEY_MESSAGE] isEqualToString:LOGIN_SUCCESS]){
        
        //create NSUserDefaults object then add respone data to it
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // create tempDictionary for storing null value
        NSMutableDictionary * tempDictionary =[[NSMutableDictionary alloc]init];
        
        // Find null value
        for (NSString* key in [result valueForKey:R_KEY_DATA])
            if([[result valueForKey:R_KEY_DATA] objectForKey:key] == [ NSNull null ])
                 [tempDictionary setObject:@"N/A" forKey:key];
        
        // set null value to NSString N/A
        for(NSString* key in tempDictionary)
              [[result valueForKey:R_KEY_DATA] setObject:@"N/A" forKey:key];
        
         [[result valueForKey:R_KEY_DATA] setObject:@"default.jpg" forKey:@"image"];
        NSLog(@"%@", [result valueForKey:R_KEY_DATA] );
        // set userdefault
        [defaults setObject:[result valueForKey:R_KEY_DATA] forKey:USER_DEFAULT_KEY];
        
        //open home view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Sidebar" bundle:nil];
        
        // determine the initial view controller here and instantiate it with
        UIViewController *viewController =  [storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else{
        // display error message
        [SVProgressHUD showErrorWithStatus:LOGIN_UNSUCCESS];
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
