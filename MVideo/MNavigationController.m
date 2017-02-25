//
//  MNavigationController.m
//  MVideo
//
//  Created by LiHongli on 17/2/25.
//  Copyright © 2017年 LHL. All rights reserved.
//

#import "MNavigationController.h"

@interface MNavigationController ()

@end

@implementation MNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

@end
