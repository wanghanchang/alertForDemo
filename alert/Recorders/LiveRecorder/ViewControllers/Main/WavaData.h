//
//  WavaData.h
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/14.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

struct WavInfo
{
    int   size;
    char  *data;
    short channels;
    short block_align;
    short bits_per_sample;
    int sample_rate;
    int format_length;
    int format_tag;
    int avg_bytes_sec;
    
};
void decodeWaveInfo();

@interface WaveData : NSObject

+(void)writeWaveHead:(NSString *)path sampleRate:(long)sampleRate;

@end
