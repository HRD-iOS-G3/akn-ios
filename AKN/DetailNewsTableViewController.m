//
//  DetailNewsTableViewController.m
//  Detail Article
//
//  Created by Ponnreay on 1/11/16.
//  Copyright © 2016 ponnreay. All rights reserved.
//

#import "DetailNewsTableViewController.h"
#import "MainViewController.h"
#import "Utilities.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ConnectionManager.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface DetailNewsTableViewController ()<ConnectionManagerDelegate>

{
	NSString *imageFile;
	NSString *title;
	NSString *date;
	NSString *description;
	
    IBOutlet UIView *cellContentOfDesc;
    IBOutlet UILabel *lblCpyRight;
	IBOutlet NSLayoutConstraint *imageHeaderCenterY;

}

@end

@implementation DetailNewsTableViewController
-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication].keyWindow addSubview:lblCpyRight];
    [lblCpyRight setFrame:CGRectMake(self.view.frame.size.width, self.view.frame.size.height-lblCpyRight.frame.size.height, self.view.frame.size.width, lblCpyRight.frame.size.height)];

    [UIView animateWithDuration:0.4 animations:^{
        [[UIApplication sharedApplication].keyWindow addSubview:lblCpyRight];
        [lblCpyRight setFrame:CGRectMake(0, self.view.frame.size.height-lblCpyRight.frame.size.height, self.view.frame.size.width, lblCpyRight.frame.size.height)];
    }];
	
	_labelTitle.text = @"";
	_labelDate.text = @"";
	_labelDescription.text = @"";

}
-(void)viewWillDisappear:(BOOL)animated{
    [lblCpyRight removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = _pageTitle;
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // change status color
	self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:193.0/255.0 green:0.0/255.0 blue:1.0/255.0 alpha:1.0];[UIColor redColor];
	
	title = _news.newsTitle;
	date = [Utilities timestamp2date:_news.newsDateTimestampString];
	description = _news.newsDescription;
	
	NSLog(@"%d", _news.newsId);
	
    ConnectionManager *con=[[ConnectionManager alloc]init];
    con.delegate=self;
    [con requestDataWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api-akn.herokuapp.com/api/article/%d/12",_news.newsId]]];
	
}
-(void)viewDidAppear:(BOOL)animated{
	[SVProgressHUD showWithStatus:@"Loading..."];
}
-(void)connectionManagerDidReturnResult:(NSArray *) result FromURL:(NSURL *)URL
{
    NSDictionary *results=((NSDictionary *)result)[@"RESPONSE_DATA"];
    _labelDescription.text=[results[@"content"] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	_news.newsDescription = _labelDescription.text;
    NSLog(@"%d",_news.newsId);
	
	[SVProgressHUD dismiss];
	
	_labelTitle.text = title;
	_labelDate.text = date;
//	_labelDescription.text = description;

	if (_news.newsImage) {
		_imageViewNews.image = _news.newsImage;
	}else{
		[_imageViewNews sd_setImageWithURL:[NSURL URLWithString:_news.newsImageUrl]];
	}


    [self.tableView reloadData ];
    
    
    
    
    
    
    /*for (NSString *ns in result) {
        NSLog(@"%@",ns);
    }*/
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
	[SVProgressHUD dismiss];
	MainViewController *mvc = [MainViewController getInstance];
	[mvc.navigationController popViewControllerAnimated:YES];
//	[mvc.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (indexPath.row) {
		case 0:
			return 180;
			break;
		case 1:
			return [self heightForText:title font:_labelTitle.font withinWidth:self.view.frame.size.width-36]+10;
			break;
		case 2:
			return 36.0;
			break;
		case 3:
			return [self heightForText:_labelDescription.text font:_labelDescription.font withinWidth:self.view.frame.size.width-36];
			break;
		case 4:
			return 36.0;
		default:
			return 0;
			break;
	}
}
-(CGFloat)heightForText:(NSString*)text font:(UIFont*)font withinWidth:(CGFloat)width {
	
	CGSize constraint = CGSizeMake(width, 20000.0f);
	CGSize size;
	
	CGSize boundingBox = [text boundingRectWithSize:constraint
											options:NSStringDrawingUsesLineFragmentOrigin
										 attributes:@{NSFontAttributeName:font}
											context:nil].size;
	
	size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
	
	return size.height;
}

-(int)calculateHeightForString:(NSString *)string{
	NSAttributedString *attr = [[NSAttributedString alloc]initWithString:string];
	return [attr boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height * 2;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat y=-scrollView.contentOffset.y;
	if (y>64)
	{
		imageHeaderCenterY.constant=0;
	}
	else
	{
		imageHeaderCenterY.constant=(64-y)/2;
	}
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
