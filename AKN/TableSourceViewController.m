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
    NSLog(@"%@",[sources[indexPath.row] valueForKeyPath:@"name"]);

    
  
	switch ([[sources[indexPath.row] valueForKeyPath:@"id"] intValue]) {
		case 1: //sabay
			cell.imageViewImage.image = [UIImage imageNamed:@"sabay"];
			break;
		case 2://koh sontepheap
			cell.imageViewImage.image = [UIImage imageNamed:@"kohsontepheap"];
			break;
		case 5:///the b news
			cell.imageViewImage.image = [UIImage imageNamed:@"bnews.jpg"];
			break;
		case 6://AKN news
			cell.imageViewImage.image = [UIImage imageNamed:@"akn-logo-red.png"];
			break;
		case 10://Cambo report
			cell.imageViewImage.image = [UIImage imageNamed:@"cambo-report"];
			break;
		case 12://Mungkulkar
			cell.imageViewImage.image = [UIImage imageNamed:@"mungkulkar"];
			break;
        case 17://Biz Khmer
            cell.imageViewImage.image = [UIImage imageNamed:@"bizkhmer"];
            break;
        case 18://Business Cambodia
            cell.imageViewImage.image = [UIImage imageNamed:@"businesscambodia.jpg"];
            break;
        case 19://IOS Khmer
            cell.imageViewImage.image = [UIImage imageNamed:@"ioskhmer"];
            break;
        case 21://Khmer Note
            cell.imageViewImage.image = [UIImage imageNamed:@"khmernote"];
            break;
        case 22://rfa
            cell.imageViewImage.image = [UIImage imageNamed:@"rfa"];
            break;
	default:
			break;
	}
    
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
