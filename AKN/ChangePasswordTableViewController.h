//
//  ChangePasswordTableViewController.h
//  AKN
//
//  Created by Yin Kokpheng on 1/6/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;
@property (strong, nonatomic) IBOutlet UITableView *changePasswordTableView;
@property (weak, nonatomic) IBOutlet UITextField *nnewPasworldTextField;

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *comfirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end
