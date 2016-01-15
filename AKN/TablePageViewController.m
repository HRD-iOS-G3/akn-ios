//
//  TablePageViewController.m
//  PagingMenu
//
//  Created by Chum Ratha on 1/4/16.
//  Copyright © 2016 Chum Ratha. All rights reserved.
//

#import "TablePageViewController.h"
#import "HomeViewCell.h"
#import "MainViewController.h"
#import "DetailNewsTableViewController.h"

@interface TablePageViewController ()<UICollectionViewDataSource,UIScrollViewDelegate>{
    UICollectionViewFlowLayout *coll;
    NSArray *arr;
    __weak IBOutlet UICollectionView *collectionViewNews;
    
    __weak IBOutlet UICollectionViewFlowLayout *collection;
    CGFloat kTableHeaderHeight;
    UIView *headerView;
    
    UIView *viewIndicator;
}

@end

@implementation TablePageViewController
-(void)viewDidLayoutSubviews
{
    [coll setItemSize:CGSizeMake(collectionViewNews.frame.size.width, collectionViewNews.frame.size.height)];
    //viewIndicator.layer.zPosition=1;
    //[viewIndicator setFrame:CGRectMake(viewIndicator.frame.origin.x,0, viewIndicator.frame.size.width, 35)];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    kTableHeaderHeight=200.0;
    headerView=[[UIView alloc]init];
   
    headerView=self.tableView.tableHeaderView;
    self.tableView.tableHeaderView=nil;
    [self.tableView addSubview:headerView];
    self.tableView.contentInset=UIEdgeInsetsMake(kTableHeaderHeight, 0.0, 0.0, 0.0);
    self.tableView.contentOffset=CGPointMake(0.0, -kTableHeaderHeight);
    [self updateHeaderView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x,self.tableView.frame.origin.y,self.tableView.frame.size.width,150.0)];
    
    arr=@[@1,@2,@3,@4];
    
}
-(void)updateHeaderView{
    CGRect headerRect=CGRectMake(0.0, -kTableHeaderHeight, self.tableView.bounds.size.width, kTableHeaderHeight);
    if (self.tableView.contentOffset.y < -kTableHeaderHeight) {
        headerRect.origin.y=self.tableView.contentOffset.y;
        headerRect.size.height= -self.tableView.contentOffset.y;
    }
	[coll setItemSize:CGSizeMake(collectionViewNews.frame.size.width, headerRect.size.height)];
    headerView.frame=headerRect;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateHeaderView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.viewCell.layer.cornerRadius=5;
    cell.sourceImage.layer.cornerRadius=cell.sourceImage.frame.size.width/2;
    cell.newsTitle.text=@"4th Generation Orientation at CKCC";
    cell.newsView.text=@"300";
    cell.newsDate.text=@"02-April-2015";
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	MainViewController *mvc = [MainViewController getInstance];
	DetailNewsTableViewController *dvc = [[UIStoryboard storyboardWithName:@"Detail" bundle:nil] instantiateViewControllerWithIdentifier:@"detailNews"];
	
	[mvc.navigationController pushViewController:dvc animated:YES];
}

//-(void)viewDidLayoutSubviews
//{
//    [coll setItemSize:CGSizeMake(self->collectionView.frame.size.width, self->collectionView.frame.size.height)];
//    //UICollectionViewCell *cell=(UICollectionViewCell*)[self->collectionView viewWithTag:30];
//    //[cell setFrame:CGRectMake(0,0,self->collectionView.bounds.size.width,self->collectionView.bounds.size.height)];
//}
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"%ld",(long)indexPath.row);
//}


#pragma mark - Collection View

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	
	MainViewController *mvc = [MainViewController getInstance];
	DetailNewsTableViewController *dvc = [[UIStoryboard storyboardWithName:@"Detail" bundle:nil] instantiateViewControllerWithIdentifier:@"detailNews"];
	dvc.pageTitle = @"Popular News";
	[mvc.navigationController pushViewController:dvc animated:YES];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionViewNews dequeueReusableCellWithReuseIdentifier:@"cell1" forIndexPath:indexPath];
    UIImageView *img=(UIImageView*)[cell viewWithTag:20];
    img.image=[UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",(long)(indexPath.row+1)]];
    return cell;
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
