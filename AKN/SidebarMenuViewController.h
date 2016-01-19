//
//  SidebarMenuViewController.h
//  AKN
//
//  Created by Kokpheng on 1/4/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SidebarMenuViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *sidebarMenuTableView;
@property (weak, nonatomic) IBOutlet UIView *profileBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;


@end
