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
@end
