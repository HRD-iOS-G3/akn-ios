//
//  SaveListTableViewController.h
//  AKN
//
//  Created by Yin Kokpheng on 1/18/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaveListTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

+(SaveListTableViewController *)getInstance;
@end
