//
//  ConnectionManager.m
//  AKN
//
//  Created by Ponnreay on 1/17/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "ConnectionManager.h"

@implementation ConnectionManager

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

@end
