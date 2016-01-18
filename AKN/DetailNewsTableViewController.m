//
//  DetailNewsTableViewController.m
//  Detail Article
//
//  Created by Ponnreay on 1/11/16.
//  Copyright © 2016 ponnreay. All rights reserved.
//

#import "DetailNewsTableViewController.h"
#import "MainViewController.h"

@interface DetailNewsTableViewController ()

{
	NSString *imageFile;
	NSString *title;
	NSString *date;
	NSString *description;
    IBOutlet NSLayoutConstraint *imageHeaderCenterY;
}

@end

@implementation DetailNewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = _pageTitle;
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // change status color
	self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:193.0/255.0 green:0.0/255.0 blue:1.0/255.0 alpha:1.0];[UIColor redColor];
	
	title = @"3th Generation Orientation at CKCC";
	date = @"2-April-2015";
	description = @"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
	
	_labelTitle.text = title;
	_labelDate.text = date;
	_labelDescription.text = description;
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
	MainViewController *mvc = [MainViewController getInstance];
	[mvc.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (indexPath.row) {
		case 0:
			return 200.0;
			break;
		case 1:
			return 36;
			break;
		case 2:
			return 36.0;
			break;
        case 3:
            return [self heightForText:description font:_labelDescription.font withinWidth:self.view.frame.size.width-36];
            break;
		case 4:
			return 36.0;
		default:
			return 0;
			break;
	}
}
-(CGFloat)heightForText:(NSString*)text font:(UIFont*)font withinWidth:(CGFloat)width {
    
    CGSize constraint = CGSizeMake(width, 20000.0f);
    CGSize size;
    
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:font}
                                            context:nil].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

-(int)calculateHeightForString:(NSString *)string{
	NSAttributedString *attr = [[NSAttributedString alloc]initWithString:string];
	return [attr boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height * 2;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat y=-scrollView.contentOffset.y;
    if (y>64)
    {
            imageHeaderCenterY.constant=0;
    }
    else
    {
            imageHeaderCenterY.constant=(64-y)*2/5;
    }
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
