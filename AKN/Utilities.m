//
//  Utilities.m
//  AKN
//
//  Created by Ponnreay on 1/17/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities
+(NSString*)timestamp2date:(NSString*)timestamp{
	NSString * timeStampString =timestamp;
	//[timeStampString stringByAppendingString:@"000"];   //convert to ms
	NSTimeInterval _interval=[timeStampString doubleValue];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval/1000];
	NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
	[_formatter setDateFormat:@"dd-MM-yyyy"];
	return [_formatter stringFromDate:date];
}

#pragma mark: -  Gradien Color
+(void)setGradientColor:(UIView *)control NSArrayColor:(NSArray *)arrayColor{
    //Set GradienColor for control
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = control.bounds;
    gradient.colors = arrayColor;
    
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(0, 1);
    [control.layer insertSublayer:gradient atIndex:0];
}

#pragma mark - Navigation bar
+(void)customizeNavigationBar:(UINavigationController *)navigationController withTitle:(NSString *)title{
    navigationController.title = title;
    
    // change status color
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    navigationController.navigationBar.barTintColor=[UIColor colorWithRed:193.0/255.0 green:0.0/255.0 blue:1.0/255.0 alpha:1.0];[UIColor redColor];
    navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Arial-Bold" size:0.0]};
}

@end
