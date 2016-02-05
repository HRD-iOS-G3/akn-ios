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
#import "UIImageView+WebCache.h"

@interface SearchAllTableViewController () <ConnectionManagerDelegate>
{	
	UIActivityIndicatorView *indicatorFooter;
    ConnectionManager *manager;

}

// property
@property (strong, nonatomic) NSMutableArray<News *> *listNewsFound;
@property int currentPageNumber;
@property int totalPages;

@end

@implementation SearchAllTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set startup
    self.title = _searchKey;
    _currentPageNumber = 1;
    [self initializeRefreshControl];
    _listNewsFound = [NSMutableArray new];
    
    // get user id
     _userId = 0;
    if ([[NSUserDefaults standardUserDefaults]objectForKey: USER_DEFAULT_KEY]) {
        _userId = [[[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY] valueForKey:@"id"] intValue];
    }
    
    manager = [[ConnectionManager alloc]init];
    manager.delegate = self;
    
    // request news
    if (_listNewsFound.count == 0) {
        [self fetchNews];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if (_listNewsFound.count <= 0) {
        [SVProgressHUD show];
    }
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}


#pragma mark: - init footer refreshControl
-(void)initializeRefreshControl
{   // init footer refresh control when scroll down
	indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
	[indicatorFooter setColor:[UIColor blackColor]];
	[indicatorFooter stopAnimating];
	[self.tableView setTableFooterView:indicatorFooter];
	
}

// when scroll down to bottom load more data
-(void)refreshTableVeiwList
{
	if(_currentPageNumber >= _totalPages){
		[indicatorFooter stopAnimating];
	}else{
		_currentPageNumber++;
		[self fetchNews];
	}
    
    // set padding between last content box with bottom
	[self.tableView setContentOffset:(CGPointMake(0, self.tableView.contentOffset.y - indicatorFooter.frame.size.height + 5)) animated:YES];
}

// check when scroll to the bottom of footer
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

#pragma mark: - request news
-(void)fetchNews{
    NSDictionary * param = @{@"key":_searchKey,
                             @"page":[NSNumber numberWithInt:_currentPageNumber],
                             @"row":@10,
                             @"cid":[NSNumber numberWithInt:_cId],
                             @"sid":[NSNumber numberWithInt:_sId],
                             @"uid":[NSNumber numberWithInt:_userId]};
    
    [manager requestDataWithURL:SEARCH_NEWS data:param method:POST];
}

#pragma mark: - respone data
-(void)connectionManagerDidReturnResult:(NSArray *)result{
	[SVProgressHUD dismiss];
    
    // need news to temp array
	NSMutableArray<News *> *temp = [NSMutableArray new];
	for (NSDictionary *news in [result valueForKey:R_KEY_RESPONSE_DATA]) {
		[temp addObject:[[News alloc] initWithData:news]];
	}
    
	_totalPages = [[result valueForKey:@"TOTAL_PAGES"] intValue];
    
    // no record
	if (temp.count == 0) {
		if (_listNewsFound.count == 0) {
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/4, self.view.frame.size.width, 20)];
			label.textAlignment = NSTextAlignmentCenter;
			label.text = [NSString stringWithFormat:@"\"%@\" not found...!", _searchKey];
			[self.view insertSubview:label aboveSubview:self.tableView];
			
			// [[MainViewController getInstance].navigationController popViewControllerAnimated:YES];
		}else{
			[indicatorFooter stopAnimating];
		}
	}// have records
	else{
        // add record to list for display
		[_listNewsFound addObjectsFromArray:temp];
		
		help1 = true;
		[self.tableView reloadData];
	}
}

#pragma mark - back navigation button
- (IBAction)actionBack:(id)sender {
	[SVProgressHUD dismiss];
	MainViewController *mvc = [MainViewController getInstance];
	[mvc.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listNewsFound.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

#pragma mark - cellForRowAtIndexPath
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	cell.viewCell.layer.cornerRadius=5;
	cell.sourceImage.layer.cornerRadius=cell.sourceImage.frame.size.width/2;
	
	[self configureCell:cell AtIndexPath:indexPath];
	
    return cell;
}

#pragma mark - custom cell
-(void)configureCell:(HomeViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath{
    
    // set title, view, and date
	cell.newsTitle.text=[NSString stringWithFormat:@"%@",_listNewsFound[indexPath.row].newsTitle];
	cell.newsView.text=[NSString stringWithFormat:@"%d",_listNewsFound[indexPath.row].newsHitCount];
	cell.newsDate.text=[NSString stringWithFormat:@"%@", [Utilities timestamp2date:_listNewsFound[indexPath.row].newsDateTimestampString]];
	
    // set tag for save button
	cell.buttonSave.tag = indexPath.row;
	[cell.buttonSave addTarget:self action:@selector(buttonSaveClick1:) forControlEvents:UIControlEventTouchUpInside];
	
	// check save button state
	if (_listNewsFound[indexPath.row].saved) {
		[cell.buttonSave setEnabled:false];
		[cell.buttonSave setImage:[UIImage imageNamed:@"save-gray"] forState:UIControlStateNormal];
	}else{
		[cell.buttonSave setEnabled:true];
		[cell.buttonSave setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
	}
	
    // set image by source
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
	
    // set image to cell imageView
	if (_listNewsFound[indexPath.row].newsImage){
		cell.newsImage.image = _listNewsFound[indexPath.row].newsImage;
	}else{
		// download image
        [cell.newsImage sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:_listNewsFound[indexPath.row].newsImageUrl]
                                                 placeholderImage:[UIImage imageNamed:@"akn-logo-red"]
                                                          options:SDWebImageRefreshCached progress:nil
                                                        completed:nil];
	}
}

#pragma mark - didSelectRowAtIndexPath
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MainViewController *mvc = [MainViewController getInstance];
    DetailNewsTableViewController *dvc = [[UIStoryboard storyboardWithName:@"Detail" bundle:nil] instantiateViewControllerWithIdentifier:@"detailNews"];
    dvc.news = _listNewsFound[indexPath.row];
    dvc.pageTitle = @"";
    [mvc.navigationController pushViewController:dvc animated:YES];
}

#pragma mark - save news button event
-(void)buttonSaveClick1:(UIButton *)sender{
    
    // if user already login
	if ([[NSUserDefaults standardUserDefaults]objectForKey:@"user"]) {
		[sender setImage:[UIImage imageNamed:@"save-gray"] forState:UIControlStateNormal];
		
        NSDictionary * param = @{@"newsid":[NSNumber numberWithInt:_listNewsFound[sender.tag].newsId],
                                 @"userid":[NSNumber numberWithInt:_userId]};
        NSLog(@"%@", param);

        [manager requestDataWithURL:SAVE_LIST data:param method:POST];
        
        [[MainViewController getInstance].navigationController.view makeToast:@"Saved!"
																	 duration:2.0
																	 position:CSToastPositionBottom];
	}else{ // else have to login
		[[MainViewController getInstance].navigationController.view makeToast:@"Please login first!"
																	 duration:3.0
																	 position:CSToastPositionBottom];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
