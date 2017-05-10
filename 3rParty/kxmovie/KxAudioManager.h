//
//  KxAudioManager.h
//  kxmovie
//
//  Created by Kolyvan on 23.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt


#import <CoreFoundation/CoreFoundation.h>

typedef void (^KxAudioManagerOutputBlock)(float *data, UInt32 numFrames, UInt32 numChannels);

@protocol KxAudioManager <NSObject>

// 输出频道数
@property (readonly) UInt32             numOutputChannels;
// 采样率
@property (readonly) Float64            samplingRate;
// 每个样本字节数
@property (readonly) UInt32             numBytesPerSample;
// 音量
@property (readonly) Float32            outputVolume;
// 是否正在播放
@property (readonly) BOOL               playing;
// 音轨线
@property (readonly, strong) NSString   *audioRoute;

// 音频输出管理回调， 回调 （数据， 帧数，音轨数）
@property (readwrite, copy) KxAudioManagerOutputBlock outputBlock;

// 激活声音会话
- (BOOL) activateAudioSession;
// 取消激活声音会话
- (void) deactivateAudioSession;
// 播放
- (BOOL) play;
// 暂停
- (void) pause;

@end

@interface KxAudioManager : NSObject
+ (id<KxAudioManager>) audioManager;
@end
