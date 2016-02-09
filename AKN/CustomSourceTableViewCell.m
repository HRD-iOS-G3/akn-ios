//
//  CustomSourceTableViewCell.m
//  AKN
//
//  Created by Yin Kokpheng on 2/9/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "CustomSourceTableViewCell.h"

@implementation CustomSourceTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, 40, 40);
}

@end
