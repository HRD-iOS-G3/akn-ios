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
#import "UIView+Toast.h"
#import "SaveListTableViewController.h"
#import <Google/Analytics.h>

@interface DetailNewsTableViewController ()<ConnectionManagerDelegate>

{
	NSString * imageFile;
	NSString * title;
	NSString * date;
	NSString * description;
	
    IBOutlet UIView * cellContentOfDesc;
    IBOutlet UILabel * lblCpyRight;
	IBOutlet NSLayoutConstraint * imageHeaderCenterY;
    
    ConnectionManager * manager;

}

@end

@implementation DetailNewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utilities customizeNavigationBar:self.navigationController withTitle:@"News Details" ];
    
    title = _news.newsTitle;
    date = [Utilities timestamp2date:_news.newsDateTimestampString];
    //	description = _news.newsDescription;
    
    // custom font
    UIFont *customFont = [UIFont fontWithName:@"KhmerOSBattambang" size:17];
    self.labelDescription.font = customFont;
    
    UIFont *customFont2 = [UIFont fontWithName:@"KhmerOSBattambang-Bold" size:17];
    self.labelTitle.font = customFont2;
    
    // set user id
    int userId= 0;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY]) {
        userId = [[[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY] valueForKey:@"id"] intValue];
    }
    
    // init connection manager then request news
    manager = [[ConnectionManager alloc]init];
    manager.delegate=self;
    [manager requestDataWithURL:[NSString stringWithFormat:@"%@/%d/%d", GET_ARTICLE ,_news.newsId, userId]];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [SVProgressHUD showWithStatus:@"Loading..."];
}

-(void)viewWillDisappear:(BOOL)animated{
    [lblCpyRight removeFromSuperview];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// May return nil if a tracker has not already been initialized with a
	// property ID.
	id tracker = [[GAI sharedInstance] defaultTracker];
	
	// This screen name value will remain set on the tracker and sent with
	// hits until it is set to a new value or to nil.
	[tracker set:kGAIScreenName
		   value:@"Detail Screen"];
	
	// Previous V3 SDK versions
	// [tracker send:[[GAIDictionaryBuilder createAppView] build]];
	
	// New SDK versions
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
	
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

#pragma mark - respone news details
-(void)connectionManagerDidReturnResult:(NSArray *) result FromURL:(NSURL *)URL
{
    NSLog(@"%@", URL);
    [SVProgressHUD dismiss];
    
    // check
    if ([[result valueForKey:@"STATUS"]  isEqual: @404]) {
        [self.navigationController.view makeToast:[result valueForKey:R_KEY_MESSAGE] duration:3 position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    }else{
        
        // create dictionary for store result
        NSDictionary *results=((NSDictionary *)result)[R_KEY_RESPONSE_DATA];
        NSString *str = [[result valueForKey:R_KEY_RESPONSE_DATA] valueForKey:@"content"];
        
        // check content
        if (str != (id)[NSNull null]) {
            if (![str isEqualToString: @""] || ![str isEqualToString:@"null"]) {
                _labelDescription.text = [NSString stringWithFormat:@"%@",[results[@"content"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
                _news.newsDescription = _labelDescription.text;
                _labelTitle.text = title;
                _labelDate.text = date;
                
                if (_news.newsImage) {
                    _imageViewNews.image = _news.newsImage;
                }else{
                    [_imageViewNews sd_setImageWithURL:[NSURL URLWithString:_news.newsImageUrl]];
                }
                [SVProgressHUD dismiss];
                [self.tableView reloadData ];
            }
        }else{
            [self.navigationController.view makeToast:@"News not found!" duration:2 position:CSToastPositionCenter];
            [SVProgressHUD dismiss];
        }
        NSLog(@"%d",_news.newsId);
    }
}


#pragma mark - save event
- (IBAction)actionSave:(id)sender {
    lblCpyRight.hidden = true;
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"More"
                                 message:@"Share to Facebook or Save News"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* shareFacebook = [UIAlertAction
                                    actionWithTitle:@"Share to Facebook"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Do some thing here
                                        [view dismissViewControllerAnimated:YES completion:nil];
                                         lblCpyRight.hidden = false;
                                        
                                    }];
    
    UIAlertAction* saveNews = [UIAlertAction
                               actionWithTitle:@"Save News"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                       // check user exist
                                   	if ([[NSUserDefaults standardUserDefaults]objectForKey:USER_DEFAULT_KEY]) {
                                   
                                   		//sender setImage:[UIImage imageNamed:@"save-gray"] forState:UIControlStateNormal];
                                   
                                   		[sender setEnabled:false];
                                   
                                   		_news.saved = true;
                                   
                                           // request dictionary
                                           NSDictionary * param = @{@"newsid":[NSNumber numberWithInt:_news.newsId],
                                                                    @"userid":[NSNumber numberWithInt:[[[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY] valueForKey:@"id"]intValue]]} ;
                                   
                                           [manager requestDataWithURL:SAVE_LIST data:param method:POST];
                                           
                                   		[[MainViewController getInstance].navigationController.view makeToast:@"Saved!"
                                   																	 duration:2.0
                                   																	 position:CSToastPositionBottom];
                                   	}else{
                                   		
                                   		[[MainViewController getInstance].navigationController.view makeToast:@"Please login first!"
                                   																	 duration:3.0
                                   																	 position:CSToastPositionBottom];
                                   	}
                                   [view dismissViewControllerAnimated:YES completion:nil];
                                    lblCpyRight.hidden = false;
                                   
                               }];
    
    if (_news.saved) {
        saveNews.enabled = false;
    }
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                  lblCpyRight.hidden = false;
                                 
                             }];
    
    [view addAction:shareFacebook];
    [view addAction:saveNews];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

#pragma mark - respone save event
-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
    NSLog(@"save event ====== %@", result);
}

- (IBAction)backAction:(id)sender {
	[SVProgressHUD dismiss];
	
	if ([self.sourceViewController isEqualToString:@"SaveList"]) {
		[[SaveListTableViewController getInstance].navigationController popToRootViewControllerAnimated:YES];
	}else{
		MainViewController *mvc = [MainViewController getInstance];
		[mvc.navigationController popViewControllerAnimated:YES];
	}
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

#pragma mark - heightForText for display content
-(CGFloat)heightForText:(NSString*)text font:(UIFont*)font withinWidth:(CGFloat)width {
	// find font height
	CGSize constraint = CGSizeMake(width, 20000.0f);
	CGSize size;
	
	CGSize boundingBox = [text boundingRectWithSize:constraint
											options:NSStringDrawingUsesLineFragmentOrigin
										 attributes:@{NSFontAttributeName:font}
											context:nil].size;
	
	size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
	
	return size.height;
}

#pragma mark - calculateHeightForString for display content
-(int)calculateHeightForString:(NSString *)string{
    
	NSAttributedString *attr = [[NSAttributedString alloc]initWithString:string];
	return [attr boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height * 2;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat y = -scrollView.contentOffset.y;
    if (y > 64){
        imageHeaderCenterY.constant = 0;
    }
    else{
        imageHeaderCenterY.constant = (64-y)/2;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
