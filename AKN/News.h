//
//  News.h
//  AKN
//
//  Created by Ponnreay on 1/17/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface News : NSObject

@property int newsId;
@property int newsSourceId;
@property(nonatomic, strong)NSString *newsTitle;
@property(nonatomic, strong)NSString *newsURL;
@property(nonatomic, strong)NSString *newsDescription;
@property(nonatomic, strong)NSString *newsSource;
@property(nonatomic, strong)NSString *newsImageUrl;
@property(nonatomic, strong)UIImage *newsImage;
@property int newsHitCount;
@property(nonatomic, strong)NSString *newsDateTimestampString;
@property BOOL saved;

-(id)initWithData:(NSDictionary *)array;

@end
