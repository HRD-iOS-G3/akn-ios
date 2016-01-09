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

@interface SidebarMenuViewController ()<UITableViewDelegate, UITableViewDataSource>{
    NSArray *menuItems, *menuTitle;
}

@end

@implementation SidebarMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sidebarMenuTableView.delegate=self;
    self.sidebarMenuTableView.dataSource=self;
    
    menuItems = @[@"home", @"saveList", @"setting", @"logout", @"aboutUs"];
    menuTitle = @[@"Home", @"Save List", @"Setting", @"Logout", @"About us"];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
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

    cell.textLabel.text = [menuTitle objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    
      // This is how you change the background color
      cell.selectionStyle = UITableViewCellSelectionStyleDefault;
      UIView *bgColorView = [[UIView alloc] init];
      bgColorView.backgroundColor = [UIColor colorWithRed:(55/255.0) green:(109/255.0) blue:(103/255.0) alpha:1] ;
      [cell setSelectedBackgroundView:bgColorView];
      
    return cell;
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
    if ([segue.identifier isEqualToString:@"showSetting"]) {
//        UINavigationController *navController = segue.destinationViewController;
//        UserProfileViewController *UserProfileController = [navController childViewControllers].firstObject;
//        NSString *photoFilename = [NSString stringWithFormat:@"%@_photo", [menuItems objectAtIndex:indexPath.row]];
//        UserProfileController.photoFilename = photoFilename;
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

@end
