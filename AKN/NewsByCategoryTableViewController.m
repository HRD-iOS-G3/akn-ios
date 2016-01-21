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
@interface NewsByCategoryTableViewController ()<ConnectionManagerDelegate>
{
	NSURL *url;
	int cid;
	int sid;
	bool help; //finish fetching news -> help = false otherwise true
	UIActivityIndicatorView *indicatorFooter;
}
@property (strong, nonatomic) NSMutableArray<News *> *newsList;

@property int currentPageNumber;
@property int totalPages;

@end

@implementation NewsByCategoryTableViewController

- (IBAction)buttonSearchClicked:(id)sender {
	
	
}

-(void)viewWillDisappear:(BOOL)animated{
	
}
- (IBAction)actionBack:(id)sender {
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
	url =[NSURL URLWithString:[NSString stringWithFormat:@"http://akn.khmeracademy.org/api/article/1/10/%d/%d/0/", cid, sid]];
	
	[manager requestDataWithURL:url];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[self initializeRefreshControl];
}


-(void)initializeRefreshControl
{
	indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
	[indicatorFooter setColor:[UIColor blackColor]];
	[indicatorFooter startAnimating];
	[self.tableView setTableFooterView:indicatorFooter];
	
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (scrollView.contentOffset.y + scrollView.frame.size.height == scrollView.contentSize.height)
	{
		if (help) {
			help = false;
			[self refreshTableVeiwList];
		}
	}
}

-(void)refreshTableVeiwList
{
	//Code here
	NSLog(@"currentPage: %d, totalPage: %d", _currentPageNumber, _totalPages);
	if(_currentPageNumber >= _totalPages){
		[indicatorFooter stopAnimating];
	}else{
		_currentPageNumber++;
		url =[NSURL URLWithString:[NSString stringWithFormat:@"http://akn.khmeracademy.org/api/article/%d/10/%d/%d/0/", _currentPageNumber,cid, sid]];
		
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
	if ([URL.path isEqualToString:[NSString stringWithFormat:@"/api/article/%d/10/%d/%d/0", _currentPageNumber, cid, sid]]) {
		_totalPages = [[result valueForKeyPath:@"TOTAL_PAGES"] intValue];
		for (NSDictionary *object in [result valueForKeyPath:@"RESPONSE_DATA"]) {
			[_newsList addObject:[[News alloc]initWithData:object]];
		}
		help = true;
		[self.tableView reloadData];
		//		[indicatorFooter stopAnimating];
	}
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
//	cell.newsTitle.text=@"4th Generation Orientation at CKCC";
//	cell.newsView.text=@"300";
//	cell.newsDate.text=@"02-April-2015";
	[self configureCell:cell AtIndexPath:indexPath];
	return cell;
}

-(void)configureCell:(HomeViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath{
	cell.newsTitle.text=[NSString stringWithFormat:@"%@",_newsList[indexPath.row].newsTitle];
	cell.newsView.text=[NSString stringWithFormat:@"%@",_newsList[indexPath.row].newsHitCount];
	cell.newsDate.text=[NSString stringWithFormat:@"%@", [Utilities timestamp2date:_newsList[indexPath.row].newsDateTimestampString]];
	
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
		cell.newsImage.image = [UIImage imageNamed:@"akn-logo"];
		// download image in background
		[self downloadImageInBackground:self.newsList[indexPath.row] forIndexPath:indexPath];
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
