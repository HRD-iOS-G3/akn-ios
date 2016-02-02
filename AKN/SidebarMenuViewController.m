//
//  SidebarMenuViewController.m
//  AKN
//
//  Created by Kokpheng on 1/4/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "SidebarMenuViewController.h"
#import "SWRevealViewController.h"
#import "UserProfileViewController.h"
#import "ConnectionManager.h"
#import "UIImageView+WebCache.h"


@interface SidebarMenuViewController ()<UITableViewDelegate, UITableViewDataSource,ConnectionManagerDelegate>{
    NSArray *menuItems, *menuTitle;
    NSUserDefaults *userDefault;
    NSMutableDictionary *user;
    ConnectionManager *manager;
}

@end

@implementation SidebarMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sidebarMenuTableView.delegate=self;
    self.sidebarMenuTableView.dataSource=self;
    
    
    menuItems = @[@"home", @"saveList", @"setting", @"logout", @"aboutUs"];
    menuTitle = @[@"Home", @"Save List", @"Setting", @"Logout", @"About us"];
    
    
    //Set color for button login
    CAGradientLayer *gradient1 = [CAGradientLayer layer];
    gradient1.frame = self.profileBackgroundView.bounds;
    gradient1.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00] CGColor], (id)[[UIColor colorWithRed:(160/225.0) green:(30/255.0) blue:(30/255.0) alpha:1.00] CGColor], nil];
    
    gradient1.startPoint = CGPointMake(0, 0);
    gradient1.endPoint = CGPointMake(0, 1);
    [self.profileBackgroundView.layer insertSublayer:gradient1 atIndex:0];
    
    [self.profileImageView.layer setCornerRadius:self.profileImageView.bounds.size.height/2];
    self.profileImageView.clipsToBounds = YES;
    [self.profileImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.profileImageView.layer setBorderWidth: 2.0];
    
    NSUserDefaults *userDefaul = [NSUserDefaults standardUserDefaults];
    self.nameLabel.text=[[userDefaul objectForKey:@"user"]valueForKey:@"username"];
    self.emailLabel.text=[[userDefaul objectForKey:@"user"]valueForKey:@"email"];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:NO];
    [self.revealViewController.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //set image
    userDefault = [NSUserDefaults standardUserDefaults];
    user = [[NSMutableDictionary alloc]initWithDictionary:[userDefault valueForKey:@"user"]];
    
    self.profileImageView.image = [UIImage imageNamed:@"profile.png"];
    [self.profileImageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://akn.khmeracademy.org/resources/images/user/%@",[user valueForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"profile.png"] options:SDWebImageRefreshCached progress:nil completed:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.imageView.image = [UIImage imageNamed:[menuItems objectAtIndex:indexPath.row]];
    cell.imageView.highlightedImage = [UIImage imageNamed:  [NSString stringWithFormat:@"%@White", [menuItems objectAtIndex:indexPath.row]]];
    
    cell.textLabel.text = [menuTitle objectAtIndex:indexPath.row];
    
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    
    cell.tag = indexPath.row;
    
    // This is how you change the background color
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(160/225.0) green:(30/255.0) blue:(30/255.0) alpha:1.00];
    [cell setSelectedBackgroundView:bgColorView];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 3)
    {
        NSUserDefaults *userDefaul = [NSUserDefaults standardUserDefaults];
        [userDefaul removeObjectForKey:@"user"];
        [self.revealViewController performSegueWithIdentifier:SWSegueGuestIdentifier sender:nil];
    }
}


// set cell height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.sidebarMenuTableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
    
    // Set the photo if it navigates to the PhotoView
    if ([segue.identifier isEqualToString:@"showHome"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NSNotificationCenterHomeClick" object:nil];
    }
    else if ([segue.identifier isEqualToString:@"showSetting"]) {
        //        UINavigationController *navController = segue.destinationViewController;
        //        UserProfileViewController *UserProfileController = [navController childViewControllers].firstObject;
        //        NSString *photoFilename = [NSString stringWithFormat:@"%@_photo", [menuItems objectAtIndex:indexPath.row]];
        //        UserProfileController.photoFilename = photoFilename;
    }
}

@end
