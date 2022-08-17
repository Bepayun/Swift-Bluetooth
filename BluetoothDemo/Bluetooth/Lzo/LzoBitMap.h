//
//  LzoBitMap.h
//  BluetoothDemo
//
//  Created by apple on 2021/12/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LzoBitMap : NSObject

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
             thresh:(int)thresh;

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
             thresh:(int)thresh;

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
             qty:(int)qty;

/**
 走纸
 @return CPCL
 */
+ (NSData *)form;

/**
 打印
 @return CPCL
 */
+ (NSData *)print;


@end

NS_ASSUME_NONNULL_END
