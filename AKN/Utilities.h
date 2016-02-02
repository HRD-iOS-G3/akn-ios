//
//  Utilities.h
//  AKN
//
//  Created by Ponnreay on 1/17/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utilities : NSObject

+(NSString*)timestamp2date:(NSString*)timestamp;
+(void)setGradientColor:(UIView *)control NSArrayColor:(NSArray *)arrayColor;
+(void)customizeNavigationBar:(UINavigationController *)view withTitle:(NSString *)title;

@end
