//
//  HomeViewCell.h
//  PagingMenu
//
//  Created by Po Dara on 1/6/16.
//  Copyright © 2016 Chum Ratha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *newsImage;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImage;
@property (weak, nonatomic) IBOutlet UILabel *newsTitle;
@property (weak, nonatomic) IBOutlet UILabel *newsDate;
@property (weak, nonatomic) IBOutlet UILabel *newsView;
@property (weak, nonatomic) IBOutlet UIView *viewCell;

@end
