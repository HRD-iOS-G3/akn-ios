//
//  DetailNewsTableViewController.h
//  Detail Article
//
//  Created by Ponnreay on 1/11/16.
//  Copyright © 2016 ponnreay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailNewsTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageViewNews;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;


@end
