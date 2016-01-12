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
#import "BButton.h"

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
    
    //Set color for button login
    CAGradientLayer *gradient1 = [CAGradientLayer layer];
    gradient1.frame = self.profileBackgroundView.bounds;
    gradient1.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:(200/255.0) green:(38/255.0) blue:(38/255.0) alpha:1.00] CGColor], (id)[[UIColor colorWithRed:(160/225.0) green:(30/255.0) blue:(30/255.0) alpha:1.00] CGColor], nil];
    
    gradient1.startPoint = CGPointMake(0, 0);
    gradient1.endPoint = CGPointMake(0, 1);
    [self.profileBackgroundView.layer insertSublayer:gradient1 atIndex:0];
}

- (void)buttonPressed:(UIButton *)sender
{
    NSLog(@"Good jorb, you pressed a button: %@", sender.titleLabel.text);
    
}

- (NSString *)titleForType:(BButtonType)type
{
    switch (type) {
        case BButtonTypePrimary:
            return @"Primary";
            
        case BButtonTypeInfo:
            return @"Info";
            
        case BButtonTypeSuccess:
            return @"Success";
            
        case BButtonTypeWarning:
            return @"Warning";
            
        case BButtonTypeDanger:
            return @"Danger";
            
        case BButtonTypeInverse:
            return @"Inverse";
            
        case BButtonTypeTwitter:
            return @"Twitter";
            
        case BButtonTypeFacebook:
            return @"Facebook";
            
        case BButtonTypePurple:
            return @"Purple";
            
        case BButtonTypeGray:
            return @"Gray";
            
        case BButtonTypeDefault:
        default:
            return @"Default";
    }
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:NO];
    [self.revealViewController.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
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
    
      // This is how you change the background color
      cell.selectionStyle = UITableViewCellSelectionStyleDefault;
      UIView *bgColorView = [[UIView alloc] init];

      [cell setSelectedBackgroundView:bgColorView];
    
   [[BButton appearance] setButtonCornerRadius:@0.0f];
    
    BButtonType type = 0;

    CGRect frame = CGRectMake(0.0f, 0.0f, cell.frame.size.width, cell.frame.size.height);

   BButton *btn = [[BButton alloc] initWithFrame:frame type:type style:BButtonStyleBootstrapV3];

     [btn setTitle:[NSString stringWithFormat:@" %@",[menuTitle objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
    
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:(160/225.0) green:(30/255.0) blue:(30/255.0) alpha:1.00] forState:UIControlStateHighlighted];
     [btn addAwesomeIcon:FAIconFacebook beforeTitle:YES];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 25, 0, 0);
    
    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
     btn.enabled = YES;
    
     [cell addSubview:btn];
    
    return cell;
}


// set cell height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
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
