//
//  CategoryTableViewController.m
//  AKN
//
//  Created by Ponnreay on 1/11/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "NewsByCategoryTableViewController.h"
#import "MainViewController.h"
#import "ConnectionManager.h"
@interface CategoryTableViewController ()<ConnectionManagerDelegate>
{
	NSMutableArray *categories;
    ConnectionManager *manager;
}
@end

@implementation CategoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    manager = [ConnectionManager new];
    manager.delegate = self;
	categories = [[NSMutableArray alloc]init];
    
	[self getCategoryList];
}

#pragma mark - request category
-(void)getCategoryList{
	[manager requestDataWithURL: GET_ARTICLE_CATEGORY];
}

#pragma mark - respone category
-(void)connectionManagerDidReturnResult:(NSArray *)result FromURL:(NSURL *)URL{
	categories = [result valueForKey:R_KEY_DATA];
	[self.tableView reloadData];
}

#pragma mark - Table view data source
#pragma mark - numberOfRowsInSection
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return categories.count;
}

#pragma mark - cellForRowAtIndexPath
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
    
    // Configure the cell...
	cell.textLabel.text = [categories[indexPath.row] valueForKey:@"name"];
	cell.imageView.image = [UIImage imageNamed:@"folder"];
    
    return cell;
}

#pragma mark - didSelectRowAtIndexPath
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	MainViewController *mvc = [MainViewController getInstance];
    NewsByCategoryTableViewController *view=[self.storyboard instantiateViewControllerWithIdentifier:@"listNews"];
	view.pageTitle = [categories[indexPath.row] valueForKey:@"name"];
	view.categoryOrSource = categories[indexPath.row];
	[mvc.navigationController pushViewController:view animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"newsByCategorySegue"]) {
//        NewsByCategoryTableViewController *vc = [segue destinationViewController];
//      vc.pageTitle = sender;
//    }
}


@end
