//
//  ActivityCell.h
//  iRedmine
//
//  Created by Thomas Stägemann on 09.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SubtitleCell : UITableViewCell 
{
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *authorLabel;
	IBOutlet UILabel *subtitleLabel;
}

- (void)setCellDataWithTitle:(NSString*)title author:(NSString *)author;
- (void)setSubtitle:(NSString*)subtitle;

@end
