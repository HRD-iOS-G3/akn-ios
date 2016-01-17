//
//  NewsByCategoryTableViewController.h
//  AKN
//
//  Created by Korea Software HRD Center on 1/11/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsByCategoryTableViewController : UITableViewController

@property (strong, nonatomic) NSString *pageTitle;
@property (strong, nonatomic) NSDictionary *categoryOrSource;

@end
