//
//  LzoBitMap.m
//  BluetoothDemo
//
//  Created by apple on 2021/12/15.
//

#import "LzoBitMap.h"
#include "compressuntil.h"

static LzoBitMap *manager = nil;

@implementation LzoBitMap

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LzoBitMap alloc]init];
    });
    return manager;
}


/**
 image -> GG
 @param image 图片
 @param x 坐标x
 @param y 坐标y
 @param maxSize 压缩数据最大值
 @param thresh 阈值 0~255
 @return 图像数据
 */
+ (NSData *)imageGG:(UIImage *)image
                  x:(int)x
                  y:(int)y
            maxSize:(int)maxSize
             thresh:(int)thresh{
    
    return [[self sharedInstance] imageGG:image
                                        x:x
                                        y:y
                                  maxSize:maxSize
                                   thresh:thresh];
}

- (NSData *)imageGG:(UIImage *)image
                  x:(int)x
                  y:(int)y
            maxSize:(int)maxSize
             thresh:(int)thresh{
    
    CGImageRef imageRef = image.CGImage;
    // 取图片的宽高
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t widthByteFixed = (width + 7) / 8;
    
    int maxHeight = maxSize * 8 / (widthByteFixed * 8);
    int imageCount = (int)ceil(height * 1.0 / maxHeight);
    
    NSMutableData *mutableData = [[NSMutableData alloc]init];
    for (int n = 0; n < imageCount; n++) {
        // 要拆分的子图片高度
        CGFloat subHeight = (n == imageCount - 1) ? (height - maxHeight * n) : maxHeight;
        // 子图片rect
        CGRect subRect = CGRectMake(0, maxHeight * n, width, subHeight);
        // 拆分成子图片
        CGImageRef subImgRef = CGImageCreateWithImageInRect(imageRef, subRect);
        // bitmapData
        NSData *bitmapData = [self imageToBitmapAscii:[UIImage imageWithCGImage:subImgRef] thresh:thresh];
        
        // 压缩的长度
        unsigned long outLength = 0;
        // bitmapData -> unsigned char
        unsigned char *bitmapChars = (unsigned char*)[bitmapData bytes];
        // 压缩
        unsigned char *compressedBytes = compress_until(bitmapChars, bitmapData.length, &outLength);
        // compressedBytes -> data
        NSData *bitmapDataCompressed = [NSData dataWithBytes:compressedBytes length:sizeof(unsigned char) * outLength];
        
        // GG编码
        NSString *ggString = [NSString stringWithFormat:@"%@ %lu %lu %d %d %lu ", @"GG",
                              widthByteFixed,
                              CGImageGetHeight(subImgRef),
                              x,
                              (y + (maxHeight * n)),
                              outLength];
        // 声明一个GBK编码
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        // 字符串转化成 data
        NSData *ggData = [ggString dataUsingEncoding: gbkEncoding];
        
        // 换行符
        NSData *nData = [@"\n" dataUsingEncoding: NSUTF8StringEncoding];
        
        // 拼接
        [mutableData appendData:ggData];
        [mutableData appendData:bitmapDataCompressed];
        [mutableData appendData:nData];
        
        // FIX: memory leak
        CGImageRelease(subImgRef);
        free(compressedBytes);
    }
    
    return mutableData;
}

/**
 image -> CG
 @param image 图片
 @param x 坐标x
 @param y 坐标y
 @param thresh 阈值 0~255
 @return 图像数据
 */
+ (NSData *)imageCG:(UIImage *)image
                  x:(int)x
                  y:(int)y
             thresh:(int)thresh{
    
    return [[self sharedInstance] imageCG:image
                                        x:x
                                        y:y
                                   thresh:thresh];
}

- (NSData *)imageCG:(UIImage *)image
                  x:(int)x
                  y:(int)y
             thresh:(int)thresh{
    
    CGImageRef imageRef = [image CGImage];
    // 取图片的宽高
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t widthByteFixed = (width + 7) / 8;
    
    NSMutableData *mutableData = [[NSMutableData alloc]init];
    
    // bitmapData
    NSData *bitmapData = [self imageToBitmapAscii:image thresh:thresh];
    // CG编码
    NSString *cgString = [NSString stringWithFormat:@"%@ %lu %lu %d %d ", @"CG",
                          widthByteFixed,
                          height,
                          x,
                          y];
    // 声明一个GBK编码
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    // 字符串转化成 data
    NSData *cgData = [cgString dataUsingEncoding: gbkEncoding];
    
    // 换行符
    NSData *nData = [@"\n" dataUsingEncoding: NSUTF8StringEncoding];
    
    // 拼接
    [mutableData appendData:cgData];
    [mutableData appendData:bitmapData];
    [mutableData appendData:nData];
    
    return mutableData;
}

/**
 开始标签
 @param offset 偏移量
 @param width 宽度
 @param height 最大高度
 @param qty 打印份数
 @return CPCL
 */
+ (NSData *)area:(int)offset
           width:(int)width
          height:(int)height
             qty:(int)qty{
    return [[self sharedInstance] area:offset
                                 width:width
                                height:height
                                   qty:qty];
}

- (NSData *)area:(int)offset
           width:(int)width
          height:(int)height
             qty:(int)qty{
    
    NSMutableData *mutableData = [[NSMutableData alloc]init];
    
    // 换行符
    NSData *nData = [@"\n" dataUsingEncoding: NSUTF8StringEncoding];
    
    // 编码
    NSString *codeString = [NSString stringWithFormat:@"%@ %d %@ %d %d", @"!",
                            offset,
                            @"203 203",
                            height,
                            qty];
    
    // 声明一个GBK编码
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    // 字符串转化成 data
    NSData *codeStringData = [codeString dataUsingEncoding: gbkEncoding];
    
    // 编码 宽度
    NSString *widthString = [NSString stringWithFormat:@"%@ %d", @"PW", width];
    
    // 字符串转化成 data
    NSData *widthStringData = [widthString dataUsingEncoding: gbkEncoding];
    
    // 拼接
    [mutableData appendData:codeStringData];
    [mutableData appendData:nData];
    [mutableData appendData:widthStringData];
    [mutableData appendData:nData];
    
    return mutableData;
}

/**
 走纸
 @return CPCL
 */
+ (NSData *)form {
    
    return [[self sharedInstance] form];
}

- (NSData *)form {
    
    NSMutableData *mutableData = [[NSMutableData alloc]init];
    
    // form
    NSData *fData = [@"FORM" dataUsingEncoding: NSUTF8StringEncoding];
    // 换行符
    NSData *nData = [@"\n" dataUsingEncoding: NSUTF8StringEncoding];
    
    // 拼接
    [mutableData appendData:fData];
    [mutableData appendData:nData];
    
    return mutableData;
}

/**
 打印
 @return CPCL
 */
+ (NSData *)print {
    
    return [[self sharedInstance] print];
}

- (NSData *)print {
    
    NSMutableData *mutableData = [[NSMutableData alloc]init];
    
    // print
    NSData *pData = [@"PRINT" dataUsingEncoding: NSUTF8StringEncoding];
    // 换行符
    NSData *nData = [@"\n" dataUsingEncoding: NSUTF8StringEncoding];
    
    // 拼接
    [mutableData appendData:pData];
    [mutableData appendData:nData];
    
    return mutableData;
}

/**
 image -> Ascii图像数据(EG)
 @param image 图片
 @param thresh 阈值 0~255
 @return Ascii图像数据
 */
- (NSData *)imageToBitmapAscii:(UIImage *)image
                        thresh:(int)thresh {
    
    CGImageRef imageRef = [image CGImage];
    // 取图片的宽高
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t widthFixed = (width + 7) / 8 * 8;
    
    // 使用CFDataGetLength函数可以看到
    // 这个数据的长度是4*image.size.width*image.size.height
    // 也就是每一个像素点都占据了四个字节的长度，依次序分别是RGBA，即红色、绿色、蓝色值和透明度值
    CFDataRef pixelsData = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    // 使用函数CFDataGetBytePtr(bitmapData) 就可以拿到字节数组的指针了
    const unsigned char *pixels =  CFDataGetBytePtr(pixelsData);
    
    size_t len = widthFixed * height / 8;
    
    unsigned char *array = (unsigned char *)malloc(sizeof(unsigned char) * len);
    
    for (size_t i = 0, offset = 0, idx = 0; i < height; i++) { // 纵坐标
        for (size_t j = 0, bin, x; j < widthFixed / 8; j++) {
            bin = 0;
            for (unsigned char n = 0, r, g, b; n < 8; n++) {
                x = j * 8 + n; // 横坐标
                bin = (bin << 1);
                if (x < width) { // 只处理未超出x边界的数据
                    offset = (i * width + x) * 4; // (x, y)坐标的像素下标
                    r = pixels[offset + 0];
                    g = pixels[offset + 1];
                    b = pixels[offset + 2];
                    unsigned char gray = (r * 38 + g * 75 + b * 15) >> 7;
                    bin += (gray > thresh ? 0 : 1);
                }
            }
            // CG指令
            array[idx++] = bin;
        }
    }
    
    NSData *bitmapData = [NSData dataWithBytes:array length:sizeof(unsigned char) * len];
    
    // 释放
    CFRelease(pixelsData);
    free(array);
    
    return bitmapData;
}

@end
