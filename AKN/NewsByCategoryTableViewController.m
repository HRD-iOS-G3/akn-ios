//
//  NewsByCategoryTableViewController.m
//  AKN
//
//  Created by Korea Software HRD Center on 1/11/16.
//  Copyright © 2016 kshrd. All rights reserved.
//

#import "NewsByCategoryTableViewController.h"
#import "HomeViewCell.h"
#import "MainViewController.h"
#import "DetailNewsTableViewController.h"
#import "ConnectionManager.h"
#import "News.h"
#import "Utilities.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIView+Toast.h"
#import "SearchAllTableViewController.h"
@interface NewsByCategoryTableViewController ()<ConnectionManagerDelegate, UISearchBarDelegate>
{
	NSURL *url;
	int cid;
	int sid;
	int userId;
	bool help; //finish fetching news -> help = false otherwise true
	UIActivityIndicatorView *indicatorFooter;
	
	NSTimer *searchDelayer;
	UIView *disableViewOverlay;
	NSString *searchString;
}
@property (strong, nonatomic) NSMutableArray<News *> *newsList;

@property int currentPageNumber;
@property int totalPages;

@property (nonatomic, strong) UIBarButtonItem *searchItem;
@property (nonatomic, strong) UISearchBar *searchBarField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end

@implementation NewsByCategoryTableViewController

- (IBAction)buttonSearchClicked:(id)sender {
	[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
	[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"X"];
	self.searchBarField.placeholder=[NSString stringWithFormat:@"Search news of this %@",([_categoryOrSource valueForKey:@"url"])?@"site":@"category"];
	self.searchBarField.searchBarStyle=UISearchBarStyleMinimal;
	UITextField *textFieldInsideSearchBar =[self.searchBarField valueForKey:@"searchField"];
	textFieldInsideSearchBar.textColor=[UIColor whiteColor];
	[UIView animateWithDuration:0.1 animations:^{
		self.searchButton.alpha = 0.0f;
		
		
	} completion:^(BOOL finished) {
		
		// remove the search button
		self.navigationItem.rightBarButtonItem = nil;
		// add the search bar (which will start out hidden).
		self.navigationItem.titleView = _searchBarField;
		_searchBarField.alpha = 0.0;
		
		[UIView animateWithDuration:0.02
						 animations:^{
							 _searchBarField.alpha = 1.0;
						 } completion:^(BOOL finished) {
							 [_searchBarField becomeFirstResponder];
						 }];
		
	}];
	
}
#pragma mark UISearchBarDelegate methods
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
	[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"X"];
	self.searchBarField.placeholder=[NSString stringWithFormat:@"Search news of this %@",([_categoryOrSource valueForKey:@"url"])?@"site":@"category"];
	self.searchBarField.searchBarStyle=UISearchBarStyleMinimal;
	UITextField *textFieldInsideSearchBar =[self.searchBarField valueForKey:@"searchField"];
	textFieldInsideSearchBar.textColor=[UIColor whiteColor];
	[UIView animateWithDuration:0.1f animations:^{
		_searchBarField.alpha = 0.0;
	} completion:^(BOOL finished) {
		self.navigationItem.titleView = nil;
		self.navigationItem.rightBarButtonItem = _searchItem;
		_searchButton.alpha = 0.0;  // set this *after* adding it back
		[UIView animateWithDuration:0.2f animations:^ {
			_searchButton.alpha = 1.0;
		}];
	}];
	[disableViewOverlay removeFromSuperview];
	self.searchBarField.text=@"";
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	NSLog(@"searchBarSearchButtonClicked");
	[disableViewOverlay removeFromSuperview];
	//[self searchBarTextDidEndEditing:searchBar];
	[self.searchBarField endEditing:YES];
	
	
	MainViewController *mvc = [MainViewController getInstance];
	SearchAllTableViewController *svc = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateViewControllerWithIdentifier:@"search"];
	svc.searchKey = searchString;
	svc.userId = userId;
	svc.cId = cid;
	svc.sId = sid;
	
	[mvc.navigationController pushViewController:svc animated:YES];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	disableViewOverlay.alpha = 0;
	[self.view addSubview:disableViewOverlay];
	
	[UIView beginAnimations:@"FadeIn" context:nil];
	[UIView setAnimationDuration:0.5];
	disableViewOverlay.alpha = 0.6;
	[UIView commitAnimations];
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
	//    NSLog(@"End work");
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	searchString = searchText;
	[searchDelayer invalidate], searchDelayer=nil;
	if (YES /* ...or whatever validity test you want to apply */)
		searchDelayer = [NSTimer scheduledTimerWithTimeInterval:1.5
														 target:self
													   selector:@selector(doDelayedSearch:)
													   userInfo:searchText
														repeats:NO];
}
-(void)doDelayedSearch:(NSTimer *)t
{
	assert(t == searchDelayer);
	[self request:searchDelayer.userInfo];
	searchDelayer = nil; // important because the timer is about to release and dealloc itself
}
-(void)request:(NSString *)myString{
	//    NSLog(@"%@",myString);
}
-(void)viewDidAppear:(BOOL)animated{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
		userId = [[[[NSUserDefaults standardUserDefaults]objectForKey:@"user"] valueForKey:@"id"]intValue];
	}
	if (_newsList.count ==0) {
		[SVProgressHUD show];
	}
}
- (IBAction)actionBack:(id)sender {
	[SVProgressHUD dismiss];
	[MainViewController getInstance].title = @"ALL KHMER NEWS";
	[[MainViewController getInstance].navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _pageTitle;
	help = true;
	
	//set current page n rows
	_currentPageNumber = 1;
	_newsList = [[NSMutableArray<News *> alloc]init];
	
	ConnectionManager *manager = [ConnectionManager new];
	manager.delegate = self;
	
	//if it have url, means that it's site screen
	if ([_categoryOrSource valueForKey:@"url"]) {
		cid = 0;
		sid = [[_categoryOrSource valueForKey:@"id"] intValue];
	}else{
		cid = [[_categoryOrSource valueForKey:@"id"] intValue];
		sid = 0;
	}
	userId = 0;
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
		userId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] valueForKey:@"id"] intValue];
	}
	url =[NSURL URLWithString:[NSString stringWithFormat:@"http://akn.khmeracademy.org/api/article/1/10/%d/%d/%d/", cid, sid, userId]];
	
	[manager requestDataWithURL:url];
	[self initializeRefreshControl];
	
	//search bar
	
	//self.searchItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
	self.searchItem = [[UIBarButtonItem alloc] initWithCustomView:_searchButton];
	self.navigationItem.rightBarButtonItem = _searchItem;
	
	self.navigationItem.rightBarButtonItem = _searchItem;
	
	self.searchBarField = [[UISearchBar alloc] init];
	_searchBarField.showsCancelButton = YES;
	_searchBarField.delegate = self;
	disableViewOverlay = [[UIView alloc]
						  initWithFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height)];
	disableViewOverlay.backgroundColor=[UIColor blackColor];
	disableViewOverlay.alpha = 0;
}

#pragma - Mark Search bar



-(void)initializeRefreshControl
{
	indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
	[indicatorFooter setColor:[UIColor blackColor]];
//	[indicatorFooter startAnimating];
	[self.tableView setTableFooterView:indicatorFooter];
	
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (scrollView.contentOffset.y + scrollView.frame.size.height == scrollView.contentSize.height)
	{
		[indicatorFooter startAnimating];
		if (help) {
			help = false;
			[self refreshTableVeiwList];
		}
	}
}

-(void)refreshTableVeiwList
{
	if(_currentPageNumber >= _totalPages){
		[indicatorFooter stopAnimating];
	}else{
		_currentPageNumber++;
		url =[NSURL URLWithString:[NSString stringWithFormat:@"http://akn.khmeracademy.org/api/article/%d/10/%d/%d/%d/", _currentPageNumber,cid, sid, userId]];
		
		[self fetchNews];
	}

	//	[self.tableView setContentOffset:(CGPointMake(0,self.tableView.contentOffset.y-indicatorFooter.frame.size.height)) animated:YES];
}
-(void)fetchNews{
	//Create connection manager
	ConnectionManager *manager = [[ConnectionManager alloc] init];

	manager.delegate = self;
	[manager requestDataWithURL:url];
}


-(void)connectionManagerDidReturnResult:(NSArray *)result FromURL:(NSURL *)URL{
	NSLog(@"%@" , URL.path);
	if ([URL.path isEqualToString:[NSString stringWithFormat:@"/api/article/%d/10/%d/%d/%d", _currentPageNumber, cid, sid, userId]]) {
		_totalPages = [[result valueForKeyPath:@"TOTAL_PAGES"] intValue];
		for (NSDictionary *object in [result valueForKeyPath:@"RESPONSE_DATA"]) {
			[_newsList addObject:[[News alloc]initWithData:object]];
		}
		if (_newsList.count == 0) {
			[SVProgressHUD dismiss];
			[self.navigationController.view makeToast:@"No news found!" duration:3 position:CSToastPositionCenter];
		}else{
			help = true;
			[SVProgressHUD dismiss];
			[self.tableView reloadData];
			//		[indicatorFooter stopAnimating];
		}
	}
}
-(void)connectionManagerDidReturnResult:(NSDictionary *)result{
	NSLog(@"%@",result);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	NSLog(@"%d", _newsList.count);
    return _newsList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsByCategoryCell"];
	cell.viewCell.layer.cornerRadius=5;
	cell.sourceImage.layer.cornerRadius=cell.sourceImage.frame.size.width/2;

	[self configureCell:cell AtIndexPath:indexPath];
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
		[sender setEnabled:false];
		_newsList[sender.tag].saved = true;
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 126;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	MainViewController *mvc = [MainViewController getInstance];
	DetailNewsTableViewController *dvc = [[UIStoryboard storyboardWithName:@"Detail" bundle:nil] instantiateViewControllerWithIdentifier:@"detailNews"];
	dvc.pageTitle = _pageTitle;
	dvc.news = _newsList[indexPath.row];
	[mvc.navigationController pushViewController:dvc animated:YES];
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
