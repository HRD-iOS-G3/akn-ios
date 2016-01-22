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
#import "ConnectionManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "News.h"
#import "Utilities.h"
#import "UIView+Toast.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface TablePageViewController ()<UICollectionViewDataSource,UIScrollViewDelegate, ConnectionManagerDelegate>{
	
    __weak IBOutlet UICollectionView *collectionViewNews;
    __weak IBOutlet UICollectionViewFlowLayout *collection;
    CGFloat kTableHeaderHeight;
    UIView *headerView;
	
	
	__strong IBOutlet UIView *viewIndicatorTop;
	__weak IBOutlet UIView *viewIndicator;
	UIView *viewIndiTop;
	
	UIActivityIndicatorView *indicatorFooter;
	
	ConnectionManager *manager;
	
	NSMutableArray *countHelp;
	int userId;
}
@property (strong, nonatomic) NSMutableArray<News *> *newsList;
@property (strong, nonatomic) NSMutableArray<News *> *popularNewsList;

@property int currentPageNumber;
@property int totalPages;

@end

@implementation TablePageViewController

NSString *khmeracademy = @"http://akn.khmeracademy.org";

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
	_popularNewsList = [[NSMutableArray alloc]init];
	_newsList = [[NSMutableArray alloc]init];
	
	manager = [[ConnectionManager alloc]init];
	manager.delegate = self;
	
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

	//set current page n rows
	_currentPageNumber =1;
	[self initializeRefreshControl];
	
	// pull to refresh
	viewIndiTop=[[UIView alloc]initWithFrame:CGRectMake(0,-37, self.view.frame.size.width, 37)];
	viewIndiTop.backgroundColor=[UIColor clearColor];
	[viewIndicator addSubview:viewIndiTop];
	[viewIndiTop addSubview:viewIndicatorTop];
//	viewIndicatorTop.tag =101;
	
	userId = 0;
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
		userId = [[[[NSUserDefaults standardUserDefaults]objectForKey:@"user"] valueForKey:@"id"]intValue];
	}
	
	[SVProgressHUD show];
}
-(void)initializeRefreshControl
{
		indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
		[indicatorFooter setColor:[UIColor blackColor]];
//		[indicatorFooter startAnimating];
		[self.tableView setTableFooterView:indicatorFooter];
	
}
bool help = true;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (scrollView == self.tableView) {
		if (scrollView.contentOffset.y + scrollView.frame.size.height == scrollView.contentSize.height)
		{
			[indicatorFooter startAnimating];
			if (help) {
				help = false;
				[self refreshTableVeiwList];
			}
		}else{
			[self updateHeaderView];
		}
 
		CGFloat y=-scrollView.contentOffset.y;
		
		
		if (y>310 && viewIndicatorTop.tag!=100) {
			
			[UIView animateWithDuration:0.3 animations:^{
				[viewIndiTop setFrame:CGRectMake(viewIndicatorTop.frame.origin.x,0, viewIndicator.frame.size.width, viewIndiTop.frame.size.height)];
			} completion:^(BOOL finished) {
				// request data
				[self refreshData];
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
		CGFloat offset = pageWidth * (_popularNewsList.count - 2);
		
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

-(void)refreshData{
	_currentPageNumber = 1;
	viewIndicatorTop.tag = 101;
	
	[manager requestDataWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/article/%d/10/0/0/%d/",khmeracademy, _currentPageNumber, userId]]];
	[manager requestDataWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/article/1/5/0/0/%d/",khmeracademy, userId]]];
	
}

-(void)refreshTableVeiwList
{
	//Code here
	
	if(_currentPageNumber >= _totalPages){
		[indicatorFooter stopAnimating];
	}else{
		_currentPageNumber++;
		[self fetchNews];
	}
	
//	[self.tableView setContentOffset:(CGPointMake(0,self.tableView.contentOffset.y-indicatorFooter.frame.size.height)) animated:YES];
}
-(void)fetchNews{
	//Create connection manager
//	ConnectionManager *manager = [[ConnectionManager alloc] init];
//	
//	manager.delegate = self;
	[manager requestDataWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/article/%d/10/0/0/%d/", khmeracademy,_currentPageNumber,userId]]];
}
-(void)viewWillDisappear:(BOOL)animated{
	[SVProgressHUD dismiss];
}
-(void)viewDidAppear:(BOOL)animated{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
		userId = [[[[NSUserDefaults standardUserDefaults]objectForKey:@"user"] valueForKey:@"id"]intValue];
	}
	if (_popularNewsList.count == 0) {
		[SVProgressHUD show];
	}
	[manager requestDataWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/article/%d/10/0/0/%d/", khmeracademy,_currentPageNumber,userId]]];
	[manager requestDataWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/article/1/5/0/0/%d/",khmeracademy, userId]]];
}

-(void)connectionManagerDidReturnResult:(NSArray *)result FromURL:(NSURL *)URL{
	NSLog(@"%@" , URL.path);
	if (viewIndicatorTop.tag == 101) { // refresh data
		
		[SVProgressHUD dismiss];
		
		if ([URL.path isEqualToString:[NSString stringWithFormat:@"/api/article/%d/10/0/0/%d", _currentPageNumber, userId]]) {
			_totalPages = [[result valueForKeyPath:@"TOTAL_PAGES"] intValue];
			NSMutableArray<News *> *tmp = [NSMutableArray new];
			for (NSDictionary *object in [result valueForKeyPath:@"RESPONSE_DATA"]) {
				[tmp addObject:[[News alloc]initWithData:object]];
			}
			help = true;
			[_newsList removeAllObjects];
			[_newsList addObjectsFromArray:tmp];
			
			[self.tableView reloadData];
		}
		//	if ([URL.path isEqualToString:@"/api/article/popular/0"]) {
		if ([URL.path isEqualToString:[NSString stringWithFormat:@"/api/article/1/5/0/0/%d", userId]]) {
			
			NSMutableArray<News *> *tmp = [NSMutableArray new];
			for (NSDictionary *object in [result valueForKeyPath:@"RESPONSE_DATA"]) {
				[tmp addObject:[[News alloc]initWithData:object]];
			}
			[_popularNewsList removeAllObjects];
			[_popularNewsList addObjectsFromArray:tmp];
			[self->collectionViewNews reloadData];
			
			id firstItem = [_popularNewsList firstObject];
			id lastItem = [_popularNewsList lastObject];
			NSMutableArray *workingArray = [_popularNewsList mutableCopy];
			[workingArray insertObject:lastItem atIndex:0];
			[workingArray addObject:firstItem];
			
			_popularNewsList = workingArray;
			
			countHelp = [NSMutableArray new];
			for (int i=1; i<_popularNewsList.count-1; i++) {
				[countHelp addObject:[NSNumber numberWithInt:i]];
			}
			if (countHelp.count <= _popularNewsList.count) {
				[countHelp addObjectsFromArray:countHelp];
			}
		}
		
		[UIView animateWithDuration:0.3 animations:^{
			[viewIndiTop setFrame:CGRectMake(viewIndicatorTop.frame.origin.x,-37, viewIndicator.frame.size.width, viewIndiTop.frame.size.height)];
		} completion:^(BOOL finished) {
			viewIndicatorTop.tag = 102;
		}];
	}
	else{
		if ([URL.path isEqualToString:[NSString stringWithFormat:@"/api/article/%d/10/0/0/%d", _currentPageNumber, userId]]) {
			_totalPages = [[result valueForKeyPath:@"TOTAL_PAGES"] intValue];
			for (NSDictionary *object in [result valueForKeyPath:@"RESPONSE_DATA"]) {
				[_newsList addObject:[[News alloc]initWithData:object]];
			}
			help = true;
			[self.tableView reloadData];
		}
		//	if ([URL.path isEqualToString:@"/api/article/popular/0"]) {
		else if([URL.path isEqualToString:[NSString stringWithFormat:@"/api/article/1/5/0/0/%d",userId]]) {
			
			for (NSDictionary *object in [result valueForKeyPath:@"RESPONSE_DATA"]) {
				[_popularNewsList addObject:[[News alloc]initWithData:object]];
			}
			[self->collectionViewNews reloadData];
			
			id firstItem = [_popularNewsList firstObject];
			id lastItem = [_popularNewsList lastObject];
			NSMutableArray *workingArray = [_popularNewsList mutableCopy];
			[workingArray insertObject:lastItem atIndex:0];
			[workingArray addObject:firstItem];
			
			_popularNewsList = workingArray;
			
			countHelp = [NSMutableArray new];
			for (int i=1; i<_popularNewsList.count-1; i++) {
				[countHelp addObject:[NSNumber numberWithInt:i]];
			}
			[countHelp addObjectsFromArray:countHelp];
		}
		if (_newsList.count > 0 && _popularNewsList.count > 0) {
			[SVProgressHUD dismiss];
		}
	}
}
-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
	NSLog(@"%@",result);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _newsList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.viewCell.layer.cornerRadius=5;
    cell.sourceImage.layer.cornerRadius=cell.sourceImage.frame.size.width/2;

	[self configureCell:cell AtIndexPath:indexPath];

//	cell.newsTitle.text = @"Hello world!";
//	cell.newsView.text = @"213";
//	cell.newsDate.text =@"12-12-2014";
	
    return cell;
}

-(void)configureCell:(HomeViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath{
	cell.newsTitle.text=[NSString stringWithFormat:@"%@",_newsList[indexPath.row].newsTitle];
	cell.newsView.text=[NSString stringWithFormat:@"%@",_newsList[indexPath.row].newsHitCount];
	cell.newsDate.text=[NSString stringWithFormat:@"%@", [Utilities timestamp2date:_newsList[indexPath.row].newsDateTimestampString]];
	
	cell.buttonSave.tag = indexPath.row;
	[cell.buttonSave addTarget:self action:@selector(buttonSaveClick:) forControlEvents:UIControlEventTouchUpInside];
	
	if (_newsList[indexPath.row].saved) {
		[cell.buttonSave setEnabled:false];
		[cell.buttonSave setImage:[UIImage imageNamed:@"save-gray"] forState:UIControlStateNormal];
	}else{
		[cell.buttonSave setEnabled:true];
		[cell.buttonSave setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
	}
	
	switch (_newsList[indexPath.row].newsSourceId) {
			
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
	
	if (self.newsList[indexPath.row].newsImage){
		cell.newsImage.image = self.newsList[indexPath.row].newsImage;
	}else{
		cell.newsImage.image = [UIImage imageNamed:@"akn-logo-red"];
		// download image in background
		[self downloadImageInBackground:self.newsList[indexPath.row] forIndexPath:indexPath];
	}
}
-(void)buttonSaveClick:(UIButton *)sender{
	if ([[NSUserDefaults standardUserDefaults]objectForKey:@"user"]) {
		[sender setImage:[UIImage imageNamed:@"save-gray"] forState:UIControlStateNormal];
		
		ConnectionManager *m = [[ConnectionManager alloc]init];
		m.delegate = self;
		
		[m requestDataWithURL:@{@"newsid":[NSNumber numberWithInt:_newsList[sender.tag].newsId], @"userid":[NSNumber numberWithInt:userId]} withKey:@"/api/article/savelist" method:@"POST"];
		[[MainViewController getInstance].navigationController.view makeToast:@"Saved!"
																	 duration:2.0
																	 position:CSToastPositionBottom];
	}else{
		
		[[MainViewController getInstance].navigationController.view makeToast:@"Please login first!"
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
			self.newsList[indexPath.row].newsImage = [UIImage imageWithData:dataImage];
			cell.newsImage.image = self.newsList[indexPath.row].newsImage;
		});
	});
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	MainViewController *mvc = [MainViewController getInstance];
	DetailNewsTableViewController *dvc = [[UIStoryboard storyboardWithName:@"Detail" bundle:nil] instantiateViewControllerWithIdentifier:@"detailNews"];
	dvc.news = (News *)_newsList[indexPath.row];
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


#pragma mark - Collection View delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	
	MainViewController *mvc = [MainViewController getInstance];
	DetailNewsTableViewController *dvc = [[UIStoryboard storyboardWithName:@"Detail" bundle:nil] instantiateViewControllerWithIdentifier:@"detailNews"];
	dvc.pageTitle = @"Popular News";
	dvc.news = _popularNewsList[indexPath.row];
	[mvc.navigationController pushViewController:dvc animated:YES];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _popularNewsList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionViewNews dequeueReusableCellWithReuseIdentifier:@"cell1" forIndexPath:indexPath];
    UIImageView *img=(UIImageView*)[cell viewWithTag:20];
	UILabel *label = (UILabel *)[cell viewWithTag:21];
	label.text = self.popularNewsList[indexPath.row].newsTitle;
	UILabel *labelNum = (UILabel *)[cell viewWithTag:22];
	labelNum.text = [NSString stringWithFormat:@"%@",countHelp[indexPath.row]];
	
	
	if (self.popularNewsList[indexPath.row].newsImage){
		img.image = self.popularNewsList[indexPath.row].newsImage;
	}else{
		img.image = [UIImage imageNamed:@"akn-logo-red"];
		// download image in background
		dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
		
		dispatch_async(concurrentQueue, ^{
			__block NSData *dataImage = nil;
			
			dispatch_sync(concurrentQueue, ^{
				NSURL *urlImage = [NSURL URLWithString:self.popularNewsList[indexPath.row].newsImageUrl];
				dataImage = [NSData dataWithContentsOfURL:urlImage];
			});
			
			dispatch_async(dispatch_get_main_queue(), ^{
				self.popularNewsList[indexPath.row].newsImage = [UIImage imageWithData:dataImage];
				img.image = self.popularNewsList[indexPath.row].newsImage;
			});
		});
	}
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
