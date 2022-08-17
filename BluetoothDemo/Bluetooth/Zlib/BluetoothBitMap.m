//
//  BluetoothBitMap.m
//  BluetoothDemo
//
//  Created by apple on 2021/12/15.
//  1个字节存8个像素

#import <Foundation/Foundation.h>
#import "BluetoothBitMap.h"

typedef NS_ENUM(NSInteger,BitPixels) {
    BPAlpha = 0,
    BPBlue = 1,
    BPGreen = 2,
    BPRed = 3
};

@implementation BluetoothBitMap

// 芝柯
- (NSData *)DrawBigBitmap:(UIImage*)image {
    
    CGImageRef imageRef = image.CGImage;
    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self bitmapRGBA8Context:imageRef];
    
    if(!context) {
        return nil;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);
    
    // Get a pointer to the data
    uint32_t *bitmapData = (uint32_t *)CGBitmapContextGetData(context);
    
    if (bitmapData) {
        int len;
        len = (width+7) / 8;
        uint8_t *bitmapdata = (uint8_t *) malloc((len+4)*height);
        
        //uint8_t *RowData = (uint8_t *) malloc(width * height/8 + 8*height/8);
        memset(bitmapdata, 0, (len+4)*height);
        int ndata = 0;
        
        // floyd steinberg
        int32_t *errors = (int32_t*) malloc((width*height)*sizeof(int32_t));
//        memset(bitmapdata, 0, (width+1)*(height+1));
        
        for (int i = 0; i < height;i++) {
            bitmapdata[ndata+0] = 0x1F;
            bitmapdata[ndata+1] = 0x10;
            bitmapdata[ndata+2] = (len%256);
            bitmapdata[ndata+3] = (len/256);
            for (int j = 0; j < len; j++) {
                bitmapdata[ndata+4 + j] = 0;
            }
            for (int j = 0; j < width; j++) {
                int color = bitmapData[i * width + j];
                int b = (color>>0)&0xff;
                int g = (color>>8)&0xff;
                int r = (color>>16)&0xff;
                int a = (color>>24)&0xff; // a 透明度 
                int gray = (r+g+b)*a/255/3;
                // if( grey <12 )
//                if (gray < 100  || (gray < 250 && j % 2 == 0)) {
//                    bitmapdata[ndata+4 + j/8] |= (0x80 >> (j%8));
//                }
                int error = 0;
//                if(i>height * 0.92 && j > width * 0.4) {
//                    printf("%d",gray);
//                }
                if (gray + errors[i * width + j] < 250 ) {
                    bitmapdata[ndata+4 + j/8] |= (0x80 >> (j%8));
                    error = gray + errors[i * width + j];
                } else {
                    error = gray + errors[i * width + j] - 255;
                }
                if (j < width-1) {
                    errors[(i)*width+(j+1)] += (7 * error) / 16;
                }
                if (i < height-1) {
                    if (j > 0) {
                        errors[(i+1)*width+(j-1)] += (3 * error) / 16;
                    }
                    errors[(i+1)*width+(j)] += (5 * error) / 16;
                    if (j < width-1) {
                        errors[(i+1)*width+(j+1)] += (1 * error) / 16;
                    }
                }
            }

            bitmapdata[ndata+2] = (len%256);
            bitmapdata[ndata+3] = (len/256);
            ndata+= 4+len;
        }
        NSMutableData *data = [[NSMutableData alloc] initWithCapacity:0];
        [data appendBytes:bitmapdata length:ndata];
        NSData *d = [self code:data];
        // 释放
        free(errors);
        free(bitmapData);
        CGContextRelease(context);
        
        return d;
    }
    
    NSLog(@"Error getting bitmap pixel data\n");
    CGContextRelease(context);
    
    return nil ;
}

// 图片通过抖动算法转为黑白图片 【PDD】
- (UIImage *)DrawBigBWImage:(UIImage*)image {
    
    CGImageRef imageRef = image.CGImage;
    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self bitmapRGBA8Context:imageRef];
    
    if(!context) {
        return nil;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);
    
    // Get a pointer to the data
    uint32_t *bitmapData = (uint32_t *)CGBitmapContextGetData(context);
    
    if (bitmapData) {
        // floyd steinberg
        int32_t *errors = (int32_t*) malloc((width*height)*sizeof(int32_t));
//        memset(bitmapdata, 0, (width+1)*(height+1));
        
        for (int i = 0; i < height;i++) {
            for (int j = 0; j < width; j++) {
                int color = bitmapData[i * width + j];
                int b = (color>>0)&0xff;
                int g = (color>>8)&0xff;
                int r = (color>>16)&0xff;
                int a = (color>>24)&0xff; // a 透明度
                int gray = (r+g+b)*a/255/3;
                // if( grey <12 )
//                if (gray < 100  || (gray < 250 && j % 2 == 0)) {
//                    bitmapdata[ndata+4 + j/8] |= (0x80 >> (j%8));
//                }
                int error = 0;
//                if(i>height * 0.92 && j > width * 0.4) {
//                    printf("%d",gray);
//                }
                if (gray + errors[i * width + j] < 250 ) {
                    bitmapData[i * width + j] = 0x000000ff;
                    error = gray + errors[i * width + j];
                } else {
                    bitmapData[i * width + j] = 0xffffffff;
                    error = gray + errors[i * width + j] - 255;
                }
                if (j < width-1) {
                    errors[(i)*width+(j+1)] += (7 * error) / 16;
                }
                if (i < height-1) {
                    if (j > 0) {
                        errors[(i+1)*width+(j-1)] += (3 * error) / 16;
                    }
                    errors[(i+1)*width+(j)] += (5 * error) / 16;
                    if (j < width-1) {
                        errors[(i+1)*width+(j+1)] += (1 * error) / 16;
                    }
                }
            }
        }
        
        CGImageRef outRef = CGBitmapContextCreateImage(context);
        UIImage* outImage = [[UIImage alloc] initWithCGImage:outRef];
        // 释放
        CGImageRelease(outRef);
        free(bitmapData);
        free(errors);
        CGContextRelease(context);
        return outImage;
    }
    
    NSLog(@"Error getting bitmap pixel data\n");
    CGContextRelease(context);
    
    return nil ;
}

- (NSData *)code:(NSData *)pUncompressedData {
    if (!pUncompressedData || [pUncompressedData length] == 0) {
        NSLog(@"%s: Error: Can't compress an empty or null NSData object.", __func__);
        return nil;
    }
    
    int deflateStatus;
    
    float buffer = 1.1;
    // z_stream zlib的核心数据结构 表比特流 同时用于deflate或者inflate过程
    do {
        z_stream zlibStreamStruct;
        zlibStreamStruct.zalloc    = Z_NULL; // Set zalloc, zfree, and opaque to Z_NULL so
        zlibStreamStruct.zfree     = Z_NULL; // that when we call deflateInit2 they will be
        zlibStreamStruct.opaque    = Z_NULL; // updated to use default allocation functions.
        zlibStreamStruct.total_out = 0; // Total number of output bytes produced so far
        zlibStreamStruct.next_in   = (Bytef*)[pUncompressedData bytes]; // Pointer to input bytes
        zlibStreamStruct.avail_in  = (uInt)[pUncompressedData length]; // Number of input bytes left to process
        
        int initError = deflateInit2(&zlibStreamStruct, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
        
        if (initError != Z_OK) {
            NSString *errorMsg = nil;
            
            switch (initError) {
                case Z_STREAM_ERROR:
                    errorMsg = @"Invalid parameter passed in to function.";
                    
                    break;
                    
                case Z_MEM_ERROR:
                    errorMsg = @"Insufficient memory.";
                    
                    break;
                    
                case Z_VERSION_ERROR:
                    errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                    
                    break;
                    
                default:
                    errorMsg = @"Unknown error code.";
                    
                    break;
            }
            NSLog(@"%s: deflateInit2() Error: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
            return nil;
        }
        
        // Create output memory buffer for compressed data. The zlib documentation states that
        // destination buffer size must be at least 0.1% larger than avail_in plus 12 bytes.
        NSMutableData *compressedData = [NSMutableData dataWithLength:[pUncompressedData length] * buffer + 12];
        
        do {
            // Store location where next byte should be put in next_out
            zlibStreamStruct.next_out = [compressedData mutableBytes] + zlibStreamStruct.total_out;
            
            // Calculate the amount of remaining free space in the output buffer
            
            // by subtracting the number of bytes that have been written so far
            
            // from the buffer's total capacity
            
            zlibStreamStruct.avail_out = (uInt)([compressedData length] - zlibStreamStruct.total_out);
            
            deflateStatus = deflate(&zlibStreamStruct, Z_FINISH);
            
        } while ( deflateStatus == Z_OK );
        
        if (deflateStatus == Z_BUF_ERROR && buffer < 32) {
            continue;
        }
        
        // Check for zlib error and convert code to usable error message if appropriate
        
        if (deflateStatus != Z_STREAM_END) {
            NSString *errorMsg = nil;
            switch (deflateStatus) {
                case Z_ERRNO:
                    errorMsg = @"Error occured while reading file.";
                    
                    break;
                    
                case Z_STREAM_ERROR:
                    errorMsg = @"The stream state was inconsistent (e.g., next_in or next_out was NULL).";
                    
                    break;
                    
                case Z_DATA_ERROR:
                    errorMsg = @"The deflate data was invalid or incomplete.";
                    
                    break;
                    
                case Z_MEM_ERROR:
                    errorMsg = @"Memory could not be allocated for processing.";
                    
                    break;
                    
                case Z_BUF_ERROR:
                    errorMsg = @"Ran out of output buffer for writing compressed bytes.";
                    
                    break;
                    
                case Z_VERSION_ERROR:
                    errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                    
                    break;
                    
                default:
                    errorMsg = @"Unknown error code.";
                    
                    break;
            }
            
            NSLog(@"%s: zlib error while attempting compression: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
            // Free data structures that were dynamically created for the stream.
            
            deflateEnd(&zlibStreamStruct);
            return nil;
        }
        
        // Free data structures that were dynamically created for the stream.
        
        deflateEnd(&zlibStreamStruct);
        [compressedData setLength: zlibStreamStruct.total_out];
        int countsize=compressedData.length;
        Byte aa[] ={(countsize>>0)&0xff};
        Byte bb[] = {(countsize>>8)&0xff};
        Byte cc[] = {(countsize>>16)&0xff};
        Byte dd[] = {(countsize>>24)&0xff};
        [compressedData replaceBytesInRange:NSMakeRange(4, 1) withBytes:aa length:1];
        [compressedData replaceBytesInRange:NSMakeRange(5, 1) withBytes:bb length:1];
        [compressedData replaceBytesInRange:NSMakeRange(6, 1) withBytes:cc length:1];
        [compressedData replaceBytesInRange:NSMakeRange(7, 1) withBytes:dd length:1];
        
        uLong crc = crc32(0L, Z_NULL, 0);
        crc = crc32(crc, compressedData.bytes+8,compressedData.length-12);
        
        Byte a[] = {(crc>>0)&0xff};
        Byte b[] = {(crc>>8)&0xff};
        Byte c[] = {(crc>>16)&0xff};
        Byte d[] = {(crc>>24)&0xff};
        
        [compressedData replaceBytesInRange:NSMakeRange(countsize-4, 1) withBytes:a length:1];
        [compressedData replaceBytesInRange:NSMakeRange(countsize-3, 1) withBytes:b length:1];
        [compressedData replaceBytesInRange:NSMakeRange(countsize-2, 1) withBytes:c length:1];
        [compressedData replaceBytesInRange:NSMakeRange(countsize-1, 1) withBytes:d length:1];
        return compressedData;
        
    } while ( false );
    
    return nil;
}

- (CGContextRef)bitmapRGBA8Context:(CGImageRef)CGImage {
    CGImageRef imageRef = CGImage;
    if (!imageRef) {
        return NULL;
    }
    
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;
    
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }
    
    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);
    
    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    // Create bitmap context
    context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);    // RGBA
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

- (UIImage *)imageWithscaleMaxWidth:(UIImage *)img MaxWidth:(CGFloat )maxWidth {
    CGImageRef imageRef = img.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    if (width > maxWidth) {
        CGFloat maxHeight = maxWidth * height / width;
        CGSize size = CGSizeMake(maxWidth, maxHeight);
        UIGraphicsBeginImageContext(size);
        [img drawInRect:CGRectMake(0, 0, maxWidth, maxHeight)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImage;
    }
    
    return img;
}

- (BOOL)addData:(Byte *)data length:(int)length {
    if (_offset + length > MAX_DATA_SIZE)
        return FALSE;
    memcpy(_buffer, data, length);
    _offset += length;
    return TRUE;
}


- (NSData *)getData {
    NSData *data;
    data = [[NSData alloc]initWithBytes:_buffer length:[self getDataLength]];
    return data;
}

- (int)getDataLength {
    return _offset;
}

- (void)reset {
    _offset = 0;
    _sendedDataLength = 0;
}

- (UIImage *)cgUIImage:(CGPDFPageRef)pageRef scale:(float )scale {
    CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFMediaBox);
//    float scale = 1;
//    float scale = 800/ pageRect.size.width;
     
    CGSize newSzie = CGSizeMake(pageRect.size.width*scale, pageRect.size.height*scale);
    UIGraphicsBeginImageContext(newSzie);
    
    // 由于坐标系不同，需要进行翻转
    CGContextRef imgContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(imgContext);
    // 进行坐标系的翻转
    CGContextTranslateCTM(imgContext, 0.0, pageRect.size.height*scale);
    CGContextScaleCTM(imgContext, scale, -scale);
    CGContextSetInterpolationQuality(imgContext, kCGInterpolationDefault);
    CGContextSetRenderingIntent(imgContext, kCGRenderingIntentDefault);
    CGContextDrawPDFPage(imgContext, pageRef);
    CGContextRestoreGState(imgContext);
     
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(imgContext);
    CGPDFPageRelease(pageRef);
    
//    NSURL *url = [[NSURL alloc] initWithString:@""];
//    CFURLRef ref = (__bridge CFURLRef)url;
//    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(ref);
//    CFRelease(ref);
//    
//    CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
    
     
    return tempImage;
}

//// 使用该方法不会模糊，根据屏幕密度计算 【弃用】
- (UIImage *)convertViewToImage:(UIView *)view width:(CGFloat)width scale:(CGFloat)scale {
//    CGFloat newScale = width/view.frame.size.width;

    //开始画图，以下方法。第一个参数表示区域大小。第二个参数表示是否是非透明的。假设须要显示半透明效果。须要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, view.frame.size.height), NO, scale);

//    // 关闭抗锯齿【貌似未起到效果】
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, false);
    CGContextSetAllowsFontSmoothing(context, false);
    CGContextSetAllowsFontSubpixelPositioning(context, false);
    CGContextSetAllowsFontSubpixelQuantization(context, false);

    // 将view上的子view加进来
    [view.layer renderInContext:context];
    CGContextRestoreGState(context);

    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    CGContextRelease(context);
//    image = [self scaleToSize:image scale:scale];
    return image;
}

- (UIImage *)scaleToSize:(UIImage *)img scale:(CGFloat)scale {
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    CGSize size = CGSizeMake(img.size.width*scale, img.size.height*scale);
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, img.size.width*scale, img.size.height*scale)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

@end
