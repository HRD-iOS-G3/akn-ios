//
//  UserProfileViewController.h
//  AKN
//
//  Created by Yin Kokpheng on 1/6/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *profileTableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorLoading;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (weak, nonatomic) IBOutlet UIButton *changePictureButton;

@end
