//
//  PageView.m
//  BluetoothDemo
//
//  Created by apple on 2021/12/1.
//

#import "PageView.h"

@implementation PageView

- (instancetype)initWithDataSource:(id<DocumentDataSource>)dataSource page:(NSInteger)page scale:(CGFloat)scale {
    //scale 为1 则代表将page 与屏幕相等
    CGRect rect = [[UIScreen mainScreen] bounds];
    NSLog(@"屏幕宽度---%f",rect.size.width);
    CGSize pageSize = [dataSource getPageSize:page];
    NSLog(@"pagesize宽度---%f",pageSize.width);
//    CGRect frame =CGRectMake(0, 0, rect.size.width, rect.size.height);
    CGRect frame = CGRectMake(0, 0, pageSize.width, pageSize.height);
    
    if (self = [self initWithFrame:frame]) {
        self.dataSource = dataSource;
        self.page = page;
        
        self.backgroundColor = [UIColor whiteColor];
//        CGAffineTransform transform = self.transform;
        
//        CGFloat trueScale = (rect.size.width/pageSize.width);
//        transform = CGAffineTransformScale(transform, trueScale*scale,trueScale*scale);//前面的2表示横向放大2倍，后边的0.5表示纵向缩小一半
//
//        self.transform = transform;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    [self.dataSource drawLayer:UIGraphicsGetCurrentContext() page:self.page];
}


@end
