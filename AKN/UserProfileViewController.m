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
    [Utilities setBorderRadius:self.updateButton];
    [Utilities setBorderRadius:self.changePasswordButton];
    
    //Set GradienColor for control
    NSArray *gradientColor = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00] CGColor], (id)[[UIColor colorWithRed:(140/225.0) green:(30/255.0) blue:(30/255.0) alpha:1.00] CGColor], nil];
    
    [Utilities setGradientColor:self.updateButton NSArrayColor:gradientColor];
    [Utilities setGradientColor:self.changePasswordButton NSArrayColor:gradientColor];
    [Utilities setGradientColor:self.profileBackgroundImageView NSArrayColor:gradientColor];
    
    [Utilities setBorderRadius:self.profileImageView];
    [self.profileImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.profileImageView.layer setBorderWidth: 2.0];
    
    //Set SWReveal
    [Utilities setSWRevealSidebarButton:self.sidebarButton :self.revealViewController :self.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];;
        
    // change background color
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00]];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:(241/255.0) green:(241/255.0) blue:(241/255.0) alpha:1.00]];
    
    userDefault = [NSUserDefaults standardUserDefaults];
    user = [[NSMutableDictionary alloc]initWithDictionary:[userDefault valueForKey:USER_DEFAULT_KEY]];
    
    [self.profileImageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@", @"http://api.khmeracademy.org", IMAGE_USER_URL,[user valueForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"profile.png"] options:SDWebImageRefreshCached progress:nil completed:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    
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
        
        // start animating when choose image
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD show];
        
        // request dictionary
        NSDictionary * param = @{
                                 @"username":self.nameTextField.text,
                                 @"gender": @"ប្រុស",
                                 @"dateOfBirth": @"2016-02-09T02:03:51.883Z",
                                 @"phoneNumber": @"012345678",
                                 @"userImageUrl": [[userDefault objectForKey:USER_DEFAULT_KEY] valueForKey:@"image"],
                                 @"universityId": @"MQ==",
                                 @"departmentId": @"MQ==",
                                 @"userId":[[userDefault objectForKey:USER_DEFAULT_KEY] valueForKey:@"id"]};
        
         NSLog(@"param %@", param);
        //Send data to server and insert it
        [manager requestDataWithURL:UPDATE_USER data:param method:PUT];        
    }
}

#pragma mark: - ConnectionManagerDelegate
-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
    NSLog(@"%@", result);
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    
    // check return message
    if([[result valueForKey:R_KEY_MESSAGE] containsString:UPDATE_USER_SUCCESS]){
        
        // init dictionary for storing temp value of user defualt
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        for (NSString* key in [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY]) {
            id value = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY] objectForKey:key];
            [dictionary setObject:value forKey:key];
        }
        
        // change value of temp dictionary
        [dictionary setObject:self.nameTextField.text forKey:@"username"];
        
        // set new value for user default
        [userDefault setObject:dictionary forKey:USER_DEFAULT_KEY];
        [SVProgressHUD showSuccessWithStatus:UPDATE_USER_SUCCESS];
      
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
    
    // upload new image for first image of user
    if([[[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY] valueForKey:@"image"] isEqualToString:@"avatar.jpg"]){
        [manager uploadUserImageWithImage:chosenImage urlPath:[NSString stringWithFormat:@"%@?url=%@", UPLOAD_USER_PROFILE_IMAGER, @"user"] fileName:@"hrd.jpg"];
        
        // update image of current user
    }else{
        [manager uploadUserImageWithImage:chosenImage urlPath:[NSString stringWithFormat:@"%@?url=%@&filename=%@", EDIT_USER_PROFILE_IMAGER, @"user",[[[NSUserDefaults standardUserDefaults]objectForKey:USER_DEFAULT_KEY] valueForKey:@"image"]] fileName:[[[NSUserDefaults standardUserDefaults]objectForKey:USER_DEFAULT_KEY] valueForKey:@"image"]];
    }
   
    self.profileImageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    // start animating when choose image
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
   
}

-(void)responseImage:(NSDictionary *)dataDictionary{
    
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    NSLog(@"--------%@", dataDictionary);
    
    // check respone data
    if([[dataDictionary valueForKey:R_KEY_MESSAGE] containsString:UPLOAD_IMAGE_SUCCESS]){
        
        // init dictionary for storing temp value of user defualt
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        for (NSString* key in [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY]) {
            id value = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY] objectForKey:key];
            [dictionary setObject:value forKey:key];
        }
     
        // change value of temp dictionary
        [dictionary setObject:[[dataDictionary valueForKey:@"IMG"] substringFromIndex:28] forKey:@"image"];

        // set new value for user default
        [userDefault setObject:dictionary forKey:USER_DEFAULT_KEY];
        
        
        [self updateButtonAction:nil];
        
        // clear cache
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
    }
    else if ([[dataDictionary valueForKey:R_KEY_MESSAGE] containsString:UPDATE_IMAGE_SUCCESS]){
        // clear cache
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        
        [SVProgressHUD showSuccessWithStatus:UPDATE_IMAGE_SUCCESS];
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
