//
//  ListTableViewCell.h
//  MVideo
//
//  Created by LHL on 17/2/15.
//  Copyright © 2017年 LHL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *canPlayLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *urlLabel;


- (void)checkIsCanPlay:(NSString *)url fileName:(NSString *)fileName;

- (void)setObject:(id)anObject;


@end
