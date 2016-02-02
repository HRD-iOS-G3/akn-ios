//
//  ConnectionManager.m
//  AKN
//
//  Created by Ponnreay on 1/17/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "ConnectionManager.h"

// REQUEST METHOD
NSString * GET  = @"GET";//
NSString * POST = @"POST";//
NSString * PUT  = @"PUT";//
NSString * DELETE = @"DELETE";//

// REQUEST URL
NSString * LOGIN_URL    = @"/api/user/login";//
NSString * SIGNUP_URL   = @"/api/user/";//
NSString * GET_USER     = @"/api/user";
NSString * UPDATE_USER  = @"/api/user/update";//
NSString * EDIT_UPLOAD_IMAGE  = @"/api/user/editupload";//
NSString * IMAGE_URL    = @"/api/uploadfile/upload?url=user";

// RESPONSE KEY
NSString * R_KEY_MESSAGE    = @"MESSAGE";//
NSString * R_KEY_DATA   =  @"DATA";//


// RESPONSE KEY FOR UER
NSString * USERID           = @"USERID";
NSString * PROFILE_IMG_URL  = @"PROFILE_IMG_URL";
NSString * COVER_IMG_URL    = @"COVER_IMG_URL";
NSString * EMAIL            = @"EMAIL";
NSString * USERNAME         = @"USERNAME";


// MESSAGE STATE
NSString * LOGIN_SUCCESS    = @"LOGIN SUCCESS";//
NSString * LOGIN_UNSUCCESS  = @"Login failed! check email or password and try again!";//

NSString * SIGNUP_SUCCESS   = @"SUCCESS"; //
NSString * SIGNUP_UNSUCCESS = @"SignUp Failed\nThis username is already created!!!";//

NSString * GET_USER_SECCESS = @"RECORD FOUND";

NSString * UPDATE_USER_SECCESS     = @"SUCCESS";//
NSString * UPDATE_USER_UNSUCCESS   = @"OPERATION FAIL";//

NSString * UPLOAD_IMAGE_SECCESS    = @"SUCCESS";//
NSString * UPLOAD_IMAGE_UNSECCESS  = @"OPERATION FAIL";//

// DEFINED KEY
NSString * LOGIN_KEY = @"login";
NSString * USER_DEFAULT_KEY = @"user";//

// API KEY
NSString *API_KEY = @"Authorization";//
NSString *HTTP_HEADER = @"Basic YXBpOmFrbm5ld3M=";//



@implementation ConnectionManager{
    //responseData object
    NSMutableData *responseData;
}

-(id)init{
    self = [super init];
    if (self != nil) {
        self.basedUrl = @"http://akn.khmeracademy.org";
    }
    return self;
}

#pragma mark: - Request with URL
-(void)requestDataWithURL:(NSURL *)URL{
    
    // create request with url
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL: URL];
	
    //Set request method and content type
	urlRequest.HTTPMethod = GET;
	[urlRequest addValue:HTTP_HEADER forHTTPHeaderField:API_KEY];
	
    //Create session
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
	
	[[session downloadTaskWithRequest:urlRequest completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
		if (!error) {
			if ([urlRequest.URL isEqual:URL] ) {
				NSData *data = [NSData dataWithContentsOfURL:localfile];
				NSArray *root = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
				[self.delegate connectionManagerDidReturnResult:root FromURL:URL];
			}
		}else{
			NSLog(@"Error request data : %@", error);
		}
		
	}] resume];
}


#pragma mark: - Request with Method
-(void)requestDataWithURL:(NSDictionary *)reqDictionary withKey:(NSString *)key method:(NSString *)method{
    
    // set url
    NSString *strURL = [NSString stringWithFormat:@"%@%@", self.basedUrl, key];
    NSURL *url = [NSURL URLWithString:strURL];
    
    // create request with url
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    
    //Set request method and content type
    request.HTTPMethod = method;
    [request addValue:HTTP_HEADER forHTTPHeaderField:API_KEY];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //Create session
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSData *jsonObject = [NSJSONSerialization dataWithJSONObject:reqDictionary options:0 error:nil];
    
    NSString *urlString = [[NSString alloc] initWithData:jsonObject encoding:NSUTF8StringEncoding];
    
    //Add request object to request body
    NSData *requestBodyData = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPBody = requestBodyData;
    
    //Create download task for download content
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            if ([request.URL isEqual:url] ) {
                NSData *data = [NSData dataWithContentsOfURL:localfile];
               
                //init responseData object
                responseData = [NSMutableData data];
                [responseData appendData:data];
                
                //convert from json to dictionary
                NSDictionary *dicObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];

                //call return result method
                [self.delegate connectionManagerDidReturnResult:dicObject];
            }
        }
    }];
    [task resume];
}

#pragma mark: - Request with Method
-(void)uploadWithImage:(UIImage *)image urlPath:(NSString *)path fileName:(NSString *)name{
  
    // set url
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.basedUrl, path]];
    
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // image
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:POST];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    // set content type
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request addValue:HTTP_HEADER forHTTPHeaderField:API_KEY];
   
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", name]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // add image data
    [body appendData:[NSData dataWithData:imageData]];
    
        // close form
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // create session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    [[session downloadTaskWithRequest:request completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSData *data = [NSData dataWithContentsOfURL:localfile];
            NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [self.delegate responseImage:root];
        }else{
            NSLog(@"Error request data : %@", error);
        }
        
    }] resume];
}


@end
