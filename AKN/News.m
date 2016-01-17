//
//  News.m
//  AKN
//
//  Created by Ponnreay on 1/17/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "News.h"

@implementation News

-(id)initWithData:(NSDictionary *)array{
	self = [super init];
	if (self != nil) {
		_newsSourceId = [[array valueForKeyPath:@"site.id"] intValue];
		_newsId = [[array valueForKey:@"id"] intValue];
		_newsTitle = [array valueForKeyPath:@"title"];
		_newsDescription = [array valueForKeyPath:@"description"];
		_newsSource = [array valueForKeyPath:@"name"];
		_newsImageUrl = [array valueForKeyPath:@"image"];
		_newsHitCount = [array valueForKeyPath:@"hit"];
		_newsDateTimestampString = [array valueForKeyPath:@"date"];
		_newsURL = [array valueForKey:@"url"];
	}
	return self;
}


@end
