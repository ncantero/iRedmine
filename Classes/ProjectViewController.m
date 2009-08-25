//
//  ProjectViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 14.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "ProjectViewController.h"

@implementation ProjectViewController

@synthesize project;
@synthesize homeItem;
@synthesize issuesItem;
@synthesize activityItem;
@synthesize titleLabel;
@synthesize dateLabel;
@synthesize descriptionText;
@synthesize loginData;

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[self setTitle:NSLocalizedString(@"Project",@"Project")];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	[issuesItem setBadgeValue:nil];
	[activityItem setBadgeValue:nil];
	
	[self fetchIssues:self];
	[self fetchActivities:self];
}

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

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	if(item == homeItem) 
	{
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
	else if((item == issuesItem) && ([[issuesItem badgeValue] intValue] > 0))
	{
		IssueTableController * issuesViewController = [IssueTableController initWithArray:[project valueForKey:@"issues"] title:NSLocalizedString(@"Issues",@"Issues") loginData:loginData];		
		[self.navigationController pushViewController:issuesViewController animated:YES];			
	}
	else if((item == activityItem) && ([[activityItem badgeValue] intValue] > 0))
	{
		IssueTableController * activityViewController = [IssueTableController initWithArray:[project valueForKey:@"activities"] title:NSLocalizedString(@"Activities",@"Activities") loginData:loginData];
		
		[self.navigationController pushViewController:activityViewController animated:YES];
	}
	[tabBar setSelectedItem:nil];
}

- (IBAction)fetchIssues:(id)sender
{
	NSString * password = [WWURL encode:[loginData valueForKey:@"password"]];
	NSString * username = [WWURL encode:[loginData valueForKey:@"username"]];
	NSString * hostname = [loginData valueForKey:@"hostname"];
	
	int projectID = [[[self.project valueForKey:@"id"] lastPathComponent] intValue];
	NSURL * feedURL = [NSURL URLWithString:[NSString  stringWithFormat:@"http://%@/projects/%d/issues?format=atom",hostname,projectID]];
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

	[[WWFeedReader alloc] initWithRequest:request keyForItems:@"entry" arrayOfKeys:[NSArray arrayWithObjects:@"title",@"content",@"name",@"updated",@"id",nil] delegate:self];
}

- (IBAction)fetchActivities:(id)sender
{	
	NSString * password = [WWURL encode:[loginData valueForKey:@"password"]];
	NSString * username = [WWURL encode:[loginData valueForKey:@"username"]];
	NSString * hostname = [loginData valueForKey:@"hostname"];
		
	int projectID = [[[self.project valueForKey:@"id"] lastPathComponent] intValue];
	NSURL * feedURL = [NSURL URLWithString:[NSString  stringWithFormat:@"http://%@/projects/%d/activity?format=atom",hostname,projectID]];
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
			
	[[WWFeedReader alloc] initWithRequest:request keyForItems:@"entry" arrayOfKeys:[NSArray arrayWithObjects:@"title",@"content",@"name",@"updated",@"id",nil] delegate:self];	
}

- (void)feedReader:(WWFeedReader *)feedReader didEndWithResult:(NSArray *)result
{		
	NSString* postString = [[[NSString alloc] initWithData:[[feedReader request] HTTPBody] encoding:NSUTF8StringEncoding] lastPathComponent];
	NSString* urlString = [[[[feedReader request] URL] relativePath] lastPathComponent];
	
	if([postString isEqual:@"issues?format=atom"] || [urlString isEqual:@"issues"])
	{
		[project setValue:result forKey:@"issues"];
		if([result count] > 0)
			[issuesItem setBadgeValue:[NSString stringWithFormat:@"%d",[result count]]];
		else
			[issuesItem setBadgeValue:nil];
	}
	else if([postString isEqual:@"activity?format=atom"] || [urlString isEqual:@"activity"])
	{
		[project setValue:result forKey:@"activities"];
		if([result count] > 0)
			[activityItem setBadgeValue:[NSString stringWithFormat:@"%d",[result count]]];
		else
			[activityItem setBadgeValue:nil];
	}
}

- (void)dealloc {
	[project release];
	[descriptionText release];
	[homeItem release];
	[issuesItem release];
	[activityItem release];
	[titleLabel release];
	[dateLabel release];
	[loginData release];
	
    [super dealloc];
}


@end
