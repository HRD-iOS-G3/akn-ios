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
#import "Utilities.h"

@interface UserProfileViewController ()<ConnectionManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    NSUserDefaults *userDefault;
    NSMutableDictionary *user;
    ConnectionManager *manager ;
}


@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utilities customizeNavigationBar:self.navigationController withTitle:@"PROFILE"];
 
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
    
    [Utilities setGradientColor:self.updateButton NSArrayColor:gradientColor];
    [Utilities setGradientColor:self.changePasswordButton NSArrayColor:gradientColor];
    [Utilities setGradientColor:self.profileBackgroundImageView NSArrayColor:gradientColor];
    
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
    user = [[NSMutableDictionary alloc]initWithDictionary:[userDefault valueForKey:USER_DEFAULT_KEY]];
    
    [self.profileImageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/resources/images/user/%@", manager.basedUrl, [user valueForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"profile.png"] options:SDWebImageRefreshCached progress:nil completed:nil];
    
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
        [dictionary setObject:[[userDefault objectForKey:USER_DEFAULT_KEY] valueForKey:@"id"] forKey:@"id"];
        
        [dictionary setObject:self.nameTextField.text forKey:@"username"];
        
        //Send data to server and insert it
        [manager requestDataWithURL:dictionary withKey:UPDATE_USER method:PUT];
        
    }
    
}

#pragma mark: - ConnectionManagerDelegate

-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
    [self.view setUserInteractionEnabled:true];
    [self.activityIndicatorLoading stopAnimating];
    self.updateButton.enabled = true;
    
    if([[result valueForKey:R_KEY_MESSAGE] containsString:UPDATE_USER_SUCCESS]){
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        for (NSString* key in [[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
            id value = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:key];
            [dictionary setObject:value forKey:key];
        }
        
        // change
        [dictionary setObject:self.nameTextField.text forKey:@"username"];
        [dictionary setObject:self.emailTextField.text forKey:@"email"];
        
        [userDefault setObject:dictionary forKey:USER_DEFAULT_KEY];
        
        //open home view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Sidebar" bundle:nil];
        
       //  determine the initial view controller here and instantiate it with
        UIViewController *viewController =  [storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else{
       [SVProgressHUD showErrorWithStatus:[result valueForKey:UPDATE_USER_SUCCESS]];
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
   
    [manager uploadWithImage:chosenImage urlPath:[NSString stringWithFormat:@"%@?id=%@", EDIT_UPLOAD_IMAGE,  [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY] valueForKey:@"id"]] fileName:@"hrd.jpg"];
     self.profileImageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    // start animating when choose image
    [self.activityIndicatorLoading startAnimating];
   
    self.updateButton.enabled = false;
    
    
}

-(void)responseImage:(NSDictionary *)dataDictionary{
    [self.activityIndicatorLoading stopAnimating];
    self.updateButton.enabled = true;
    NSLog(@"--------%@", dataDictionary);
    if([[dataDictionary valueForKey:R_KEY_MESSAGE] containsString:UPLOAD_IMAGE_SUCCESS]){
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        for (NSString* key in [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY]) {
            id value = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY] objectForKey:key];
            [dictionary setObject:value forKey:key];
        }
        // change
        [dictionary setObject:[[dataDictionary valueForKey:@"IMAGE"] substringFromIndex:12] forKey:@"image"];
        
        [userDefault setObject:dictionary forKey:USER_DEFAULT_KEY];
        NSLog(@"=========%@", [userDefault objectForKey:USER_DEFAULT_KEY]);
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        
        //open home view
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Sidebar" bundle:nil];
        
          //determine the initial view controller here and instantiate it with
          UIViewController *viewController =  [storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
         [self presentViewController:viewController animated:YES completion:nil];

    }
    else{
       [SVProgressHUD showErrorWithStatus:[[dataDictionary valueForKey:R_KEY_MESSAGE] valueForKey:UPLOAD_IMAGE_UNSECCESS]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
}

-(void)dismissKeyboard{
    [self.view endEditing:YES];
}

@end
