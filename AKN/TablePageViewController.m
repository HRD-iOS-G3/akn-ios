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
    
    
    __weak IBOutlet UICollectionView *collectionViewNews;
    
    __weak IBOutlet UICollectionViewFlowLayout *collection;
    CGFloat kTableHeaderHeight;
    UIView *headerView;
    
  
    __strong IBOutlet UIView *viewIndicatorTop;
    __weak IBOutlet UIView *viewIndicator;
    UIView *viewIndiTop;
}
@property (strong,nonatomic) NSArray *arr;
@property (strong, nonatomic) NSIndexPath *indexPathForDeviceOrientation;// for move to the right position after orientation

@end

@implementation TablePageViewController
-(void)viewDidLayoutSubviews
{
    [collection setItemSize:CGSizeMake(collectionViewNews.frame.size.width, collectionViewNews.frame.size.height)];
    viewIndicator.layer.zPosition=1;
    //viewIndicatorTop.alpha=0.5;
    [viewIndicatorTop setFrame:CGRectMake(viewIndicatorTop.frame.origin.x,0, viewIndicator.frame.size.width, viewIndicatorTop.frame.size.height)];
    //viewIndicator.constraints[2].constant=-37;
    //viewIndicator.layer.zPosition=1;
    //[viewIndicator setFrame:CGRectMake(viewIndicator.frame.origin.x,0, viewIndicator.frame.size.width, 35)];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    viewIndiTop=[[UIView alloc]initWithFrame:CGRectMake(0,-37, self.view.frame.size.width, 37)];
    viewIndiTop.backgroundColor=[UIColor clearColor];
    [viewIndicator addSubview:viewIndiTop];
    [viewIndiTop addSubview:viewIndicatorTop];
    /*viewIndicatorTop.translatesAutoresizingMaskIntoConstraints=NO;
    [viewIndicator addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[viewIndiTop]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(viewIndiTop)]];
    [viewIndicator addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-<=0-[viewIndiTop(37)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(viewIndiTop)]];*/
    
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
    
   
    // data source
     _arr=@[@1,@2,@3,@4];
    // duplicate the last item and put it at first
    // duplicate the first item and put it at last
    id firstItem = [_arr firstObject];
    id lastItem = [_arr lastObject];
    NSMutableArray *workingArray = [_arr mutableCopy];
    [workingArray insertObject:lastItem atIndex:0];
    [workingArray addObject:firstItem];
    _arr = workingArray;
    
    
}
-(void)updateHeaderView{
    CGRect headerRect=CGRectMake(0.0, -kTableHeaderHeight, self.tableView.bounds.size.width, kTableHeaderHeight);
    if (self.tableView.contentOffset.y < -kTableHeaderHeight) {
        headerRect.origin.y=self.tableView.contentOffset.y;
        headerRect.size.height= -self.tableView.contentOffset.y;
    }
	[collection setItemSize:CGSizeMake(collectionViewNews.frame.size.width, headerRect.size.height)];
    headerView.frame=headerRect;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    
    if (scrollView == self.tableView) {
        [self updateHeaderView];
        
        CGFloat y=-scrollView.contentOffset.y;
        
        
        if (y>310 && viewIndicatorTop.tag!=100) {
            
            [UIView animateWithDuration:0.3 animations:^{
                [viewIndiTop setFrame:CGRectMake(viewIndicatorTop.frame.origin.x,0, viewIndicator.frame.size.width, viewIndiTop.frame.size.height)];
            } completion:^(BOOL finished) {
                
            }];
            viewIndicatorTop.tag=100;
        }

    }else{
        
        static CGFloat lastContentOffsetX = FLT_MIN;
        
        // We can ignore the first time scroll,
        // because it is caused by the call scrollToItemAtIndexPath: in ViewWillAppear
        if (FLT_MIN == lastContentOffsetX) {
            lastContentOffsetX = scrollView.contentOffset.x;
            return;
        }
        
        CGFloat currentOffsetX = scrollView.contentOffset.x;
        CGFloat currentOffsetY = scrollView.contentOffset.y;
        
        CGFloat pageWidth = scrollView.frame.size.width;
        CGFloat offset = pageWidth * (_arr.count - 2);
        
        // the first page(showing the last item) is visible and user's finger is still scrolling to the right
        if (currentOffsetX < pageWidth && lastContentOffsetX > currentOffsetX) {
            lastContentOffsetX = currentOffsetX + offset;
            scrollView.contentOffset = (CGPoint){lastContentOffsetX, currentOffsetY};
        }
        // the last page (showing the first item) is visible and the user's finger is still scrolling to the left
        else if (currentOffsetX > offset && lastContentOffsetX < currentOffsetX) {
            lastContentOffsetX = currentOffsetX - offset;
            scrollView.contentOffset = (CGPoint){lastContentOffsetX, currentOffsetY};
        } else {
            lastContentOffsetX = currentOffsetX;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // scroll to the 2nd page, which is showing the first item.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // scroll to the first page, note that this call will trigger scrollViewDidScroll: once and only once
        [collectionViewNews scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    });
}

#pragma mark - UIInterfaceOrientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _indexPathForDeviceOrientation = [[collectionViewNews indexPathsForVisibleItems] firstObject];
    [[collectionViewNews collectionViewLayout] invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [collectionViewNews scrollToItemAtIndexPath:_indexPathForDeviceOrientation atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
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
    return _arr.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionViewNews dequeueReusableCellWithReuseIdentifier:@"cell1" forIndexPath:indexPath];
    UIImageView *img=(UIImageView*)[cell viewWithTag:20];
<<<<<<< HEAD
    img.image=[UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",(long)(indexPath.row+1)]];
=======
    UILabel *lbl = (UILabel *)[cell viewWithTag:21];
    lbl.text = @"Hello world!";
    UILabel *lbl1 = (UILabel *)[cell viewWithTag:22];
    lbl1.text = [NSString stringWithFormat:@"%@",_arr[indexPath.item]];
    img.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",_arr[indexPath.item]]];
>>>>>>> PoDara
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
