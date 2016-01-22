//
//  ConnectionManager.h
//  AKN
//
//  Created by Ponnreay on 1/17/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol  ConnectionManagerDelegate;
@interface ConnectionManager : NSObject

//Request Method
-(void)requestDataWithURL:(NSDictionary *)reqDictionary withKey:(NSString *)key method:(NSString *)method;
-(void)requestDataWithURL:(NSURL *)URL;

-(void)uploadImage:(UIImage *)image urlPath:(NSString *)path fileName:(NSString *)name;

@property (nonatomic, weak) id<ConnectionManagerDelegate>delegate;
@end


@protocol ConnectionManagerDelegate <NSObject>
@optional
//Get Result Method
-(void)connectionManagerDidReturnResult:(NSDictionary *) result;
-(void)connectionManagerDidReturnResult:(NSArray *) result FromURL:(NSURL *)URL;
-(void)responseImage:(NSDictionary *)dataDictionary;
@end