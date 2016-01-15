//
//  MainViewController.h
//  AKN
//
//  Created by Kokpheng on 1/3/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;

+(MainViewController *)getInstance;
@end
