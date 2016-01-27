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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // change status color
    
    [self customizePageMenu];
    
    // border radius
    [self.loginButton.layer setCornerRadius:self.loginButton.bounds.size.height/2];
    self.loginButton.clipsToBounds = YES;
    
    
    //Set GradienColor for control
    NSArray *gradientColor  =[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00] CGColor], (id)[[UIColor colorWithRed:(140/225.0) green:(30/255.0) blue:(30/255.0) alpha:1.00] CGColor], nil];
    [self setGradientColor:self.loginButton NSArrayColor:gradientColor];
    
    
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
    
    
    // change background color
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00]];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:(241/255.0) green:(241/255.0) blue:(241/255.0) alpha:1.00]];
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

-(void)setGradientColor:(UIView *)control NSArrayColor:(NSArray *)arrayColor{
    //Set GradienColor for control
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = control.bounds;
    gradient.colors = arrayColor;
    
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(0, 1);
    [control.layer insertSublayer:gradient atIndex:0];
}

#pragma mark: - Login
- (IBAction)actionLogin:(id)sender {
    // dismiss keyboard
    [self dismissKeyboard];
    
    // Get value from text field
    NSString * username = self.usernameTextField.text;
    NSString * password = self.passwordTextField.text;
    
    // validate text field
    if ([username isEqualToString:@""]) {
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
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:username forKey:@"email"];
        [dictionary setObject:password forKey:@"password"];
        
        // send data to server
        [manager requestDataWithURL:dictionary withKey:@"/api/user/login" method:@"POST"];
        
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark: - ConnectionManagerDelegate

-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
      [self.view setUserInteractionEnabled:true];
    [self.activityIndicatorLoading stopAnimating];
     self.loginButton.enabled = true;
    
    if([[result valueForKey:@"MESSAGE"] isEqualToString:@"LOGIN SUCCESS"]){
        //create NSUserDefaults object then add respone data to it
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [[result valueForKey:@"DATA"] setObject:@"na" forKey:@"roles"];
        [[result valueForKey:@"DATA"] setObject:@"na" forKey:@"authorities"];
        [[result valueForKey:@"DATA"] setObject:@"na" forKey:@"password"];
        
        [defaults setObject:[result valueForKey:@"DATA"] forKey:@"user"];
        
        //open home view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Sidebar" bundle:nil];
        
        // determine the initial view controller here and instantiate it with
        UIViewController *viewController =  [storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else{
        [SVProgressHUD showErrorWithStatus:[result valueForKey:@"MESSAGE"]];
    }
}


-(void)dismissKeyboard{
    [self.view endEditing:YES];
}

@end
