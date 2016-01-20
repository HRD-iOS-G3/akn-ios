//
//  UserProfileViewController.m
//  AKN
//
//  Created by Yin Kokpheng on 1/6/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "UserProfileViewController.h"
#import "SWRevealViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ConnectionManager.h"

@interface UserProfileViewController ()<ConnectionManagerDelegate>{
    NSUserDefaults *userDefault;
    NSMutableDictionary *user;
    ConnectionManager *manager ;
}


@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // change status color
    
    [self customizePageMenu];
 
    
    // border radius
    [self.updateButton.layer setCornerRadius:self.updateButton.bounds.size.height/2];
    self.updateButton.clipsToBounds = YES;
    
    [self.changePasswordButton.layer setCornerRadius:self.updateButton.bounds.size.height/2];
    self.changePasswordButton.clipsToBounds = YES;
    
    
    //Set GradienColor for control
    NSArray *gradientColor =[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00] CGColor], (id)[[UIColor colorWithRed:(140/225.0) green:(30/255.0) blue:(30/255.0) alpha:1.00] CGColor], nil];
    [self setGradientColor:self.updateButton NSArrayColor:gradientColor];
    [self setGradientColor:self.changePasswordButton NSArrayColor:gradientColor];
    [self setGradientColor:self.profileBackgroundImageView NSArrayColor:gradientColor];
    
    [self.profileImageView.layer setCornerRadius:self.profileImageView.bounds.size.height/2];
    self.profileImageView.clipsToBounds = YES;
    [self.profileImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.profileImageView.layer setBorderWidth: 2.0];
    
    //Set SWReveal
    [self.sidebarButton setTarget: self.revealViewController];
    [self.sidebarButton setAction: @selector( revealToggle: )];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];;

}

-(void)viewDidAppear:(BOOL)animated{
    userDefault = [NSUserDefaults standardUserDefaults];
    user = [[NSMutableDictionary alloc]initWithDictionary:[userDefault valueForKey:@"user"]];
    
    NSString *imageURL = [NSString stringWithFormat:@"http://hrdams.herokuapp.com/%@",[user valueForKey:@"photo"]];
    
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(concurrentQueue, ^{
        __block NSData *dataImage = nil;
        
        dispatch_sync(concurrentQueue, ^{
            NSURL *urlImage = [NSURL URLWithString:imageURL];
            dataImage = [NSData dataWithContentsOfURL:urlImage];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:dataImage];
            self.profileImageView.image = image;
            
        });
    });
    
    self.nameTextField.text = [user valueForKey:@"username"];
    
    self.emailTextField.text = [user valueForKey:@"email"];
}


#pragma mark - Keyboard Did Show and Hide

- (void)keyboardDidShow:(NSNotification *)sender {
    self.profileTableView.scrollEnabled = YES;
    [self.profileTableView setContentOffset:CGPointMake(0, self.profileTableView.bounds.size.height * 0.1) animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    self.profileTableView.scrollEnabled = NO;
}

#pragma mark - Navigation bar color

-(void)customizePageMenu{
    self.title = @"PROFILE";
    
    self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:193.0/255.0 green:0.0/255.0 blue:1.0/255.0 alpha:1.0];[UIColor redColor];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];

    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Arial-Bold" size:0.0]};
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateButtonAction:(id)sender {
     // dismiss keyboard
    [self dismissKeyboard];
    
    // Get value from text field
    NSString * username = self.nameTextField.text;
    NSString * email = self.emailTextField.text;
    
    // validate text field
    if ([username isEqualToString:@""]) {
        [self makeToast:@"Please complete username" duration:2];
    }else if ([email isEqualToString:@""]) {
        [self makeToast:@"Please complete email" duration:2];
    }else{
        
        [self.activityIndicatorLoading startAnimating];
        self.updateButton.enabled = false;
        
        //Create connection object
        manager = [[ConnectionManager alloc] init];
        
        //Set delegate
        manager.delegate = self;
        
        // request dictionary
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:self.nameTextField.text forKey:@"id"];
        [dictionary setObject:self.emailTextField.text forKey:@"username"];
        
        
        //Send data to server and insert it
        [manager requestDataWithURL:dictionary withKey:@"/api/user/update" method:@"PUT"];
    
    }
    
}

#pragma mark: - ConnectionManagerDelegate

-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
    
    [self.activityIndicatorLoading stopAnimating];
    self.updateButton.enabled = true;
    
    if([[result valueForKey:@"MESSAGE"] containsString:@"SUCCESS"]){
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:[userDefault objectForKey:@"user"], nil];
        NSLog(@"%@", data);
        
        
       // NSUserDefaults object change value
        [[userDefault objectForKey:@"user"] setValue:[NSString stringWithFormat:@"%@",self.emailTextField.text ] forKey:@"username"];
           NSLog(@"%@", [[userDefault objectForKey:@"user"] valueForKey:@"username"]);
        //open home view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Sidebar" bundle:nil];
        
       //  determine the initial view controller here and instantiate it with
        UIViewController *viewController =  [storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else{
        NSLog(@"Fail");
    }
     
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)makeToast:(NSString *)msg duration:(NSTimeInterval)duration{
    self.errorLabel.text=  msg ;
    self.errorLabel.hidden = false;
  
    [UIView animateWithDuration:duration animations:^(void){
        self.errorLabel.alpha = 0;
        self.errorLabel.alpha = 1;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:1.0 animations:^(void){
            self.errorLabel.alpha = 1;
            self.errorLabel.alpha = 0;
            
        }];
    }];
}

-(void)dismissKeyboard{
    [self.view endEditing:YES];
}

@end
