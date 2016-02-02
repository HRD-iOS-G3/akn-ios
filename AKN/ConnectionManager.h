//
//  ConnectionManager.h
//  AKN
//
//  Created by Ponnreay on 1/17/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// METHOD
extern NSString * GET;
extern NSString * POST;
extern NSString * PUT;
extern NSString * DELETE;

// REQUEST URL
extern NSString * LOGIN_URL;
extern NSString * SIGNUP_URL;
extern NSString * GET_USER;
extern NSString * UPDATE_USER;
extern NSString * EDIT_UPLOAD_IMAGE;
extern NSString * IMAGE_URL;

// RESPONSE KEY
extern NSString * R_KEY_MESSAGE;
extern NSString * R_KEY_DATA;

// RESPONSE KEY FOR USER
extern NSString * USERID;
extern NSString * PROFILE_IMG_URL;
extern NSString * COVER_IMG_URL;
extern NSString * EMAIL;
extern NSString * USERNAME;


// MESSAGE STATE
extern NSString * LOGIN_SUCCESS;
extern NSString * LOGIN_UNSUCCESS;

extern NSString * SIGNUP_SUCCESS;
extern NSString * SIGNUP_UNSUCCESS;

extern NSString * GET_USER_SECCESS;

extern NSString * UPDATE_USER_SECCESS;
extern NSString * UPDATE_USER_UNSUCCESS;

extern NSString * UPLOAD_IMAGE_SECCESS;
extern NSString * UPLOAD_IMAGE_UNSECCESS;

// DEFINED KEY
extern NSString * LOGIN_KEY;
extern NSString * USER_DEFAULT_KEY;

// API KEY
extern NSString * API_KEY;
extern NSString * HTTP_HEADER;

// delegate
@protocol  ConnectionManagerDelegate;

// class
@interface ConnectionManager : NSObject

// property
@property (nonatomic, weak) id<ConnectionManagerDelegate>delegate;
@property(nonatomic, strong)NSString *basedUrl;

//Request Method
-(void)requestDataWithURL:(NSDictionary *)reqDictionary withKey:(NSString *)key method:(NSString *)method;
-(void)requestDataWithURL:(NSURL *)URL;
-(void)uploadWithImage:(UIImage *)image urlPath:(NSString *)path fileName:(NSString *)name;

@end

// protocol
@protocol ConnectionManagerDelegate <NSObject>

@optional
//Get Result Method
-(void)connectionManagerDidReturnResult:(NSDictionary *) result;
-(void)connectionManagerDidReturnResult:(NSArray *) result FromURL:(NSURL *)URL;
-(void)responseImage:(NSDictionary *)dataDictionary;

@end