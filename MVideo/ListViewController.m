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

#define TVList          @"tvList"
#define CanPlayResult   @"CanPlayResult"

@interface ListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView       *liveListTableView;
@property (nonatomic, strong) UISwitch          *autoPlaySwitch;
@property (nonatomic, strong) UIViewController  *playerController;
@property (nonatomic, strong) NSMutableArray    *dataSource;
@property (nonatomic, assign) BOOL              kxResetPop;

@end

@implementation ListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.dict[@"title"];
    [self.view addSubview:self.liveListTableView];
    [self addBackgroundMethod];
    [self operationStr];
    [self registerObserver];
    [self setNavgationRightItem];
}

/**
 *  导航条右边添加自动返回开关
 */
- (void)setNavgationRightItem{
    self.autoPlaySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100-30, 0, 30, 20)];
    [self.autoPlaySwitch addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    NSNumber *oldValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAutoPlaySwitch"];
    self.autoPlaySwitch.on = oldValue ? oldValue.boolValue : YES;
    
    UILabel *tipLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    tipLable.userInteractionEnabled = YES;
    tipLable.text = @"自动返回";
    tipLable.font = [UIFont systemFontOfSize:14];
    [tipLable addSubview:self.autoPlaySwitch];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tipLable];
}

- (BOOL)shouldAutorotate{
    return NO;
}

/**
 *  Switch 开关值改变方法回调
 *
 *  @param sender switch
 */
- (void)valueChange:(UISwitch *)sender{
    [[NSUserDefaults standardUserDefaults] setObject:@(sender.on) forKey:@"kAutoPlaySwitch"];
}

/**
 *  添加后台方法
 */
- (void)addBackgroundMethod{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)operationStr{
    NSString *filePath = self.dict[@"filePath"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableArray *itemArray = [NSMutableArray array];
        NSError *error = nil;
        // 去除路径下的某个txt文件
        NSString *videosText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        // 过滤掉特殊字符 "\r"。有些url带有"\r",导致转换失败
        videosText = [videosText stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        if (!error) {
            // 依据换行符截取一行字符串
            NSArray *videosArray = [videosText componentsSeparatedByString:@"\n"];
            
            for (NSString *subStr in videosArray) {
                // 根据"," 和" " 分割一行的字符串
                NSArray *subStrArray = [subStr componentsSeparatedByString:@","];
                NSArray *sub2StrArray = [subStr componentsSeparatedByString:@" "];
                
                if(subStrArray.count == 2 || (sub2StrArray.count == 2)){
                    NSArray *tempArray = (subStrArray.count == 2)? subStrArray : sub2StrArray;
                    itemArray = [self checkMultipleUrlInOneUrlWithUrl:[tempArray lastObject] videoName:[tempArray firstObject] itemArray:itemArray];
                }
                else if ([subStr stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0){
                    // nothing
                }
                else if (subStrArray.count >= 3 || (sub2StrArray.count >= 3)){
                    NSArray *tempArray = (subStrArray.count >= 3)? subStrArray : sub2StrArray;
                    NSString *tempUrl = [tempArray objectAtIndex:1];
                    itemArray = [self checkMultipleUrlInOneUrlWithUrl:tempUrl.length>5?tempUrl:[tempArray objectAtIndex:2] videoName:[tempArray firstObject] itemArray:itemArray];
                }
                else {
                    subStrArray = [subStr componentsSeparatedByString:@" "];
                    itemArray = [self checkMultipleUrlInOneUrlWithUrl:[subStrArray lastObject] videoName:[subStrArray firstObject] itemArray:itemArray];
                }
            }
            [self.dataSource addObject:@{TVList:itemArray}];
        }else {
            NSLog(@"error %@", error);
        }
    }
    [self.liveListTableView reloadData];
}

- (NSMutableArray *)checkMultipleUrlInOneUrlWithUrl:(NSString *)url
                              videoName:(NSString *)videoName
                              itemArray:(NSMutableArray *)itemArray
{
    NSArray *multipleArray = [url componentsSeparatedByString:@"#"];
    for (NSString *itemUrl in multipleArray) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              videoName ?: @"",@"name",
                              itemUrl ?: @"",@"liveUrl",
                              nil];
        [itemArray addObject:dict];
    }
    return itemArray;
}

/**
 *  注册前后台观察者
 *  进入后台，暂停。进去前台，播放
 */
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
        NSString *videoName = dict[@"name"];
        NSString *movieUrl = [dict[@"liveUrl"] stringByReplacingOccurrencesOfString:@"[url]" withString:@""];
        
        NSLog(@"%@\n name = %@", dict, videoName);
        self.title = videoName;
        
        [self playVideoWithMovieUrl:movieUrl movieName:videoName indexPath:indexPath];
    }
}


/**
 *  播放某一个index下的视频。对于可播放的，存储。然后根据条件自动判断是否进行下一个视频播放
 *
 *  kxResetPop 当自动进行下一个播放时，设置为NO，当进行点击操作时，变为YES，这样dispatch_after（）就可以判断不用自动进行下一个了。另外条件就是switch开关。
 *
 *  @param movieUrl  视频的播放地址
 *  @param movieName 视频的名称
 *  @param indexPath 当前播放的视频cell的索引
 */
- (void)playVideoWithMovieUrl:(NSString *)movieUrl
                    movieName:(NSString *)movieName
                    indexPath:(NSIndexPath *)indexPath{
    if (movieUrl == nil) {
        return;
    }
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
        /** 使用AVPlayer播放
         AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:movieUrl]];
         AVPlayer *avPlayer = [AVPlayer playerWithPlayerItem:playerItem];
         
         NewPlayerViewController *playerVC = [[NewPlayerViewController alloc] init];
         [playerVC setPlayer:avPlayer];
         [avPlayer play];
         self.playerController = playerVC;
         [self presentViewController:playerVC animated:YES completion:nil];
         */
        ///*
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"KxMovieParameterDisableDeinterlacing"] = @(YES);
        KxMovieViewController *vc = [KxMovieViewController
                                     movieViewControllerWithContentPath:movieUrl
                                     parameters:params];
        vc.timeout = 15;
        __block NSString *movieStr = movieUrl;
        __weak __block typeof(self) mySelf = self;
        __weak __block typeof(KxMovieViewController *) myvc = vc;
        
        self.kxResetPop = YES;
        
        vc.VCCallBack = ^(void){
            mySelf.kxResetPop = YES;
        };
        
        vc.playCallBack = ^(NSError *error , BOOL success){
            if (success) {
                ListTableViewCell *ttcell = [mySelf.liveListTableView cellForRowAtIndexPath:indexPath];
                if (ttcell.canPlayLabel.hidden || !ttcell.canPlayLabel) {
                    [mySelf saveCanPlayHistory:movieStr];
                    [mySelf saveCanPlayHistoryToDocument:movieStr name:movieName];
                }
                ttcell.canPlayLabel.hidden = NO;
                mySelf.kxResetPop = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
                    if (mySelf.kxResetPop || !self.autoPlaySwitch.on) {
                        return;
                    }
                    [myvc dismissViewControllerAnimated:YES completion:nil];
                    mySelf.kxResetPop = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
                        if (mySelf.kxResetPop) {
                            return;
                        }
                        [mySelf autoPlayNextVideo:indexPath delegate:mySelf];
                    });
                });
                
            }else {
                [myvc.alertView dismissWithClickedButtonIndex:0 animated:YES];
                [myvc dismissViewControllerAnimated:YES completion:nil];
                mySelf.kxResetPop = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
                    if (mySelf.kxResetPop || !self.autoPlaySwitch.on) {
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
        //   */
    }
}



/**
 *  自动播放下一个cell里的视频
 *
 *  @param currentIndexPath 当前播放的视频cell索引
 *  @param vc
 */
- (void)autoPlayNextVideo:(NSIndexPath *)currentIndexPath delegate:(ListViewController *)vc{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndexPath.row+1 inSection:0];
    [vc tableView:self.liveListTableView didSelectRowAtIndexPath:indexPath];
}

/**
 *  根据一个列表产生一个可播放地址列表
 *
 *  @param movieUrl 播放地址
 */
- (void)saveCanPlayHistory:(NSString *)movieUrl{
    NSMutableDictionary *canPlaylistDict = [NSMutableDictionary dictionary];
    [canPlaylistDict setDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:self.dict[@"title"]]];
    if (!canPlaylistDict) {
    }
    [canPlaylistDict setValue:movieUrl forKey:movieUrl];
    [[NSUserDefaults standardUserDefaults] setObject:canPlaylistDict forKey:self.dict[@"title"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  保存可以播放的地址进入沙盒
 *
 *  @param movieUrl 播放地址
 *  @param name     播放地址名称
 */
- (void)saveCanPlayHistoryToDocument:(NSString *)movieUrl name:(NSString *)name{
    NSString *documentPath = [ListViewController getResultDocumentFilePath];
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

/**
 *  获取过滤后的列表存储地址
 *
 *  @return 沙盒存储地址
 */
+ (NSString *)getResultDocumentFilePath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    documentPath = [NSString stringWithFormat:@"%@/%@.txt", documentPath, CanPlayResult];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
        [[NSFileManager defaultManager] createFileAtPath:documentPath contents:nil attributes:nil];
    }
    NSLog(@"documentPath  %@", documentPath);
    return documentPath;
}

@end