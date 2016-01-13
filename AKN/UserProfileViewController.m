//
//  UserProfileViewController.m
//  AKN
//
//  Created by Yin Kokpheng on 1/6/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "UserProfileViewController.h"
#import "SWRevealViewController.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizePageMenu];
    
    // border radius
    [self.updateButton.layer setCornerRadius:self.updateButton.bounds.size.height/2];
    self.updateButton.clipsToBounds = YES;
    
    [self.changePasswordButton.layer setCornerRadius:self.updateButton.bounds.size.height/2];
    self.changePasswordButton.clipsToBounds = YES;
    
    
       //Set GradienColor for control
    NSArray *gradientColor =[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00] CGColor], (id)[[UIColor colorWithRed:(160/225.0) green:(30/255.0) blue:(30/255.0) alpha:1.00] CGColor], nil];
    [self setGradientColor:self.updateButton NSArrayColor:gradientColor];
    [self setGradientColor:self.changePasswordButton NSArrayColor:gradientColor];
    [self setGradientColor:self.profileBackgroundImageView NSArrayColor:gradientColor];
    
    //Set SWReveal
    [self.sidebarButton setTarget: self.revealViewController];
    [self.sidebarButton setAction: @selector( revealToggle: )];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
