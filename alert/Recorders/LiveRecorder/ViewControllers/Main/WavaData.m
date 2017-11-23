//
//  WavaData.m
//  LiveRecorder
//
//  Created by 匹诺曹 on 17/4/14.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "WavaData.h"

void decodeWaveInfo(const char *fname, struct WavInfo *info)
{
    FILE *fp;
    fp = fopen(fname, "rb");
    if(fp==NULL) {
        printf("file not found!\n");
    }
    fseek(fp, 0L, SEEK_END);
    long sz = ftell(fp);
    printf("该文件的长度为%ld字节\n",sz);
    fseek(fp, 0L, SEEK_SET);
    
    if(fp)
    {
        char id[5];
        unsigned int dataSize,size;
        
        fread(id, sizeof(char), 4, fp);
        id[4]='\0';
        if (!strcmp(id, "RIFF")) //资源交换文件标志（RIFF）注意字符大小写!
        {
            fread(&size, sizeof(int), 1, fp);//read file size
            fread(id, sizeof(char), 4, fp);//read wave
            id[4]='\0';
            printf("开%d\n",strcmp(id, "WAVE"));
            if (!strcmp(id, "WAVE"))  //WAV文件标志（WAVE）注意字符大小写!
            {
                
                fread(id, sizeof(char), 4, fp);
                fread(&info->format_length, sizeof(int), 1, fp);                            
                fread(&info->format_tag, sizeof(short), 1, fp);            //格式种类（值为1时，表示数据为线性PCM编码）
                fread(&info->channels, sizeof(short), 1, fp);              //通道数，单声道为1，双声音为2
                fread(&info->sample_rate, sizeof(int), 1, fp);   //采样率
                fread(&info->avg_bytes_sec, sizeof(int), 1, fp); //波形数据传输速率
                fread(&info->block_align, sizeof(short), 1, fp);           //数据的调整数（按字节计算）
                fread(&info->bits_per_sample, sizeof(short), 1, fp);       //样本数据位数
                char id1[5];
                fread(id1, sizeof(char), 4, fp);                            //数据标志符（data）注意字符大小写!
                
                id1[4] = '\0';
                if (!strcmp(id1, "data")) {
                    fread(&dataSize, sizeof(unsigned int), 1, fp);            //采样数据总数
                    info->size = dataSize;
                    info->data = (char *)malloc(sizeof(char)*dataSize);       //采样数据
                    printf("数据大小:%d",dataSize);
                    fread(info->data, sizeof(char), dataSize, fp);

                } else {
                    int perFrame = info->channels * info->sample_rate * 2 * 0.02;
                    int totalCount= ((int)sz - 44 ) / perFrame;
                    info->size = totalCount * perFrame;
                    
                    info->data = (char *)malloc(sizeof(char)*info->size);       //采样数据                    
//                    fseek(fp, 44, SEEK_CUR);
                    fseek(fp, 44, SEEK_SET);
                    printf("数据大小:%d",info->size);
                    fread(info->data, sizeof(char), info->size, fp);
                }
            }
            else
            {
                printf("Error\n");
            }
        }
        else
        {
            printf("Error\n");
        }
        fclose(fp);
    }
}

@implementation WaveData

+ (void)writeWaveHead:(NSString *)path sampleRate:(long)sampleRate {
    NSMutableData *audioData = [[NSMutableData alloc] initWithContentsOfFile:path];
    Byte waveHead[44];
    waveHead[0] = 'R';
    waveHead[1] = 'I';
    waveHead[2] = 'F';
    waveHead[3] = 'F';
    
    long totalDatalength = [audioData length] + 44;
    waveHead[4] = (Byte)(totalDatalength & 0xff);
    waveHead[5] = (Byte)((totalDatalength >> 8) & 0xff);
    waveHead[6] = (Byte)((totalDatalength >> 16) & 0xff);
    waveHead[7] = (Byte)((totalDatalength >> 24) & 0xff);
    
    waveHead[8] = 'W';
    waveHead[9] = 'A';
    waveHead[10] = 'V';
    waveHead[11] = 'E';
    
    waveHead[12] = 'f';
    waveHead[13] = 'm';
    waveHead[14] = 't';
    waveHead[15] = ' ';
    
    waveHead[16] = 16;  //size of 'fmt '
    waveHead[17] = 0;
    waveHead[18] = 0;
    waveHead[19] = 0;
    
    waveHead[20] = 1;   //format
    waveHead[21] = 0;
    
    waveHead[22] = 1;   //chanel
    waveHead[23] = 0;
    
    waveHead[24] = (Byte)(sampleRate & 0xff);
    waveHead[25] = (Byte)((sampleRate >> 8) & 0xff);
    waveHead[26] = (Byte)((sampleRate >> 16) & 0xff);
    waveHead[27] = (Byte)((sampleRate >> 24) & 0xff);
    
    long byteRate = sampleRate * 2 * (16 >> 3);;
    waveHead[28] = (Byte)(byteRate & 0xff);
    waveHead[29] = (Byte)((byteRate >> 8) & 0xff);
    waveHead[30] = (Byte)((byteRate >> 16) & 0xff);
    waveHead[31] = (Byte)((byteRate >> 24) & 0xff);
    
    waveHead[32] = 2*(16 >> 3);
    waveHead[33] = 0;
    
    waveHead[34] = 16;
    waveHead[35] = 0;
    
    waveHead[36] = 'd';
    waveHead[37] = 'a';
    waveHead[38] = 't';
    waveHead[39] = 'a';
    
    long totalAudiolength = [audioData length];
    
    waveHead[40] = (Byte)(totalAudiolength & 0xff);
    waveHead[41] = (Byte)((totalAudiolength >> 8) & 0xff);
    waveHead[42] = (Byte)((totalAudiolength >> 16) & 0xff);
    waveHead[43] = (Byte)((totalAudiolength >> 24) & 0xff);
    
    NSMutableData *waveData = [[NSMutableData alloc]initWithBytes:&waveHead length:sizeof(waveHead)];
    [waveData appendData:audioData];
    
    [waveData writeToFile:path atomically:YES];
}
@end
