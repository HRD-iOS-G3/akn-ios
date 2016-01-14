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

@interface CategoryTableViewController ()
{
	NSMutableArray *categories;
}
@end

@implementation CategoryTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	
	categories = [[NSMutableArray alloc]initWithArray:@[@"ពាណិជ្ជកម្ម", @"ពត៌មានពិភពលោក", @"សហក្រិនភាព",@"ថ្មីហើយប្លែក", @"ស៊ីវីល័យ", @"ជីវិតនិងសង្គម", @"កម្សាន្ត", @"កីឡា", @"អចលនទ្រព្យ", @"បច្ចេកវិទ្យា"]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return categories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
    
    // Configure the cell...
	cell.textLabel.text = categories[indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	MainViewController *mvc = [MainViewController getInstance];
    NewsByCategoryTableViewController *view=[self.storyboard instantiateViewControllerWithIdentifier:@"listNews"];
	view.pageTitle = categories[indexPath.row];	[mvc.navigationController pushViewController:view animated:YES];
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"newsByCategorySegue"]) {
//        NewsByCategoryTableViewController *vc = [segue destinationViewController];
//      vc.pageTitle = sender;
//    }
}


@end
