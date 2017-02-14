//
//  Muxer.h
//  kxmovie
//
//  Created by gxw on 15/1/4.
//
//

#import <CoreFoundation/CoreFoundation.h>

@interface Muxer : NSObject
@property (nonatomic, retain) NSString* state; // 'INITIALIZE' | 'PROCESS' | 'FINISHED' | 'SUCCESS'
@property (nonatomic, retain) NSString* filePath;

- (BOOL)gather:(NSString *)filePath sdpPath:(NSString *)sdpPath;
- (void)stop;
@end