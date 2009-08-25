//
//  IssueTableController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 01.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "IssueTableController.h"

@implementation IssueTableController

@synthesize issuesTable;
@synthesize _issues;
@synthesize activityIndicator;
@synthesize subtitleCell;
@synthesize _loginData;
@synthesize webViewController;

+ (id)initWithArray:(NSArray *)array title:(NSString*)title loginData:(NSDictionary*)loginData
{
	IssueTableController * _sharedIssueTableController = [[IssueTableController alloc] initWithNibName:@"IssueTableView" bundle:nil];
	[_sharedIssueTableController setIssues:array];
	[_sharedIssueTableController setLoginData:loginData];
	[_sharedIssueTableController setTitle:title];
	return _sharedIssueTableController;	
}

- (void)setIssues:(NSArray*)array
{
	_issues = array;
}

- (void)setLoginData:(NSDictionary*)loginData
{
	_loginData = loginData;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	[issuesTable reloadData];
}

/*
 - (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
}
*/
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [_issues count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"IssueCell";
    
	subtitleCell = (SubtitleCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (subtitleCell == nil)
        [[NSBundle mainBundle] loadNibNamed:@"RevisionCell" owner:self options:nil];
    
	NSMutableDictionary * issue = [_issues objectAtIndex:indexPath.row];
	NSString * title = [[[issue valueForKey:@"title"] componentsSeparatedByString:@":"] objectAtIndex:0];
	NSString * subtitle = [[[issue valueForKey:@"title"] componentsSeparatedByString:@":"] objectAtIndex:1];
	NSString * author = [issue valueForKey:@"name"];	
	
	[subtitleCell setCellDataWithTitle:title author:author];
	[subtitleCell setSubtitle:subtitle];
	
	return subtitleCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{		
	NSMutableDictionary * issue = [_issues objectAtIndex:indexPath.row];
	if(self.webViewController == nil)
		self.webViewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
	
	NSString * title = [[[issue valueForKey:@"title"] componentsSeparatedByString:@":"] objectAtIndex:0];
	[self.webViewController setTitle:title];

	NSString * password = [_loginData valueForKey:@"password"];
	NSString * username = [_loginData valueForKey:@"username"];
	NSString * hostname = [_loginData valueForKey:@"hostname"];
	NSString * trimLink = [[[issue valueForKey:@"id"] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];

	NSMutableURLRequest * request;
	if(([password length] > 0) && ([username length] > 0))
	{
		NSURL * xmlURL = [NSURL URLWithString:[NSString  stringWithFormat:@"http://%@/login",hostname]];
		NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@&back_url=%@",[WWURL encode:username],[WWURL encode:password],[WWURL encode:trimLink]];
		
		request = [NSMutableURLRequest requestWithURL:xmlURL];
		[request addValue:[NSString stringWithFormat:@"%d",[postString length]] forHTTPHeaderField:@"Content-Length"];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
	}
	else
	{
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:trimLink]];
	}
	
	[self.navigationController pushViewController:self.webViewController animated:YES];
	[self.webViewController.webView loadRequest:request];	
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
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

- (void)dealloc 
{
	[activityIndicator release];
	[_issues release];
	[issuesTable release];
	[_loginData release];
	[webViewController release];

    [super dealloc];
}


@end
