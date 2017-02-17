//
//  ViewController.h
//  kxmovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>

@class KxMovieDecoder;

extern NSString * const KxMovieParameterMinBufferedDuration;    // Float
extern NSString * const KxMovieParameterMaxBufferedDuration;    // Float
extern NSString * const KxMovieParameterDisableDeinterlacing;   // BOOL


typedef void(^KxPlayCallBack)(NSError *error, BOOL success);

typedef void(^KxVCCallBack)();


@interface KxMovieViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters;


@property (readonly) BOOL playing;
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, copy) KxPlayCallBack playCallBack;
@property (nonatomic, copy) KxVCCallBack VCCallBack;

@property (nonatomic, strong) UIAlertView *alertView;


- (void) play;
- (void) pause;

@end
