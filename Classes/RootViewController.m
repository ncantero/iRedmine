//
//  RootViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 31.03.09.
//  Copyright Thomas Stägemann 2009. All rights reserved.
//

#import "RootViewController.h"
#import "iRedmineAppDelegate.h"


@implementation RootViewController

@synthesize badgeCell;
@synthesize addViewController;
@synthesize projectTableController;
@synthesize projectViewController;
@synthesize accountTable;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setTitle:@"iRedmine"];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)openPreferences:(id)sender
{
	if(self.addViewController == nil)
		self.addViewController = [AddViewController sharedAddViewController];
	
	[self.navigationController pushViewController:self.addViewController animated:YES];
	
	// Set up the text view...
	
}

- (IBAction)refreshProjects:(id)sender
{	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * accounts = [[defaults dictionaryForKey:@"accounts"] allValues];
	
	for(NSDictionary * account in accounts)
	{
		NSString * password = [account valueForKey:@"password"];
		NSString * username = [account valueForKey:@"username"];
		NSString * hostname = [account valueForKey:@"hostname"];
			
		NSURL * feedURL = [NSURL URLWithString:[NSString  stringWithFormat:@"http://%@/projects?format=atom",hostname]];
		NSMutableURLRequest * request;
		
		if(([password length] > 0) && ([username length] > 0))
		{
			NSURL * loginURL = [NSURL URLWithString:[NSString  stringWithFormat:@"http://%@/login",hostname]];
			NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@&back_url=%@",username,password,[feedURL absoluteString]];
			request = [NSMutableURLRequest requestWithURL:loginURL];
			NSString *msgLength = [NSString stringWithFormat:@"%d",[postString length]];
			[request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
			[request setHTTPMethod:@"POST"];
			[request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
		}
		else
		{
			request = [NSMutableURLRequest requestWithURL:feedURL];
		}
		
		[[WWFeedReader alloc] initWithRequest:request keyForItems:@"entry" arrayOfKeys:[NSArray arrayWithObjects:@"title",@"content",@"id",@"updated",nil] delegate:self];		
	}
	
}

- (void)feedReader:(WWFeedReader *)feedReader didEndWithResult:(NSArray *)result
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary * accounts = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"accounts"]];
	NSMutableDictionary * account = [NSMutableDictionary dictionaryWithDictionary:[accounts valueForKey:[[[feedReader request] URL] host]]];
	[account setValue:result forKeyPath:@"projects"];
	[accounts setValue:account forKey:[[[feedReader request] URL] host]];
	[defaults setObject:accounts forKey:@"accounts"];
	[defaults synchronize];
	[accountTable reloadData];
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	// Fetch projects
	[self refreshProjects:self];
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults dictionaryForKey:@"accounts"] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"AccountCell";
 	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary * accountDict = [[[defaults dictionaryForKey:@"accounts"] allValues] objectAtIndex:indexPath.row];

    badgeCell = (BadgeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(badgeCell == nil)
        [[NSBundle mainBundle] loadNibNamed:@"BadgeCell" owner:self options:nil];
		
	NSString * username = [accountDict valueForKey:@"username"];
	if([username length] == 0) username = NSLocalizedString(@"Anonymous",@"Anonymous");
		
	NSString * subtitle = [NSString stringWithFormat:NSLocalizedString(@"Username: %@",@"Username: %@"),username];
	[badgeCell setCellDataWithTitle:[accountDict valueForKey:@"hostname"] subTitle:subtitle];
	[badgeCell setBadge:[[accountDict valueForKey:@"projects"] count]];
	[badgeCell setEditingStyle:UITableViewCellEditingStyleDelete];
	return badgeCell;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)    
	{
		NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
		NSMutableDictionary * accounts = [NSMutableDictionary dictionaryWithDictionary:[defaults valueForKey:@"accounts"]];
		NSString * key = [[accounts allKeys] objectAtIndex:indexPath.row];
		[accounts removeObjectForKey:key];
		[defaults setValue:accounts forKey:@"accounts"];
		[accountTable reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary * accountDict = [[[defaults dictionaryForKey:@"accounts"] allValues] objectAtIndex:indexPath.row];
	
	NSArray * projectArray	= [accountDict valueForKey:@"projects"];
	NSString * username		= [accountDict valueForKey:@"username"];
	NSString * password		= [accountDict valueForKey:@"password"];	
	
	if(([projectArray count] == 1) && ([password length] == 0) && ([username length] == 0))
	{
		if(self.projectViewController == nil)
			self.projectViewController = [[ProjectViewController alloc] initWithNibName:@"ProjectView" bundle:nil];
		
		// Set up the text view...
		NSMutableDictionary * project = [NSMutableDictionary dictionaryWithDictionary:[projectArray objectAtIndex:0]];
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
		NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		NSString * date = [dateFormatter stringFromDate:[RMParser dateWithString:[project valueForKey:@"updated"]]];
		
		self.projectViewController.project = project;
		self.projectViewController.loginData = accountDict;
		
		[self.navigationController pushViewController:self.projectViewController animated:YES];	
		
		[self.projectViewController.descriptionText loadHTMLString:[project valueForKey:@"content"] baseURL:nil];
		self.projectViewController.titleLabel.text = [project valueForKey:@"title"];
		self.projectViewController.dateLabel.text = date;
	}
	else if([[accountDict valueForKey:@"projects"] count] > 0)
	{
		if(self.projectTableController == nil)
			self.projectTableController = [[ProjectTableController alloc] initWithNibName:@"ProjectTableView" bundle:nil];
		
		self.projectTableController.loginData = accountDict;
		self.projectTableController.projectArray = [accountDict valueForKey:@"projects"];
		[self.projectTableController setTitle:[accountDict valueForKey:@"hostname"]];
		
		[self.navigationController pushViewController:self.projectTableController animated:YES];
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


- (void)dealloc {
	[badgeCell release];
	[addViewController release];
	[projectTableController release];
	[projectViewController release];
	[accountTable release];
	
    [super dealloc];
}


@end

