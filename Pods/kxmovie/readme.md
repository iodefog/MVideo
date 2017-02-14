FFmpegPlayer-iOS - A movie player for iOS based on FFmpeg.
===========================================================

### Background

the [kxmovie](https://github.com/kolyvan/kxmovie) for cocoapods

### Instation

    pod 'kxmovie', '0.0.1'

### Usage

import header file
    
    #import "KxMovieViewController.h"

For play movies:

    ViewController *vc;
    
    vc = [KxMovieViewController movieViewControllerWithContentPath:path parameters:nil];
    
    [self presentViewController:vc animated:YES completion:nil];
