//
//  RootViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 31.03.09.
//  Copyright Thomas Stägemann 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddViewController.h"
#import "BadgeCell.h"
#import "ProjectTableController.h"
#import "WWFeedReader.h"

@interface RootViewController : UITableViewController
{
	BadgeCell * badgeCell;
	AddViewController * addViewController;
	ProjectTableController * projectTableController;
	ProjectViewController * projectViewController;
	UITableView * accountTable;
}

@property(nonatomic,retain) IBOutlet BadgeCell * badgeCell;
@property(nonatomic,retain) AddViewController * addViewController;
@property(nonatomic,retain) ProjectTableController * projectTableController;
@property(nonatomic,retain) ProjectViewController * projectViewController;
@property(nonatomic,retain) IBOutlet UITableView * accountTable;

- (IBAction)openPreferences:(id)sender;
- (IBAction)refreshProjects:(id)sender;

@end
