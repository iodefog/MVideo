//
//  ListTableViewCell.m
//  MVideo
//
//  Created by LHL on 17/2/15.
//  Copyright © 2017年 LHL. All rights reserved.
//

#import "ListTableViewCell.h"

@implementation ListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        [self createUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createUI];
}

- (void)createUI{
    self.canPlayLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, 0, 50, 22)];
    self.canPlayLabel.backgroundColor = [UIColor greenColor];
    self.canPlayLabel.textAlignment = NSTextAlignmentCenter;
    self.canPlayLabel.text = @"可播";
    self.canPlayLabel.font = [UIFont systemFontOfSize:14];
    self.canPlayLabel.hidden = YES;
    [self addSubview:self.canPlayLabel];
}

- (void)checkIsCanPlay:(NSString *)url fileName:(NSString *)fileName{
    NSDictionary *canPlaylistDict = [[NSUserDefaults standardUserDefaults] objectForKey:fileName];
   NSString *tmpUrl = [canPlaylistDict objectForKey:url];
    self.canPlayLabel.hidden = !tmpUrl;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.canPlayLabel.frame = CGRectMake(self.frame.size.width - 50, 0, 50, 22);
}

@end
