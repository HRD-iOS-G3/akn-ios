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

@interface TableSourceViewController () <ConnectionManagerDelegate>
{
	NSMutableArray *sources;
}
@end

@implementation TableSourceViewController
- (void)viewDidLoad {
    [super viewDidLoad];
	
	sources = [[NSMutableArray alloc]init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[self getSourceList];
}
-(void)getSourceList{
	ConnectionManager *manager = [[ConnectionManager alloc]init];
	manager.delegate = self;
	[manager requestDataWithURL:[NSURL URLWithString:@"http://akn.khmeracademy.org/api/article/site/"]];
}
-(void)connectionManagerDidReturnResult:(NSArray *)result FromURL:(NSURL *)URL{
//	NSLog(@"%@", result);
	sources = [result valueForKey:@"DATA"];
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
	cell.textLabel.text = [sources[indexPath.row] valueForKeyPath:@"name"];
	switch ([[sources[indexPath.row] valueForKeyPath:@"id"] intValue]) {
			
		case 1: //sabay
			cell.imageView.image = [UIImage imageNamed:@"sabay"];
			break;
		case 2://koh sontepheap
			cell.imageView.image = [UIImage imageNamed:@"kohsontepheap"];
			break;
		case 5:///the b news
			cell.imageView.image = [UIImage imageNamed:@"bnews.jpg"];
			break;
		case 6://AKN news
			cell.imageView.image = [UIImage imageNamed:@"akn-logo-red.png"];
			break;
		case 10://Cambo report
			cell.imageView.image = [UIImage imageNamed:@"cambo-report"];
			break;
		case 12://Mungkulkar
			cell.imageView.image = [UIImage imageNamed:@"mungkulkar"];
			break;
	default:
			break;
	}
	
    return cell;
}


#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	MainViewController *mvc = [MainViewController getInstance];
	NewsByCategoryTableViewController *view=[self.storyboard instantiateViewControllerWithIdentifier:@"listNews"];
	view.pageTitle = [sources[indexPath.row] valueForKey:@"name"];
	view.categoryOrSource = sources[indexPath.row];
	[mvc.navigationController pushViewController:view animated:YES];
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
