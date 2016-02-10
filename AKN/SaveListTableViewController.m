//
//  SaveListTableViewController.m
//  AKN
//
//  Created by Yin Kokpheng on 1/18/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "SaveListTableViewController.h"
#import "SWRevealViewController.h"
#import "ConnectionManager.h"
#import "News.h"
#import "UIView+Toast.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "HomeViewCell.h"
#import "Utilities.h"
#import "MainViewController.h"
#import "DetailNewsTableViewController.h"
#import "UIImageView+WebCache.h"


@interface SaveListTableViewController ()<ConnectionManagerDelegate>
{
	NSMutableArray<News *> *savedNewsList;
    ConnectionManager * manager;
}

@end

@implementation SaveListTableViewController

id selfobject;
+(SaveListTableViewController *)getInstance{
	return selfobject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    savedNewsList = [[NSMutableArray alloc]init];
    
    manager = [[ConnectionManager alloc]init];
    manager.delegate = self;
	selfobject = self;
    
    // set navigation bar
    [Utilities customizeNavigationBar:self.navigationController withTitle:@"SAVE LIST"];
	
    //Set SWReveal
    [Utilities setSWRevealSidebarButton:self.sidebarButton :self.revealViewController :self.view];
}


-(void)viewDidAppear:(BOOL)animated{
    
    // set user id
    _userId = 0;
	if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY]) {
		_userId = [[[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY] valueForKey:@"id"] intValue];
	}
    
    // fetch news
	if (savedNewsList.count == 0) {
		[manager requestDataWithURL:[NSString stringWithFormat:@"%@/%d/10/1/1", SAVE_LIST, _userId]]; // need to create pagination with this url
		[SVProgressHUD showWithStatus:@"Loading..."];
	}
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return savedNewsList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 126;
}


#pragma mark - Connection manager delegate
-(void)connectionManagerDidReturnResult:(NSArray *)result FromURL:(NSURL *)URL{
	[SVProgressHUD dismiss];
	NSLog(@"Result >>>>>>> %@",result);
    
    // add news to list when success
	if ([[result valueForKeyPath:R_KEY_MESSAGE] isEqualToString:GET_NEWS_SUCCESS]) {
		[savedNewsList removeAllObjects];
		for (NSDictionary *object in [result valueForKeyPath:R_KEY_RESPONSE_DATA]) {
			News *news = [[News alloc]initWithData:object];
			news.saved = true;
			[savedNewsList addObject:news];
		}
		[self.tableView reloadData];
	}else{
		[self.navigationController.view makeToast:[result valueForKeyPath:R_KEY_MESSAGE] duration:3 position:CSToastPositionCenter];
	}
}

#pragma mark - cellForRowAtIndexPath
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"saveListCell"];
	cell.viewCell.layer.cornerRadius=5;
	cell.sourceImage.layer.cornerRadius=cell.sourceImage.frame.size.width/2;
	
	[self configureCell:cell AtIndexPath:indexPath];
	
	return cell;
}

#pragma mark - custom cell
-(void)configureCell:(HomeViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath{
    
    // set title, view, and date
	cell.newsTitle.text=[NSString stringWithFormat:@"%@",savedNewsList[indexPath.row].newsTitle];
	cell.newsView.text=[NSString stringWithFormat:@"%d",savedNewsList[indexPath.row].newsHitCount];
	cell.newsDate.text=[NSString stringWithFormat:@"%@", [Utilities timestamp2date:savedNewsList[indexPath.row].newsDateTimestampString]];
	
    // set tag for save button
	cell.buttonSave.tag = indexPath.row;
	[cell.buttonSave addTarget:self action:@selector(buttonSaveClick:) forControlEvents:UIControlEventTouchUpInside];
	
	[cell.buttonSave setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    
    // set image by source
	switch (savedNewsList[indexPath.row].newsSourceId) {
			
		case 1: //sabay
			cell.sourceImage.image = [UIImage imageNamed:@"sabay"];
			break;
		case 2://koh sontepheap
			cell.sourceImage.image = [UIImage imageNamed:@"kohsontepheap"];
			break;
		case 5:///the b news
			cell.sourceImage.image = [UIImage imageNamed:@"bnews.jpg"];
			break;
		case 6://AKN news
			cell.sourceImage.image = [UIImage imageNamed:@"akn-logo-red.png"];
			break;
		case 10://Cambo report
			cell.sourceImage.image = [UIImage imageNamed:@"cambo-report"];
			break;
		case 12://Mungkulkar
			cell.sourceImage.image = [UIImage imageNamed:@"mungkulkar"];
			break;
		default:
			break;
	}
    
    // download image
    if (savedNewsList[indexPath.row].newsImage){
        cell.newsImage.image = savedNewsList[indexPath.row].newsImage;
    }else{

        // download image
        [cell.newsImage sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString: savedNewsList[indexPath.row].newsImageUrl]
                                                 placeholderImage:[UIImage imageNamed:@"akn-logo-red"]
                                                          options:SDWebImageRefreshCached progress:nil
                                                        completed:nil];
    }
}


#pragma mark - didSelectRowAtIndexPath
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	DetailNewsTableViewController *dvc = [[UIStoryboard storyboardWithName:@"Detail" bundle:nil] instantiateViewControllerWithIdentifier:@"detailNews"];
	dvc.news = (News *)savedNewsList[indexPath.row];
	dvc.sourceViewController = @"SaveList";
	[self.navigationController pushViewController:dvc animated:YES];
}

#pragma mark - save news button event
-(void)buttonSaveClick:(UIButton *)sender{
    
    // check user existed
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USER_DEFAULT_KEY]) {
        
        // request to delete
        [manager requestDataWithURL:[NSString stringWithFormat:@"%@/%d/%d", SAVE_LIST ,savedNewsList[sender.tag].newsId, _userId] data:@{} method:DELETE];
        
        [self.navigationController.view makeToast:@"Deleted!"
                                         duration:2.0
                                         position:CSToastPositionBottom];
        [savedNewsList removeObjectAtIndex:sender.tag];
        [self.tableView reloadData];
    }else{
        
        [self.navigationController.view makeToast:@"Error occurred!"
                                         duration:3.0
                                         position:CSToastPositionBottom];
    }
}

#pragma mark - respone when delete
-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
    NSLog(@"Delete ====== %@",result);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
