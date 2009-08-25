//
//  AddViewController.m
//  iRedmine
//
//  Created by Thomas Stägemann on 08.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "AddViewController.h"

static AddViewController *_sharedAddViewController = nil;

@implementation AddViewController

@synthesize loginField;
@synthesize passwordField;
@synthesize hostField;
@synthesize oldTintColor;

+ (AddViewController *)sharedAddViewController
{
	if (!_sharedAddViewController) {
		_sharedAddViewController = [[self alloc] initWithNibName:@"AddView" bundle:nil];
	}
	return _sharedAddViewController;	
}

- (IBAction)acceptAction:(id)sender
{
	if([[hostField.text stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0)
	{
		UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error adding account",@"Error adding account") message:NSLocalizedString(@"Please complete the form",@"Please complete the form") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[errorAlert show];
		return;
	}
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary * accounts = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"accounts"]];
	NSMutableDictionary * newAccount = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		[hostField.text stringByReplacingOccurrencesOfString:@" " withString:@""],		@"hostname",
		[loginField.text stringByReplacingOccurrencesOfString:@" " withString:@""] ,	@"username",
		[passwordField.text stringByReplacingOccurrencesOfString:@" " withString:@""] ,	@"password",
	nil];
	[accounts setValue:newAccount forKey:hostField.text];
	[defaults setObject:accounts forKey:@"accounts"];	
	[defaults synchronize];
	[self.navigationController popViewControllerAnimated:YES];
}

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
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];      
	[self setTitle:NSLocalizedString(@"Add Account",@"Add Account")];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[UIApplication sharedApplication] setStatusBarStyle:oldStatusBarStyle animated:YES];
	self.navigationController.navigationBar.barStyle = oldBarStyle;	
	self.navigationController.navigationBar.tintColor = [oldTintColor autorelease];	
	[super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	oldStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	oldBarStyle = self.navigationController.navigationBar.barStyle;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	oldTintColor = [self.navigationController.navigationBar.tintColor retain];	
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];		
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


- (void)dealloc {
	[loginField release];
	[passwordField release];
	[hostField release];
	[oldTintColor release];
    [super dealloc];
}


@end
