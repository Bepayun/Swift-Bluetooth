//
//  PageView.h
//  BluetoothDemo
//
//  Created by apple on 2021/12/1.
//

#import <UIKit/UIKit.h>
#import "DocumentDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface PageView : UIView

@property (nonatomic,weak) id<DocumentDataSource> dataSource;
@property (nonatomic,assign) NSInteger page;

- (instancetype)initWithDataSource:(id<DocumentDataSource>)dataSource page:(NSInteger)page scale:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
