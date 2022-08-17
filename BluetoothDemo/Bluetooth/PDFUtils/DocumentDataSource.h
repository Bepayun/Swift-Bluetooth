//
//  DocumentDataSource.h
//  BluetoothDemo
//
//  Created by apple on 2021/12/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DocumentDataSource <NSObject>

@property (nonatomic,assign) NSInteger pageCount;
@property (nonatomic,strong) NSURL * fileURL;
+ (instancetype)createWithFileUrl:(NSURL *)url;

- (void)drawLayer:(CGContextRef)context page:(NSInteger)page;
- (CGSize)getPageSize:(NSInteger)page;
@end
