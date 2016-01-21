//
//  ChangePasswordTableViewController.m
//  AKN
//
//  Created by Yin Kokpheng on 1/6/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "ChangePasswordTableViewController.h"
#import "ConnectionManager.h"

@interface ChangePasswordTableViewController ()<ConnectionManagerDelegate>{
    NSUserDefaults *userDefault;
    NSMutableDictionary *user;
    ConnectionManager *manager ;
}



@end

@implementation ChangePasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizePageMenu];
    
    [self.changePasswordButton.layer setCornerRadius:self.changePasswordButton.bounds.size.height/2];
    
    self.changePasswordButton.clipsToBounds = YES;
    
    
    //Set GradienColor for control
    NSArray *gradientColor =[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00] CGColor], (id)[[UIColor colorWithRed:(140/225.0) green:(30/255.0) blue:(30/255.0) alpha:1.00] CGColor], nil];
    [self setGradientColor:self.changePasswordButton NSArrayColor:gradientColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];;

}

#pragma mark - Navigation bar color

-(void)customizePageMenu{
    self.title = @"Change Password";
    
    self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:193.0/255.0 green:0.0/255.0 blue:1.0/255.0 alpha:1.0];[UIColor redColor];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Arial-Bold" size:0.0]};
}

#pragma mark - Keyboard Did Show and Hide

- (void)keyboardDidShow:(NSNotification *)sender {
    self.changePasswordTableView.scrollEnabled = YES;
}

- (void)keyboardWillHide:(NSNotification *)sender {
    self.changePasswordTableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changePasswordButtonAction:(id)sender {
    // dismiss keyboard
    [self dismissKeyboard];
    
    // Get value from text field
    
    NSString * oldPassword = self.oldPasswordTextField.text;
    NSString * newPassword = self.nnewPasworldTextField.text;
     NSString * comfirmPassword = self.comfirmPasswordTextField.text;
    
    // validate text field
    if ([oldPassword isEqualToString:@""]) {
        [self makeToast:@"Please complete old password" duration:2];
    }else if ([newPassword isEqualToString:@""]) {
        [self makeToast:@"Please complete new password" duration:2];
    }else if ([comfirmPassword isEqualToString:@""]) {
        [self makeToast:@"Please complete comfirm password" duration:2];
    }else if (![newPassword isEqualToString:comfirmPassword]) {
        [self makeToast:@"Your new password and comfirm password is not the same" duration:2];
    }else{
        userDefault = [[NSUserDefaults standardUserDefaults] init];
        
        [self.activityIndicatorLoading startAnimating];
        self.changePasswordButton.enabled = false;
        
        //Create connection object
        manager = [[ConnectionManager alloc] init];
        
        //Set delegate
        manager.delegate = self;
        
        // request dictionary
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:[[userDefault objectForKey:@"user"] valueForKey:@"id"] forKey:@"id"];
        
        [dictionary setObject:newPassword forKey:@"newpass"];
        [dictionary setObject:oldPassword forKey:@"oldpass"];
        NSLog(@"%@", dictionary);
        
        //Send data to server and insert it
        [manager requestDataWithURL:dictionary withKey:@"/api/user/changepwd" method:@"PUT"];
    
    }
}

#pragma mark: - ConnectionManagerDelegate

-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
    
    [self.activityIndicatorLoading stopAnimating];
    self.changePasswordButton.enabled = true;
    
    if([[result valueForKey:@"MESSAGE"] containsString:@"CHANGED"]){
        //open home view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Sidebar" bundle:nil];
        
        //  determine the initial view controller here and instantiate it with
        UIViewController *viewController =  [storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else{
       [self makeToast:@"You old password is incorrect" duration:2];
    }
    
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

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
