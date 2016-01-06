//
//  TablePageViewController.m
//  PagingMenu
//
//  Created by Chum Ratha on 1/4/16.
//  Copyright © 2016 Chum Ratha. All rights reserved.
//

#import "TablePageViewController.h"
#import "HomeViewCell.h"
@interface TablePageViewController ()<UICollectionViewDataSource>{
    UICollectionViewFlowLayout *coll;
     NSArray *arr;
    __weak IBOutlet UICollectionView *collectionViewNews;
    
    __weak IBOutlet UICollectionViewFlowLayout *collection;
}

@end

@implementation TablePageViewController
-(void)viewDidLayoutSubviews
{
    collection.itemSize=CGSizeMake(collectionViewNews.frame.size.width,collectionViewNews.frame.size.height);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x,self.tableView.frame.origin.y,self.tableView.frame.size.width,150.0)];
    collectionViewNews.dataSource=self;
    //collectionView.delegate=self;
    [coll setItemSize:CGSizeMake(self->collectionViewNews.frame.size.width, self->collectionViewNews.frame.size.height)];
    arr=@[@1,@2,@3];

    //[headerView addSubview:collectionView];
    //self.tableView.tableHeaderView = headerView;
    collectionViewNews.dataSource=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.viewCell.layer.cornerRadius=5;
    cell.sourceImage.layer.cornerRadius=cell.sourceImage.frame.size.width/2;
    cell.newsTitle.text=@"I love Cambodia";
    cell.newsView.text=@"300";
    cell.newsDate.text=@"12-Dec-2015";
    return cell;
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
//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"%ld",(long)indexPath.row);
//    //page.currentPage=indexPath.row;
//}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionViewNews dequeueReusableCellWithReuseIdentifier:@"cell1" forIndexPath:indexPath];
    UIImageView *img=(UIImageView*)[cell viewWithTag:20];
    img.image=[UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",(indexPath.row+1)]];
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
