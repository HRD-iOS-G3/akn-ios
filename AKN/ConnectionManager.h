//
//  ConnectionManager.h
//  AKN
//
//  Created by Ponnreay on 1/17/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol  ConnectionManagerDelegate;
@interface ConnectionManager : NSObject

-(void)requestDataWithURL:(NSURL *)URL;

@property (nonatomic, weak) id<ConnectionManagerDelegate>delegate;
@end


@protocol ConnectionManagerDelegate <NSObject>
@optional
//Get Result Method
-(void)connectionManagerDidReturnResult:(NSArray *) result FromURL:(NSURL *)URL;
@end