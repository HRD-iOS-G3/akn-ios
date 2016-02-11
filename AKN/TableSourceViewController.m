//
//  TableSourceViewController.m
//  PagingMenu
//
//  Created by Po Dara on 1/6/16.
//  Copyright © 2016 Chum Ratha. All rights reserved.
//

#import "TableSourceViewController.h"
#import "MainViewController.h"
#import "NewsByCategoryTableViewController.h"
#import "ConnectionManager.h"
#import "CustomSourceTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface TableSourceViewController () <ConnectionManagerDelegate>
{
	NSMutableArray *sources;
    ConnectionManager *manager;
}
@end

@implementation TableSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    manager = [[ConnectionManager alloc]init];
    manager.delegate = self;
    
	sources = [[NSMutableArray alloc]init];
	[self getSourceList];
}

#pragma mark - request source
-(void)getSourceList{
	[manager requestDataWithURL: GET_ARTICLE_SITE];
}

#pragma mark - respone source
-(void)connectionManagerDidReturnResult:(NSArray *)result FromURL:(NSURL *)URL{
	sources = [result valueForKey:R_KEY_DATA];
	[self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sources.count;
}




#pragma mark - cellForRowAtIndexPath
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Has image
    CustomSourceTableViewCell *cell = [_customTableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.labelTitle.text = [sources[indexPath.row] valueForKeyPath:@"name"];
    
    // Configure the cell...
    [cell.imageViewImage sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@", manager.basedUrl , SOURCE_URL, [sources[indexPath.row] valueForKeyPath:@"logo"]]] placeholderImage:[UIImage imageNamed:@"akn-logo-red.png"] options:SDWebImageRefreshCached progress:nil completed:nil];
    
    cell.imageViewImage.layer.cornerRadius = cell.imageViewImage.frame.size.width/2;
    cell.imageViewImage.layer.masksToBounds = YES;
    
    return cell;
}


#pragma mark - didSelectRowAtIndexPath
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	MainViewController *mvc = [MainViewController getInstance];
	NewsByCategoryTableViewController *view=[self.storyboard instantiateViewControllerWithIdentifier:@"listNews"];
	view.pageTitle = [sources[indexPath.row] valueForKey:@"name"];
	view.categoryOrSource = sources[indexPath.row];
	[mvc.navigationController pushViewController:view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
