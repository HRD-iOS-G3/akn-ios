//
//  ConnectionManager.m
//  AKN
//
//  Created by Ponnreay on 1/17/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "ConnectionManager.h"

@implementation ConnectionManager{
    //responseData object
    NSMutableData *responseData;
}

-(void)requestDataWithURL:(NSURL *)URL{
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL: URL];
	
	urlRequest.HTTPMethod = @"GET";
	[urlRequest addValue:@"Basic YXBpOmFrbm5ld3M=" forHTTPHeaderField:@"Authorization"];
//	[urlRequest addValue:@"text/html;charset=ISO-8859-1" forHTTPHeaderField:@"Content-Type"];
	
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
    
    //Target URL
   NSString *baseURL = @"http://akn.khmeracademy.org";
     // NSString *baseURL = @"http://api-akn.herokuapp.com";
    NSString *strURL = [NSString stringWithFormat:@"%@%@", baseURL, key];
  
    NSURL *url = [NSURL URLWithString:strURL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    
    //Set request method and content type
    request.HTTPMethod = method;
    [request addValue:@"Basic YXBpOmFrbm5ld3M=" forHTTPHeaderField:@"Authorization"];
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


-(void)uploadImage:(UIImage *)image urlPath:(NSString *)path fileName:(NSString *)name{
    // url
    //Target URL
    NSString *baseURL = @"http://akn.khmeracademy.org";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, path]];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // image
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    // set content type
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request addValue:@"Basic YXBpOmFrbm5ld3M=" forHTTPHeaderField:@"Authorization"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",name]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // add image data
    [body appendData:[NSData dataWithData:imageData]];
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
