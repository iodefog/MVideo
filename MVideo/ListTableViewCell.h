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

- (void)checkIsCanPlay:(NSString *)url fileName:(NSString *)fileName;

@end
