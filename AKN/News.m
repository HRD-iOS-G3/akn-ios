//
//  News.m
//  AKN
//
//  Created by Ponnreay on 1/17/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "News.h"

@implementation News

#pragma mark: - init with data
-(id)initWithData:(NSDictionary *)array{
	self = [super init];
	if (self != nil) {
		_newsSourceId = ([array valueForKeyPath:@"site.id"]==NULL)?0:[[array valueForKeyPath:@"site.id"] intValue];
		_newsId = ([array valueForKey:@"id"]==NULL)?0:[[array valueForKey:@"id"] intValue];
		_newsTitle = ([array valueForKeyPath:@"title"]==NULL)?@"":[array valueForKeyPath:@"title"];
		_newsDescription = ([array valueForKeyPath:@"description"]==NULL)?@"":[array valueForKeyPath:@"description"];
		_newsSource = ([array valueForKeyPath:@"name"]==NULL)?@"":[array valueForKeyPath:@"name"];
		_newsImageUrl = ([array valueForKeyPath:@"image"]==NULL)?@"":[array valueForKeyPath:@"image"];
		_newsHitCount = [[array valueForKeyPath:@"hit"] intValue];
		_newsDateTimestampString = ([array valueForKeyPath:@"date"]==NULL)?@"":[array valueForKeyPath:@"date"];
		_newsURL = ([array valueForKey:@"url"]==NULL)?@"":[array valueForKeyPath:@"url"];
		_saved = ([[array valueForKey:@"saved"] intValue] == 0)?false:true;
	}
	return self;
}


@end
