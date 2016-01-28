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
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"

@interface UserProfileViewController ()<ConnectionManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
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
 
    
    //Create connection object
    manager = [[ConnectionManager alloc] init];
    
    //Set delegate
    manager.delegate = self;
    
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
    
    
    // change background color
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00]];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:(241/255.0) green:(241/255.0) blue:(241/255.0) alpha:1.00]];

}

-(void)viewDidAppear:(BOOL)animated{
    userDefault = [NSUserDefaults standardUserDefaults];
    user = [[NSMutableDictionary alloc]initWithDictionary:[userDefault valueForKey:@"user"]];
    
    
    self.profileImageView.image = [UIImage imageNamed:@"profile.png"];
    [self.profileImageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://akn.khmeracademy.org/resources/images/%@",[user valueForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"profile.png"] options:SDWebImageRefreshCached progress:nil completed:nil];
    
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
         [SVProgressHUD showErrorWithStatus:@"Please complete username"];
    }else if ([email isEqualToString:@""]) {
         [SVProgressHUD showErrorWithStatus:@"Please complete email"];
    }else{
        
        [self.view setUserInteractionEnabled:false];
        [self.activityIndicatorLoading startAnimating];
        self.updateButton.enabled = false;
        
        // request dictionary
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:[[userDefault objectForKey:@"user"] valueForKey:@"id"] forKey:@"id"];
        
        [dictionary setObject:self.nameTextField.text forKey:@"username"];
     //   [dictionary setObject:self.emailTextField.text forKey:@"email"];
        
        
        //Send data to server and insert it
        [manager requestDataWithURL:dictionary withKey:@"/api/user/update" method:@"PUT"];
        
    }
    
}

#pragma mark: - ConnectionManagerDelegate

-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
    [self.view setUserInteractionEnabled:true];
    [self.activityIndicatorLoading stopAnimating];
    self.updateButton.enabled = true;
    
    if([[result valueForKey:@"MESSAGE"] containsString:@"SUCCESS"]){
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        for (NSString* key in [[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
            id value = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:key];
            [dictionary setObject:value forKey:key];
        }
        // change
        [dictionary setObject:self.nameTextField.text forKey:@"username"];
        [dictionary setObject:self.emailTextField.text forKey:@"email"];
        
        [userDefault setObject:dictionary forKey:@"user"];
        
        //open home view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Sidebar" bundle:nil];
        
       //  determine the initial view controller here and instantiate it with
        UIViewController *viewController =  [storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else{
       [SVProgressHUD showErrorWithStatus:[result valueForKey:@"MESSAGE"]];
    }
    
}

#pragma mark - change profile image
- (IBAction)changePictureButtonAction:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate =self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profileImageView.image = chosenImage;
    [manager uploadImage:chosenImage urlPath:[NSString stringWithFormat:@"%@?id=%@", @"/api/user/editupload",  [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] valueForKey:@"id"]] fileName:@"hrd.jpg"];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    // start animating when choose image
    [self.activityIndicatorLoading startAnimating];
   
 //   self.doneButton.enabled = false;
    self.updateButton.enabled = false;
    
    
}

-(void)responseImage:(NSDictionary *)dataDictionary{
    [self.activityIndicatorLoading stopAnimating];
    self.updateButton.enabled = true;
    NSLog(@"--------%@", dataDictionary);
    if([[dataDictionary valueForKey:@"MESSAGE"] containsString:@"SUCCESS"]){
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        for (NSString* key in [[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
            id value = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:key];
            [dictionary setObject:value forKey:key];
        }
        // change
        [dictionary setObject:[[dataDictionary valueForKey:@"IMAGE"] substringFromIndex:8] forKey:@"image"];
        
        [userDefault setObject:dictionary forKey:@"user"];
        NSLog(@"=========%@", [userDefault objectForKey:@"user"]);
        
        //open home view
       // UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Sidebar" bundle:nil];
        
        //  determine the initial view controller here and instantiate it with
      //  UIViewController *viewController =  [storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
       // [self presentViewController:viewController animated:YES completion:nil];
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


-(void)dismissKeyboard{
    [self.view endEditing:YES];
}

@end
