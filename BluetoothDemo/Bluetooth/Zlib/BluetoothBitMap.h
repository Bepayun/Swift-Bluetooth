//
//  BluetoothBitMap.h
//  BluetoothDemo
//
//  Created by apple on 2021/12/15.
//

#import <Foundation/Foundation.h>
#include <CoreGraphics/CGImage.h>
#import <UIKit/UIKit.h>
#import <zlib.h>
#define MAX_DATA_SIZE (1024*1000)

NS_ASSUME_NONNULL_BEGIN

@interface BluetoothBitMap : NSObject {
    int _offset;
    int _sendedDataLength;
    Byte _buffer[];
}

- (UIImage *)DrawBigBWImage:(UIImage*)image;
- (NSData *)DrawBigBitmap:(UIImage*)image;
- (UIImage *)imageWithscaleMaxWidth:(UIImage *)img  MaxWidth:(CGFloat)maxWidth;
- (UIImage *)convertViewToImage:(UIView *)view width:(CGFloat)width scale:(CGFloat)scale;

// PDF 直接转图片的方法
- (UIImage *)cgUIImage:(CGPDFPageRef)pageRef scale:(float )scale;

@end

NS_ASSUME_NONNULL_END
