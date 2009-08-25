//
//  ActivityCell.m
//  iRedmine
//
//  Created by Thomas Stägemann on 09.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "SubtitleCell.h"


@implementation SubtitleCell

- (void)setCellDataWithTitle:(NSString*)title author:(NSString *)author
{
	[titleLabel setText:title];
	[authorLabel setText:author];
}

- (void)setSubtitle:(NSString*)subtitle
{
	[subtitleLabel setText:subtitle];
}

- (void)dealloc {
	[authorLabel release];
	[titleLabel release];
	[subtitleLabel release];
    [super dealloc];
}


@end
