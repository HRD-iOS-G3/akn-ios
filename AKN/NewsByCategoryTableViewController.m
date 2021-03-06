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
#import "UIImageView+WebCache.h"
#import <Google/Analytics.h>

@interface NewsByCategoryTableViewController ()<ConnectionManagerDelegate, UISearchBarDelegate>
{
    NSString * url;
    int cid;
    int sid;
    int userId;
    bool help; //finish fetching news -> help = false otherwise true
    UIActivityIndicatorView *indicatorFooter;
    
    NSTimer *searchDelayer;
    UIView *disableViewOverlay;
    NSString *searchString;
    
    ConnectionManager *manager;
}

@property (strong, nonatomic) NSMutableArray<News *> *newsList;

@property int currentPageNumber;
@property int totalPages;

@property (nonatomic, strong) UIBarButtonItem *searchItem;
@property (nonatomic, strong) UISearchBar *searchBarField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end

@implementation NewsByCategoryTableViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"Site~Category Screen"];
    
    // Previous V3 SDK versions
    // [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


-(void)viewDidAppear:(BOOL)animated{
    if (_newsList.count ==0) {
        [SVProgressHUD show];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set title
    self.title = _pageTitle;
    help = true;
    
    //set current page n rows
    _currentPageNumber = 1;
    _newsList = [[NSMutableArray<News *> alloc]init];
    
    manager = [ConnectionManager new];
    manager.delegate = self;
    
    //if it have url, means that it's site screen
    if ([_categoryOrSource valueForKey:@"url"]) {
        cid = 0;
        sid = [[_categoryOrSource valueForKey:@"id"] intValue];
    }else{
        cid = [[_categoryOrSource valueForKey:@"id"] intValue];
        sid = 0;
    }
    
    // set user id
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY]) {
        userId = [[[[NSUserDefaults standardUserDefaults]objectForKey:USER_DEFAULT_KEY] valueForKey:@"id"]intValue];
    }
    
    url = [NSString stringWithFormat:@"%@/1/10/%d/%d/%d/", GET_ARTICLE, cid, sid, userId];
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

#pragma mark - Mark Search bar
-(void)initializeRefreshControl
{
    indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
    [indicatorFooter setColor:[UIColor blackColor]];
    //	[indicatorFooter startAnimating];
    [self.tableView setTableFooterView:indicatorFooter];
    
}

#pragma mark - search event
- (IBAction)buttonSearchClicked:(id)sender {
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"X"];
    self.searchBarField.placeholder=[NSString stringWithFormat:@"Search news of this %@",([_categoryOrSource valueForKey:@"url"])?@"site":@"category"];
    self.searchBarField.searchBarStyle=UISearchBarStyleMinimal;
    UITextField *textFieldInsideSearchBar =[self.searchBarField valueForKey:@"searchField"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchBarCancelButtonClicked:)];
    [disableViewOverlay addGestureRecognizer:tap];
    
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
#pragma mark - search button cancle event
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

#pragma mark - search bar event
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarSearchButtonClicked");
    [disableViewOverlay removeFromSuperview];

    [self.searchBarField endEditing:YES];
    
    MainViewController *mvc = [MainViewController getInstance];
    SearchAllTableViewController *svc = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateViewControllerWithIdentifier:@"search"];
    svc.searchKey = searchString;
    svc.userId = userId;
    svc.cId = cid;
    svc.sId = sid;
    
    [mvc.navigationController pushViewController:svc animated:YES];
}

#pragma mark - searchBar
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

-(void)doDelayedSearch:(NSTimer *)timer
{
    assert(timer == searchDelayer);
    [self request:searchDelayer.userInfo];
    searchDelayer = nil; // important because the timer is about to release and dealloc itself
}

-(void)request:(NSString *)myString{
    //    NSLog(@"%@",myString);
}

- (IBAction)actionBack:(id)sender {
    [SVProgressHUD dismiss];
    [MainViewController getInstance].title = @"ALL KHMER NEWS";
    [[MainViewController getInstance].navigationController popViewControllerAnimated:YES];
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

#pragma mark - searchBar
-(void)refreshTableVeiwList
{
    if(_currentPageNumber >= _totalPages){
        [indicatorFooter stopAnimating];
    }else{
        _currentPageNumber++;
        url = [NSString stringWithFormat:@"%@/%d/10/%d/%d/%d/", GET_ARTICLE, _currentPageNumber,cid, sid, userId];
        
        [self fetchNews];
    }
    
    //	[self.tableView setContentOffset:(CGPointMake(0,self.tableView.contentOffset.y-indicatorFooter.frame.size.height)) animated:YES];
}

#pragma mark - request news
-(void)fetchNews{
    [manager requestDataWithURL:url];
}

#pragma mark - respone category news
-(void)connectionManagerDidReturnResult:(NSArray *)result FromURL:(NSURL *)URL{
    NSLog(@"%@" , URL.path);
    if ([URL.path isEqualToString:[NSString stringWithFormat:@"%@/%d/10/%d/%d/%d", GET_ARTICLE,_currentPageNumber, cid, sid, userId]]) {
        _totalPages = [[result valueForKeyPath:@"TOTAL_PAGES"] intValue];
        for (NSDictionary *object in [result valueForKeyPath:R_KEY_RESPONSE_DATA]) {
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
    cell.newsView.text=[NSString stringWithFormat:@"%d",_newsList[indexPath.row].newsHitCount];
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
        // download image
        [cell.newsImage sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:self.newsList[indexPath.row].newsImageUrl]
                                                 placeholderImage:[UIImage imageNamed:@"akn-logo-red"]
                                                          options:SDWebImageRefreshCached progress:nil
                                                        completed:nil];
    }
}

#pragma mark - save event
-(void)buttonSaveClick:(UIButton *)sender{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"user"]) {
        [sender setImage:[UIImage imageNamed:@"save-gray"] forState:UIControlStateNormal];
        [sender setEnabled:false];
        _newsList[sender.tag].saved = true;

        // request dictionary
        NSDictionary * param = @{@"newsid":[NSNumber numberWithInt:_newsList[sender.tag].newsId],
                                 @"userid":[NSNumber numberWithInt:userId]};
        
        [manager requestDataWithURL:SAVE_LIST data:param method:POST];
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

@end
