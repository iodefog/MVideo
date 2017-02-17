//
//  ListViewController.m
//  MVideo
//
//  Created by LiHongli on 16/6/18.
//  Copyright © 2016年 LHL. All rights reserved.
//

#import "ListViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ListTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "NewPlayerViewController.h"
#import "KxMovieViewController.h"

#define TVList      @"tvList"

@interface ListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView       *liveListTableView;
@property (nonatomic, strong) UIViewController  *playerController;
@property (nonatomic, strong) NSMutableArray    *dataSource;
@property (nonatomic, assign) NSInteger         tableNum;
@property (nonatomic, assign) BOOL              kxvcpop;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.dict[@"title"];
    
    self.dataSource = [NSMutableArray array];
    [self.view addSubview:self.liveListTableView];
    
    [self addBackgroundMethod];
    [self operationStr];
    [self registerObserver];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (void)addBackgroundMethod{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)operationStr{
        NSString *filePath = self.dict[@"filePath"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            self.tableNum ++;
            NSMutableArray *itemArray = [NSMutableArray array];
            NSError *error = nil;
            NSString *videosText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
            if (!error) {
                NSArray *videosArray = [videosText componentsSeparatedByString:@"\n"];
                for (NSString *subStr in videosArray) {
                    
                    NSArray *subStrArray = [subStr componentsSeparatedByString:@","];
                    NSArray *sub2StrArray = [subStr componentsSeparatedByString:@" "];
                    
                    if(subStrArray.count == 2 || (sub2StrArray.count == 2)){
                        NSArray *tempArray = (subStrArray.count == 2)? subStrArray : sub2StrArray;
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [tempArray firstObject] ?: @"",@"name",
                                              [tempArray lastObject] ?: @"",@"liveUrl",
                                              nil];
                        [itemArray addObject:dict];
                    }
                    else if ([subStr stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0){
                    // nothing
                    }
                    else if (subStrArray.count >= 3 || (sub2StrArray.count >= 3)){
                        NSArray *tempArray = (subStrArray.count == 3)? subStrArray : sub2StrArray;
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [tempArray firstObject] ?: @"",@"name",
                                              [tempArray objectAtIndex:1] ?: @"",@"liveUrl",
                                              nil];
                        [itemArray addObject:dict];
                    }
                    else {
                        subStrArray = [subStr componentsSeparatedByString:@" "];
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [subStrArray firstObject] ?: @"",@"name",
                                              [subStrArray lastObject] ?: @"",@"liveUrl",
                                              nil];
                        [itemArray addObject:dict];
                    }
                }
                [self.dataSource addObject:@{TVList:itemArray}];
            }else {
                NSLog(@"error %@", error);
            }
        }
    [self.liveListTableView reloadData];
}

- (void)registerObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification{
    if ([self.playerController isKindOfClass:[NewPlayerViewController class]]) {
        [((NewPlayerViewController *)self.playerController).player play];
    }else {
        [((MPMoviePlayerViewController *)self.playerController).moviePlayer play];
    }
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification{
    if ([self.playerController isKindOfClass:[NewPlayerViewController class]]) {
        [((NewPlayerViewController *)self.playerController).player pause];
    }else {
        [((MPMoviePlayerViewController *)self.playerController).moviePlayer pause];
    }
}

#pragma mark - Private Method

- (UITableView *)liveListTableView{
    if (_liveListTableView == nil) {
        _liveListTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _liveListTableView.delegate = self;
        _liveListTableView.dataSource = self;
        [_liveListTableView registerClass:[ListTableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    }
    return _liveListTableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *tvListArray = (self.dataSource.count > section) ? self.dataSource[section][TVList] : nil;
    return tvListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (ListTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellName = @"cellName";
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
    }
    
    if (indexPath.row < [self.dataSource[indexPath.section][TVList] count]) {
        NSDictionary *dict =  self.dataSource[indexPath.section][TVList][indexPath.row];
        cell.textLabel.text = dict[@"name"];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.text = [dict[@"liveUrl"] stringByReplacingOccurrencesOfString:@"[url]" withString:@""];
        [cell checkIsCanPlay:cell.detailTextLabel.text fileName:self.dict[@"title"]];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < [self.dataSource[indexPath.section][TVList] count]) {
        
        ListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (![tableView.visibleCells containsObject:cell]) {
            if ((indexPath.row+2) < [self.dataSource[indexPath.section][TVList] count]) {
                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row+2) inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionNone animated:YES];
            }else {
                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row) inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionNone animated:YES];
            }
        }
        
        NSDictionary *dict =  self.dataSource[indexPath.section][TVList][indexPath.row];
        NSString *name = dict[@"name"];
        
        NSLog(@"%@\n name = %@", dict, name);
        
        self.title  = name;
        NSString *movieUrl = [dict[@"liveUrl"] stringByReplacingOccurrencesOfString:@"[url]" withString:@""]; //@"http://123.108.164.75/etv2sb/phd10062/playlist.m3u8"];
        if (movieUrl == nil) {
            return;
        }
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
            /** 使用AVPlayer播放
            AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:movieUrl];
            AVPlayer *avPlayer = [AVPlayer playerWithPlayerItem:playerItem];
            
            NewPlayerViewController *playerVC = [[NewPlayerViewController alloc] init];
            [playerVC setPlayer:avPlayer];
            [avPlayer play];
            self.playerController = playerVC;
            [self presentViewController:playerVC animated:YES completion:nil];
            */
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"KxMovieParameterDisableDeinterlacing"] = @(YES);
            KxMovieViewController *vc = [KxMovieViewController
                                         movieViewControllerWithContentPath:movieUrl
                                         parameters:params];
            vc.timeout = 15;
            __block NSString *movieStr = movieUrl;
            __weak __block typeof(self) mySelf = self;
            __weak __block typeof(KxMovieViewController *) myvc = vc;
            
            self.kxvcpop = YES;
            
            vc.VCCallBack = ^(void){
                mySelf.kxvcpop = YES;
            };
            
            vc.playCallBack = ^(NSError *error , BOOL success){
                if (success) {
                    ListTableViewCell *ttcell = [mySelf.liveListTableView cellForRowAtIndexPath:indexPath];
                    if (ttcell.canPlayLabel.hidden || !ttcell.canPlayLabel) {
                        [mySelf saveCanPlayHistory:movieStr];
                        [mySelf saveCanPlayHistoryToDocument:movieStr name:name];
                    }
                    ttcell.canPlayLabel.hidden = NO;
                    mySelf.kxvcpop = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
                        if (mySelf.kxvcpop) {
                            return;
                        }
                        [myvc dismissViewControllerAnimated:YES completion:nil];
                        mySelf.kxvcpop = NO;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
                            if (mySelf.kxvcpop) {
                                return;
                            }
                            [mySelf autoPlayNextVideo:indexPath delegate:mySelf];
                        });
                    });
                    
                }else {
                    [myvc.alertView dismissWithClickedButtonIndex:0 animated:YES];
                    [myvc dismissViewControllerAnimated:YES completion:nil];
                    mySelf.kxvcpop = NO;
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
                         if (mySelf.kxvcpop) {
                             return;
                         }
                        [mySelf autoPlayNextVideo:indexPath delegate:mySelf];
                     });
                }
            };
            [self presentViewController:vc animated:YES completion:nil];
            
        }else {
            MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:movieUrl]];
            self.playerController = player;
            [self presentMoviePlayerViewControllerAnimated:player];
        }
    }
}

- (void)autoPlayNextVideo:(NSIndexPath *)currentIndexPath delegate:(ListViewController *)vc{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndexPath.row+1 inSection:0];
    [vc tableView:self.liveListTableView didSelectRowAtIndexPath:indexPath];
}

- (void)saveCanPlayHistory:(NSString *)movieUrl{
    NSMutableDictionary *canPlaylistDict = [NSMutableDictionary dictionary];
    [canPlaylistDict setDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:self.dict[@"title"]]];
    if (!canPlaylistDict) {
    }
    [canPlaylistDict setValue:movieUrl forKey:movieUrl];
    [[NSUserDefaults standardUserDefaults] setObject:canPlaylistDict forKey:self.dict[@"title"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)saveCanPlayHistoryToDocument:(NSString *)movieUrl name:(NSString *)name{
    NSString *documentPath = [self getDocumentFilePath];
    NSError *error = nil;
    NSString *oldString = [NSString stringWithContentsOfFile:documentPath encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        NSLog(@"读取字符串 error %@", error);
    }
    NSString *newString = [NSString stringWithFormat:@"%@\n%@ %@",oldString?:@"", name, movieUrl];
    BOOL success = [newString writeToFile:documentPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error || !success) {
        NSLog(@"写入字符串 error %@， success %d", error, success);
    }
}

- (NSString *)getDocumentFilePath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    documentPath = [NSString stringWithFormat:@"%@/%@.txt", documentPath, self.dict[@"title"]];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
//        [[NSFileManager defaultManager] createFileAtPath:documentPath contents:nil attributes:nil];
//    }
    NSLog(@"documentPath  %@", documentPath);
    return documentPath;
}

@end
