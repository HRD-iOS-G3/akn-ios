//
//  HomeViewCell.m
//  PagingMenu
//
//  Created by Po Dara on 1/6/16.
//  Copyright © 2016 Chum Ratha. All rights reserved.
//

#import "HomeViewCell.h"

@interface HomeViewCell()

@property (weak, nonatomic) IBOutlet UIButton *buttonSave;

@end

@implementation HomeViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)actionSave:(id)sender {
	[_buttonSave setImage:[UIImage imageNamed:@"save-gray"] forState:UIControlStateNormal];
}

@end
