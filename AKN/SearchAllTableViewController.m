//
//  SearchAllTableViewController.m
//  AKN
//
//  Created by Ponnreay on 1/21/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "SearchAllTableViewController.h"
#import "HomeViewCell.h"
#import "ConnectionManager.h"
#import "MainViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "Utilities.h"
#import "News.h"
#import "DetailNewsTableViewController.h"
#import "UIView+Toast.h"

@interface SearchAllTableViewController () <ConnectionManagerDelegate>
{	
	UIActivityIndicatorView *indicatorFooter;

}
@property (strong, nonatomic) NSMutableArray<News *> *listNewsFound;


@property int currentPageNumber;
@property int totalPages;

@end

@implementation SearchAllTableViewController

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
}

-(void)initializeRefreshControl
{
	indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
	[indicatorFooter setColor:[UIColor blackColor]];
	[indicatorFooter stopAnimating];
	[self.tableView setTableFooterView:indicatorFooter];
	
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
	ConnectionManager *manager = [[ConnectionManager alloc] init];
	manager.delegate = self;
	[manager requestDataWithURL:@{@"key":_searchKey, @"page":[NSNumber numberWithInt:_currentPageNumber], @"row":@10, @"cid":[NSNumber numberWithInt:_cId], @"sid":[NSNumber numberWithInt:_sId], @"uid":[NSNumber numberWithInt:_userId]} withKey:@"/api/article/search" method:@"POST"];
}

bool help1 = true;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (scrollView == self.tableView) {
		if (scrollView.contentOffset.y + scrollView.frame.size.height == scrollView.contentSize.height)
		{
			[indicatorFooter startAnimating];
			if (help1) {
				help1 = false;
				[self refreshTableVeiwList];
			}
		}
	}
}

-(void)connectionManagerDidReturnResult:(NSArray *)result{
	[SVProgressHUD dismiss];
	NSLog(@"%@",result);
	NSMutableArray<News *> *temp = [NSMutableArray new];
	for (NSDictionary *news in [result valueForKey:@"RESPONSE_DATA"]) {
		[temp addObject:[[News alloc] initWithData:news]];
	}
	_totalPages = [[result valueForKey:@"TOTAL_PAGES"] intValue];
	if (temp.count == 0) {
		if (_listNewsFound.count == 0) {
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/4, self.view.frame.size.width, 20)];
			label.textAlignment = NSTextAlignmentCenter;
			label.text = [NSString stringWithFormat:@"\"%@\" not found...!", _searchKey];
			[self.view insertSubview:label aboveSubview:self.tableView];
			
			//		[[MainViewController getInstance].navigationController popViewControllerAnimated:YES];
		}else{
			[indicatorFooter stopAnimating];
		}
	}
	else{
		[_listNewsFound addObjectsFromArray:temp];
		
		help1 = true;
		[self.tableView reloadData];
	}
}

- (IBAction)actionBack:(id)sender {
	[SVProgressHUD dismiss];
	MainViewController *mvc = [MainViewController getInstance];
	[mvc.navigationController popViewControllerAnimated:YES];
}
-(void)viewDidAppear:(BOOL)animated{
	if (_listNewsFound.count <= 0) {
		[SVProgressHUD show];
	}
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.title = _searchKey;
	_currentPageNumber = 1;
	[self initializeRefreshControl];
	_listNewsFound = [NSMutableArray new];
	
	int userId = 0;
	if ([[NSUserDefaults standardUserDefaults]objectForKey:@"user"]) {
		userId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] valueForKey:@"id"] intValue];
	}
	
	if (_listNewsFound.count == 0) {
		ConnectionManager *manager = [ConnectionManager new];
		manager.delegate = self;
		[manager requestDataWithURL:@{@"key":_searchKey, @"page":[NSNumber numberWithInt:_currentPageNumber], @"row":@10, @"cid":[NSNumber numberWithInt:_cId], @"sid":[NSNumber numberWithInt:_sId], @"uid":[NSNumber numberWithInt:_userId]} withKey:@"/api/article/search" method:@"POST"];
		
	}
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listNewsFound.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	cell.viewCell.layer.cornerRadius=5;
	cell.sourceImage.layer.cornerRadius=cell.sourceImage.frame.size.width/2;
	
	[self configureCell:cell AtIndexPath:indexPath];
	
    
    return cell;
}

-(void)configureCell:(HomeViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath{
	cell.newsTitle.text=[NSString stringWithFormat:@"%@",_listNewsFound[indexPath.row].newsTitle];
	cell.newsView.text=[NSString stringWithFormat:@"%d",_listNewsFound[indexPath.row].newsHitCount];
	cell.newsDate.text=[NSString stringWithFormat:@"%@", [Utilities timestamp2date:_listNewsFound[indexPath.row].newsDateTimestampString]];
	
	cell.buttonSave.tag = indexPath.row;
	[cell.buttonSave addTarget:self action:@selector(buttonSaveClick1:) forControlEvents:UIControlEventTouchUpInside];
	
	
	if (_listNewsFound[indexPath.row].saved) {
		[cell.buttonSave setEnabled:false];
		[cell.buttonSave setImage:[UIImage imageNamed:@"save-gray"] forState:UIControlStateNormal];
	}else{
		[cell.buttonSave setEnabled:true];
		[cell.buttonSave setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
	}
	
	switch (_listNewsFound[indexPath.row].newsSourceId) {
			
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
	
	if (_listNewsFound[indexPath.row].newsImage){
		cell.newsImage.image = _listNewsFound[indexPath.row].newsImage;
	}else{
		cell.newsImage.image = [UIImage imageNamed:@"akn-logo"];
		// download image in background
		[self downloadImageInBackground:_listNewsFound[indexPath.row] forIndexPath:indexPath];
	}
	
}

-(void)buttonSaveClick1:(UIButton *)sender{
	if ([[NSUserDefaults standardUserDefaults]objectForKey:@"user"]) {
		[sender setImage:[UIImage imageNamed:@"save-gray"] forState:UIControlStateNormal];
		
		ConnectionManager *m = [[ConnectionManager alloc]init];
		m.delegate = self;
		NSLog(@"Clicked!");
		[m requestDataWithURL:@{@"newsid":[NSNumber numberWithInt:_listNewsFound[sender.tag].newsId], @"userid":[NSNumber numberWithInt:_userId]} withKey:@"/api/article/savelist" method:@"POST"];
		[[MainViewController getInstance].navigationController.view makeToast:@"Saved!"
																	 duration:2.0
																	 position:CSToastPositionBottom];
	}else{
		
		[[MainViewController getInstance].navigationController.view makeToast:@"Please login first!"
																	 duration:3.0
																	 position:CSToastPositionBottom];
	}
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 120;
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
			_listNewsFound[indexPath.row].newsImage = [UIImage imageWithData:dataImage];
			cell.newsImage.image = _listNewsFound[indexPath.row].newsImage;
		});
	});
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	MainViewController *mvc = [MainViewController getInstance];
	DetailNewsTableViewController *dvc = [[UIStoryboard storyboardWithName:@"Detail" bundle:nil] instantiateViewControllerWithIdentifier:@"detailNews"];
	dvc.news = _listNewsFound[indexPath.row];
	dvc.pageTitle = @"";
	[mvc.navigationController pushViewController:dvc animated:YES];
}


@end
