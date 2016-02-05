//
//  ChangePasswordTableViewController.m
//  AKN
//
//  Created by Yin Kokpheng on 1/6/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "ChangePasswordTableViewController.h"
#import "ConnectionManager.h"
#import "SVProgressHUD.h"
#import "Utilities.h"

@interface ChangePasswordTableViewController ()<ConnectionManagerDelegate>{
    NSUserDefaults *userDefault;
    NSMutableDictionary *user;
    ConnectionManager *manager ;
}



@end

@implementation ChangePasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // custom navigation bar color
    [Utilities customizeNavigationBar:self.navigationController withTitle:@"CHANGE PASSWORD"];
    
    [Utilities setBorderRadius:self.changePasswordButton];
    
    //Set GradienColor for control
    NSArray *gradientColor =[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00] CGColor], (id)[[UIColor colorWithRed:(140/225.0) green:(30/255.0) blue:(30/255.0) alpha:1.00] CGColor], nil];
    [self setGradientColor:self.changePasswordButton NSArrayColor:gradientColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];;

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
        [SVProgressHUD showErrorWithStatus:@"Please complete old password"];
    }else if ([newPassword isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"Please complete new password"];
    }else if ([comfirmPassword isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"Please complete comfirm password"];
    }else if (![newPassword isEqualToString:comfirmPassword]) {
        [SVProgressHUD showErrorWithStatus:@"Your new password and comfirm password is not the same"];
    }else{
        userDefault = [[NSUserDefaults standardUserDefaults] init];
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD show];
        
        //Create connection object
        manager = [[ConnectionManager alloc] init];
        
        //Set delegate
        manager.delegate = self;
        
        // request dictionary
        NSDictionary * param = @{@"id":[[userDefault objectForKey:USER_DEFAULT_KEY] valueForKey:@"id"],
                                 @"newpass":newPassword,
                                 @"oldpass":oldPassword};
        
        //Send data to server and insert it
        [manager requestDataWithURL:CHANGE_USER_PASSWORD_URL data:param method:PUT];
    }
}

#pragma mark: - ConnectionManagerDelegate
-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    
    if([[result valueForKey:R_KEY_MESSAGE] containsString:CHANGE_USER_PASSWORD_SUCCESS]){
         [SVProgressHUD showSuccessWithStatus:CHANGE_USER_PASSWORD_SUCCESS];
        // Delay 2 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
    else{
         [SVProgressHUD showErrorWithStatus:CHANGE_USER_PASSWORD_UNSUCCESS];
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
