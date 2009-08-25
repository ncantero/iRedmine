//
//  ProjectTableController.m
//  iRedmine
//
//  Created by Thomas St√§gemann on 21.04.09.
//  Copyright 2009 Thomas St√§gemann. All rights reserved.
//

#import "ProjectTableController.h"


@implementation ProjectTableController

@synthesize projectArray;
@synthesize projectTable;
@synthesize projectViewController;
@synthesize reportedIssuesViewController;
@synthesize assignedIssuesViewController;
@synthesize badgeCell;
@synthesize loginData;
@synthesize reportedIssues;
@synthesize assignedIssues;

- (void)viewWillLoad {
    //[super viewWillLoad];
	
	[self setTitle:NSLocalizedString(@"Projects",@"Projects")];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}
*/

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	assignedIssues = [[NSMutableArray array] retain];
	reportedIssues = [[NSMutableArray array] retain];

	[projectTable reloadData];
	
	[self fetchAssignedIssues:self];
	[self fetchReportedIssues:self];
}

/*
- (void)viewDidAppear:(BOOL)animated {
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

- (IBAction)fetchAssignedIssues:(id)sender
{
	NSString * password = [WWURL encode:[loginData valueForKey:@"password"]];
	NSString * username = [WWURL encode:[loginData valueForKey:@"username"]];
	NSString * hostname = [loginData valueForKey:@"hostname"];
	
	NSString * feedURL = [WWURL encode:[NSString stringWithFormat:@"http://%@/issues?format=atom&assigned_to_id=me",hostname]];
	NSMutableURLRequest * request;
	
	NSURL * loginURL = [NSURL URLWithString:[NSString  stringWithFormat:@"http://%@/login",hostname]];
	NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@&back_url=%@",username,password,feedURL];
	request = [NSMutableURLRequest requestWithURL:loginURL];
	NSString *msgLength = [NSString stringWithFormat:@"%d",[postString length]];
	[request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
	
	[[WWFeedReader alloc] initWithRequest:request keyForItems:@"entry" arrayOfKeys:[NSArray arrayWithObjects:@"title",@"content",@"name",@"updated",@"id",nil] delegate:self];
}

- (IBAction)fetchReportedIssues:(id)sender
{
	NSString * password = [WWURL encode:[loginData valueForKey:@"password"]];
	NSString * username = [WWURL encode:[loginData valueForKey:@"username"]];
	NSString * hostname = [loginData valueForKey:@"hostname"];
	
	NSString * feedURL = [WWURL encode:[NSString stringWithFormat:@"http://%@/issues?format=atom&author_id=me",hostname]];
	NSMutableURLRequest * request;
	
	NSURL * loginURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/login",hostname]];
	NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@&back_url=%@",username,password,feedURL];
	request = [NSMutableURLRequest requestWithURL:loginURL];
	NSString *msgLength = [NSString stringWithFormat:@"%d",[postString length]];
	[request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
	
	[[WWFeedReader alloc] initWithRequest:request keyForItems:@"entry" arrayOfKeys:[NSArray arrayWithObjects:@"title",@"content",@"name",@"updated",nil] delegate:self];
}

- (void)feedReader:(WWFeedReader *)feedReader didEndWithResult:(NSArray *)result
{
	NSString* postString = [[[NSString alloc] initWithData:[[feedReader request] HTTPBody] encoding:NSUTF8StringEncoding] lastPathComponent];
	
	if([[postString componentsSeparatedByString:@"assigned_to_id"] count] > 1)
	{
		assignedIssues = [[result mutableCopy] retain];
		//NSLog(@"assigned issues: %@",assignedIssues);
	}
	else if([[postString componentsSeparatedByString:@"author_id"] count] > 1)
	{
		reportedIssues = [[result mutableCopy] retain];
		//NSLog(@"reported issues: %@",reportedIssues);
	}
	
	[projectTable reloadData];
}

#pragma mark Table view methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	switch (section) 
	{
		case 0: 
			return NSLocalizedString(@"Projects",@"Projects");
		case 1:	
			return NSLocalizedString(@"My Page",@"My Page"); 
		default: 
			return nil;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	NSString * username = [loginData valueForKey:@"username"];
	NSString * password = [loginData valueForKey:@"password"];	
	
	if(([password length] > 0) && ([username length] > 0))
		return 2;
	else
		return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) 
	{
		case 0:  
			// Projects
			return [projectArray count]; 
		case 1:	 
			// My Page
			return 2; 
		default: 
			return 0;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ProjectCell";
    
	badgeCell = (BadgeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (badgeCell == nil)
        [[NSBundle mainBundle] loadNibNamed:@"BadgeCell" owner:self options:nil];
    
	// Set up the cell...
	switch (indexPath.section) 
	{
		case 0:  
			// Projects
			[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
			NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setDateStyle:NSDateFormatterShortStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			NSString * subtitle = [dateFormatter stringFromDate:[RMParser dateWithString:[[projectArray objectAtIndex:indexPath.row] valueForKey:@"updated"]]];
			NSString * subtitleWithLabel = [NSString stringWithFormat:NSLocalizedString(@"Last Update: %@",@"Last Update: %@"),subtitle];
			[badgeCell setCellDataWithTitle:[[projectArray objectAtIndex:indexPath.row] valueForKey:@"title"] subTitle:subtitleWithLabel];
			break;
		case 1:	 
			// My Page
			switch (indexPath.row) 
			{
				case 0:
					[badgeCell setCellDataWithTitle:NSLocalizedString(@"Issues assigned to me",@"Issues assigned to me") subTitle:nil];
  					[badgeCell setBadge:[assignedIssues count]];
					//NSLog(@"assigned issues: %@",assignedIssues);
					break;
				case 1:
					[badgeCell setCellDataWithTitle:NSLocalizedString(@"Reported issues",@"Reported issues") subTitle:nil];
					[badgeCell setBadge:[reportedIssues count]];
					//NSLog(@"reported issues: %@",reportedIssues);
					break;
				default:
					break;
			}
			break;
		default: 
			break;
	}
	
	return badgeCell;	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.section) 
	{
		case 0:
			if(self.projectViewController == nil)
				self.projectViewController = [[ProjectViewController alloc] initWithNibName:@"ProjectView" bundle:nil];
			
			// Set up the text view...
			NSMutableDictionary * project = [NSMutableDictionary dictionaryWithDictionary:[projectArray objectAtIndex:indexPath.row]];
			
			[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
			NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setDateStyle:NSDateFormatterShortStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			NSString * date = [dateFormatter stringFromDate:[RMParser dateWithString:[project valueForKey:@"updated"]]];
			
			self.projectViewController.project = project;
			self.projectViewController.loginData = loginData;
			
			[self.navigationController pushViewController:self.projectViewController animated:YES];
			
			[self.projectViewController.descriptionText loadHTMLString:[project valueForKey:@"content"] baseURL:nil];
			self.projectViewController.titleLabel.text = [project valueForKey:@"title"];
			self.projectViewController.dateLabel.text = date;
			
			break;
		case 1:
			// My Page
			switch (indexPath.row) 
			{
				case 0:
					if ([assignedIssues count] == 0) break;
					
					// Issues assigned to me
					if(self.assignedIssuesViewController == nil)
						self.assignedIssuesViewController = [IssueTableController initWithArray:assignedIssues title:NSLocalizedString(@"Assigned Issues",@"Assigned Issues") loginData:loginData];
					
					[self.navigationController pushViewController:self.assignedIssuesViewController animated:YES];
					break;
				case 1:
					if ([reportedIssues count] == 0) break;
					
					// Reported issues
					if(self.reportedIssuesViewController == nil)
						self.reportedIssuesViewController = [IssueTableController initWithArray:reportedIssues title:NSLocalizedString(@"Reported Issues",@"Reported Issues") loginData:loginData];
					
					[self.navigationController pushViewController:self.reportedIssuesViewController animated:YES];
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
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
	[projectArray release];
	[projectTable release];
	[projectViewController release];
	[loginData release];
	[assignedIssues release];
	[reportedIssues release];

    [super dealloc];
}


@end

