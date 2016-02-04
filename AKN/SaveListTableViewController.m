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
@interface SaveListTableViewController ()<ConnectionManagerDelegate>
{
	int userId;
	NSMutableArray<News *> *savedNewsList;
}
@end

@implementation SaveListTableViewController
id selfobject;
+(SaveListTableViewController *)getInstance{
	return selfobject;
}
- (void)viewDidLoad {
    [super viewDidLoad];
	selfobject = self;
    [Utilities customizeNavigationBar:self.navigationController withTitle:@"SAVE LIST"];
	savedNewsList = [[NSMutableArray alloc]init];
	userId = 0;
    
    //Set SWReveal
    [self.sidebarButton setTarget: self.revealViewController];
    [self.sidebarButton setAction: @selector( revealToggle: )];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}
-(void)viewDidAppear:(BOOL)animated{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY]) {
		userId = [[[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY] valueForKey:@"id"] intValue];
	}
	if (savedNewsList.count == 0) {
		ConnectionManager *manager = [[ConnectionManager alloc]init];
		manager.delegate = self;
		[manager requestDataWithURL1:[NSString stringWithFormat:@"%@/%d/10/1", SAVE_LIST, userId]]; // need to create pagination with this url
		[SVProgressHUD showWithStatus:@"Loading..."];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return savedNewsList.count;
}

#pragma mark - Connection manager delegate
-(void)connectionManagerDidReturnResult:(NSArray *)result FromURL:(NSURL *)URL{
	[SVProgressHUD dismiss];
	NSLog(@"%@",result);
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
-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
	NSLog(@"%@",result);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"saveListCell"];
	cell.viewCell.layer.cornerRadius=5;
	cell.sourceImage.layer.cornerRadius=cell.sourceImage.frame.size.width/2;
	
	[self configureCell:cell AtIndexPath:indexPath];
	
	return cell;

}

-(void)configureCell:(HomeViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath{
	cell.newsTitle.text=[NSString stringWithFormat:@"%@",savedNewsList[indexPath.row].newsTitle];
	cell.newsView.text=[NSString stringWithFormat:@"%d",savedNewsList[indexPath.row].newsHitCount];
	cell.newsDate.text=[NSString stringWithFormat:@"%@", [Utilities timestamp2date:savedNewsList[indexPath.row].newsDateTimestampString]];
	
	cell.buttonSave.tag = indexPath.row;
	[cell.buttonSave addTarget:self action:@selector(buttonSaveClick:) forControlEvents:UIControlEventTouchUpInside];
	
	[cell.buttonSave setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
	
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
	
	if (savedNewsList[indexPath.row].newsImage){
		cell.newsImage.image = savedNewsList[indexPath.row].newsImage;
	}else{
		cell.newsImage.image = [UIImage imageNamed:@"akn-logo-red"];
		// download image in background
		[self downloadImageInBackground:savedNewsList[indexPath.row] forIndexPath:indexPath];
	}
}
-(void)buttonSaveClick:(UIButton *)sender{
	if ([[NSUserDefaults standardUserDefaults]objectForKey:@"user"]) {
		ConnectionManager *m = [[ConnectionManager alloc]init];
		m.delegate = self;
		
		[m requestDataWithURL:@{} withKey:[NSString stringWithFormat:@"%@/%d/%d", SAVE_LIST ,savedNewsList[sender.tag].newsId,userId] method:DELETE];
		
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

- (void)downloadImageInBackground:(News *)news forIndexPath:(NSIndexPath *)indexPath {
	
	dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	
	dispatch_async(concurrentQueue, ^{
		__block NSData *dataImage = nil;
		
		dispatch_sync(concurrentQueue, ^{
			NSURL *urlImage = [NSURL URLWithString:news.newsImageUrl];
			dataImage = [NSData dataWithContentsOfURL:urlImage];
		});
		
		dispatch_async(dispatch_get_main_queue(), ^{
			HomeViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
			savedNewsList[indexPath.row].newsImage = [UIImage imageWithData:dataImage];
			cell.newsImage.image = savedNewsList[indexPath.row].newsImage;
		});
	});
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 126;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	DetailNewsTableViewController *dvc = [[UIStoryboard storyboardWithName:@"Detail" bundle:nil] instantiateViewControllerWithIdentifier:@"detailNews"];
	dvc.news = (News *)savedNewsList[indexPath.row];
	dvc.sourceViewController = @"SaveList";
	[self.navigationController pushViewController:dvc animated:YES];
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
